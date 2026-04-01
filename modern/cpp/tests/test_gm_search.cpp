#include <cmath>
#include <cstdint>
#include <cstdlib>
#include <iostream>
#include <stdexcept>
#include <string_view>
#include <vector>

#include "piep/crystal/cell.hpp"
#include "piep/crystal/reflection.hpp"
#include "piep/search/candidate_store.hpp"
#include "piep/search/gm_search.hpp"
#include "piep/simulation/sad_simulator.hpp"
#include "search_fixtures.hpp"

namespace {

auto approx(double lhs, double rhs, double tolerance = 1.0e-9) -> bool {
    return std::abs(lhs - rhs) <= tolerance;
}

void require(bool condition, std::string_view message) {
    if (!condition) {
        throw std::runtime_error(std::string(message));
    }
}

void require_cell_close(const piep::crystal::CellParameters& actual,
                        const piep::crystal::CellParameters& expected,
                        double length_tolerance,
                        double angle_tolerance,
                        std::string_view message) {
    require(approx(actual.a, expected.a, length_tolerance) && approx(actual.b, expected.b, length_tolerance) &&
                approx(actual.c, expected.c, length_tolerance) &&
                approx(actual.alpha_deg, expected.alpha_deg, angle_tolerance) &&
                approx(actual.beta_deg, expected.beta_deg, angle_tolerance) &&
                approx(actual.gamma_deg, expected.gamma_deg, angle_tolerance),
            message);
}

auto make_exact_volume_result(const std::vector<piep::search::SearchPattern>& patterns,
                              const piep::tests::CellFixture& fixture,
                              double absolute_increment,
                              const piep::search::SearchEngineSettings& engine_settings = {})
    -> piep::search::SearchEngineResult {
    const double volume = piep::crystal::direct_volume(fixture.cell);
    return piep::search::search_unit_cells(
        patterns,
        {
            volume,
            volume,
        },
        fixture.centering,
        {
            piep::search::IncrementMode::absolute,
            absolute_increment,
        },
        {},
        {},
        {
            0.5,
            0,
        },
        engine_settings);
}

auto find_spot_index(const piep::simulation::SimulatedPattern& pattern, const piep::crystal::MillerIndex& hkl)
    -> std::size_t {
    for (std::size_t index = 0; index < pattern.spots.size(); ++index) {
        const auto& spot = pattern.spots[index];
        if (spot.hkl.h == hkl.h && spot.hkl.k == hkl.k && spot.hkl.l == hkl.l) {
            return index;
        }
    }
    throw std::runtime_error("requested simulated spot was not found");
}

auto make_zone_selected_pattern(std::size_t slot,
                                const piep::tests::CellFixture& fixture,
                                const piep::crystal::MillerIndex& zone_axis,
                                const piep::crystal::MillerIndex& first_hkl,
                                const piep::crystal::MillerIndex& second_hkl,
                                double camera_constant,
                                double maximum_radius_mm,
                                const piep::simulation::ObservationNoiseSettings& noise = {})
    -> piep::search::SearchPattern {
    const auto pattern = piep::simulation::simulate_zone_pattern(
        "synthetic",
        fixture.cell,
        {
            static_cast<double>(zone_axis.h),
            static_cast<double>(zone_axis.k),
            static_cast<double>(zone_axis.l),
            0.0,
            0.0,
        },
        {
            fixture.centering,
            camera_constant,
            0.0,
            maximum_radius_mm,
            true,
        });

    const std::size_t first_index = find_spot_index(pattern, first_hkl);
    const std::size_t second_index = find_spot_index(pattern, second_hkl);
    const double angle_deg = piep::simulation::detail::angle_between_detector_vectors(
        pattern.spots[first_index].detector_coordinates_mm,
        pattern.spots[second_index].detector_coordinates_mm);

    const piep::simulation::BasisPairSelection selection {
        first_index,
        second_index,
        first_hkl,
        second_hkl,
        piep::indexing::detail::zone_axis(first_hkl, second_hkl),
        piep::indexing::detail::zone_multiplicity(first_hkl, second_hkl, fixture.centering),
        {
            pattern.spots[first_index].reciprocal_length,
            pattern.spots[second_index].reciprocal_length,
            angle_deg,
        },
    };

    return piep::tests::prepared_pattern(
        slot,
        piep::simulation::simulate_observation_from_pair("synthetic", pattern, selection, noise).observation);
}

auto evaluate_known_candidate(const std::vector<piep::search::SearchPattern>& patterns,
                              const piep::tests::CellFixture& fixture) -> piep::search::SearchCandidateEvaluation {
    piep::search::SearchCandidate candidate;
    candidate.direct_cell = fixture.cell;

    std::vector<std::size_t> active_slots;
    active_slots.reserve(patterns.size());
    for (const auto& pattern : patterns) {
        active_slots.push_back(pattern.slot);
    }
    return piep::search::evaluate_search_candidate(patterns, active_slots, candidate, fixture.centering);
}

auto wide_volume_result(const std::vector<piep::search::SearchPattern>& patterns,
                        const piep::tests::CellFixture& fixture,
                        double absolute_increment,
                        double maximum_volume = 1000.0) -> piep::search::SearchEngineResult {
    return piep::search::search_unit_cells(
        patterns,
        {
            0.0,
            maximum_volume,
        },
        fixture.centering,
        {
            piep::search::IncrementMode::absolute,
            absolute_increment,
        });
}

void require_low_candidate_fom(const piep::search::SearchCandidateEvaluation& evaluation,
                               std::size_t expected_pattern_count,
                               std::string_view message) {
    require(evaluation.status == piep::search::CandidateEvaluationStatus::ok, message);
    require(evaluation.pattern_matches.size() == expected_pattern_count, "synthetic pattern count mismatch");
    require(evaluation.aggregate_figure_of_merit < 1.0e-6, "synthetic aggregate FOM too large");
}

void require_search_recovers_known_cell(const piep::search::SearchEngineResult& result,
                                        const piep::tests::CellFixture& fixture,
                                        double length_tolerance,
                                        double angle_tolerance,
                                        double aggregate_fom_limit,
                                        std::string_view message) {
    require(!result.candidates.empty(), "search returned no candidates");

    const auto expected = piep::crystal::reduce_cell(fixture.cell, fixture.centering);
    const auto& top = result.candidates.front().evaluation;
    require_cell_close(top.reduced_cell, expected, length_tolerance, angle_tolerance, message);
    require(top.aggregate_figure_of_merit < aggregate_fom_limit, "top aggregate FOM too large");
}

void test_candidate_store_merges_and_replaces_duplicates() {
    using piep::search::CandidateCoordinateTolerances;
    using piep::search::CandidateStoreDecision;
    using piep::search::CandidateStoreState;
    using piep::search::SearchCandidateEvaluation;
    using piep::search::insert_candidate;

    CandidateStoreState state;
    const CandidateCoordinateTolerances coordinate_tolerances {0.2, 0.2, 0.2};

    SearchCandidateEvaluation base;
    base.status = piep::search::CandidateEvaluationStatus::ok;
    base.weight_sum = 1.7;
    base.aggregate_figure_of_merit = 1.0;
    base.candidate = {
        0,
        0,
        0,
        1,
        0.1,
        0.2,
        0.3,
        {},
        {},
        {
            4.0,
            5.0,
            6.0,
            90.0,
            100.0,
            110.0,
        },
        0.0,
        0.0,
        false,
    };
    base.reduced_cell = base.candidate.direct_cell;

    const auto inserted = insert_candidate(state, base, coordinate_tolerances);
    require(inserted.decision == CandidateStoreDecision::inserted, "base candidate was not inserted");
    require(state.candidates.size() == 1, "candidate store size after insert failed");
    const double initial_support = state.candidates.front().accumulated_support;

    SearchCandidateEvaluation worse = base;
    worse.aggregate_figure_of_merit = 2.0;
    worse.candidate.x = 0.15;
    worse.candidate.y = 0.25;
    const auto rejected = insert_candidate(state, worse, coordinate_tolerances);
    require(rejected.decision == CandidateStoreDecision::duplicate_rejected, "worse duplicate was not rejected");
    require(state.candidates.size() == 1, "candidate store size after duplicate reject failed");
    require(state.candidates.front().accumulated_support > initial_support, "support accumulation failed");

    SearchCandidateEvaluation better = base;
    better.aggregate_figure_of_merit = 0.5;
    better.candidate.x = 0.4;
    better.candidate.y = 0.45;
    better.reduced_cell.gamma_deg = 109.0;
    const auto replaced = insert_candidate(state, better, coordinate_tolerances);
    require(replaced.decision == CandidateStoreDecision::replaced_duplicates, "better duplicate was not replaced");
    require(state.candidates.size() == 1, "candidate store size after replacement failed");
    require(approx(state.candidates.front().evaluation.aggregate_figure_of_merit, 0.5),
            "replacement FOM failed");
}

void test_cupc_real_patterns_search_recover_known_cell() {
    const auto fixture = piep::tests::cupc_cell_fixture();
    const auto result = wide_volume_result(piep::tests::make_cupc_patterns(), fixture, 0.025);

    require(result.setup.status == piep::search::SearchGridStatus::ok, "CuPc search setup failed");
    require(result.total_candidate_count == 786, "CuPc candidate count failed");
    require(result.duplicate_rejection_count > 0 || result.replacement_count > 0,
            "CuPc search saw no duplicate-store activity");
    require_search_recovers_known_cell(result, fixture, 0.05, 0.8, 0.9, "CuPc top cell mismatch");
}

void test_grgds_real_patterns_search_recover_known_cell() {
    const auto fixture = piep::tests::grgds_cell_fixture();
    const auto result = wide_volume_result(piep::tests::make_grgds_patterns(), fixture, 0.025, 1500.0);

    require(result.setup.status == piep::search::SearchGridStatus::ok, "GRGDS search setup failed");
    require(result.total_candidate_count == 8642, "GRGDS candidate count failed");
    require(result.duplicate_rejection_count > 0 || result.replacement_count > 0,
            "GRGDS search saw no duplicate-store activity");
    require_search_recovers_known_cell(result, fixture, 0.05, 0.8, 0.9, "GRGDS top cell mismatch");
}

void test_lysozyme_real_patterns_search_recover_known_cell() {
    const auto fixture = piep::tests::lysozyme_cell_fixture();
    const auto result = make_exact_volume_result(piep::tests::make_lysozyme_square_patterns(), fixture, 0.025);

    require(result.setup.status == piep::search::SearchGridStatus::ok, "Lysozyme search setup failed");
    require_search_recovers_known_cell(result, fixture, 0.4, 1.0, 0.9, "Lysozyme top cell mismatch");
}

void test_cupc_zone_simulated_patterns_evaluate_known_cell() {
    const auto fixture = piep::tests::cupc_cell_fixture();
    const std::vector<piep::search::SearchPattern> patterns {
        make_zone_selected_pattern(1, fixture, {0, 0, 1}, {-1, -1, 0}, {1, 1, 0}, 1100.0, 500.0),
        make_zone_selected_pattern(2, fixture, {1, 1, 0}, {-3, 3, 0}, {3, -3, 0}, 1100.0, 500.0),
        make_zone_selected_pattern(3, fixture, {1, 0, 1}, {0, -2, 0}, {0, 2, 0}, 1100.0, 500.0),
    };

    require_low_candidate_fom(evaluate_known_candidate(patterns, fixture), patterns.size(), "CuPc synthetic evaluation failed");
}

void test_grgds_zone_simulated_patterns_evaluate_known_cell() {
    const auto fixture = piep::tests::grgds_cell_fixture();
    const std::vector<piep::search::SearchPattern> patterns {
        make_zone_selected_pattern(1, fixture, {0, 0, 1}, {-2, 0, 0}, {2, 0, 0}, 360.0, 450.0),
        make_zone_selected_pattern(2, fixture, {1, 1, 0}, {-1, 1, 0}, {1, -1, 0}, 360.0, 450.0),
        make_zone_selected_pattern(3, fixture, {1, 0, 1}, {-1, -1, 1}, {-3, 1, 3}, 360.0, 450.0),
    };

    require_low_candidate_fom(evaluate_known_candidate(patterns, fixture), patterns.size(), "GRGDS synthetic evaluation failed");
}

void test_lysozyme_zone_simulated_patterns_evaluate_known_cell() {
    const auto fixture = piep::tests::lysozyme_cell_fixture();
    const std::vector<piep::search::SearchPattern> patterns {
        make_zone_selected_pattern(1, fixture, {0, 0, 1}, {-1, 0, 0}, {1, 0, 0}, 720.0, 200.0),
        make_zone_selected_pattern(2, fixture, {1, 0, 0}, {0, -1, 0}, {0, 1, 0}, 720.0, 200.0),
        make_zone_selected_pattern(3, fixture, {1, 1, 0}, {-1, 1, 0}, {1, -1, 0}, 720.0, 200.0),
    };

    require_low_candidate_fom(evaluate_known_candidate(patterns, fixture), patterns.size(), "Lysozyme synthetic evaluation failed");
}

}  // namespace

int main() {
    try {
        test_candidate_store_merges_and_replaces_duplicates();
        test_cupc_real_patterns_search_recover_known_cell();
        test_grgds_real_patterns_search_recover_known_cell();
        test_lysozyme_real_patterns_search_recover_known_cell();
        test_cupc_zone_simulated_patterns_evaluate_known_cell();
        test_grgds_zone_simulated_patterns_evaluate_known_cell();
        test_lysozyme_zone_simulated_patterns_evaluate_known_cell();

        std::cout << "All GM search checks passed.\n";
        return EXIT_SUCCESS;
    }
    catch (const std::exception& error) {
        std::cerr << error.what() << '\n';
        return EXIT_FAILURE;
    }
}
