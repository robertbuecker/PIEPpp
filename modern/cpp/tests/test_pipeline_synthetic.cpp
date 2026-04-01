#include <algorithm>
#include <cmath>
#include <cstdlib>
#include <iostream>
#include <limits>
#include <stdexcept>
#include <string_view>
#include <vector>

#include "piep/indexing/indexing_engine.hpp"
#include "piep/postprocessing/cell_postprocessing.hpp"
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

struct SyntheticObservationSettings {
    double positional_sigma_mm {};
    double pixel_size_mm {0.05};
    double angle_bias_deg {};
};

auto exact_volume_result(const std::vector<piep::search::SearchPattern>& patterns,
                         const piep::tests::CellFixture& fixture) -> piep::search::SearchEngineResult {
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
            0.01,
        });
}

auto maximum_radius_mm(const piep::search::PatternObservation& observation) -> double {
    return 1.35 * std::max({observation.first_radius, observation.second_radius, observation.third_radius});
}

auto best_match_for_pattern(const piep::search::SearchPattern& archived_pattern, const piep::tests::CellFixture& fixture)
    -> piep::indexing::IndexingMatch {
    const auto indexed =
        piep::indexing::index_prepared_pattern(archived_pattern.prepared, fixture.cell, fixture.centering);
    require(!indexed.matches.empty(), "archived pattern did not index in its source cell");
    return indexed.matches.front();
}

auto make_explicit_selection(const piep::simulation::SimulatedPattern& pattern,
                             const piep::tests::CellFixture& fixture,
                             const piep::indexing::IndexingMatch& match) -> piep::simulation::BasisPairSelection {
    const auto find_spot_index = [&](const piep::crystal::MillerIndex& hkl) {
        for (std::size_t index = 0; index < pattern.spots.size(); ++index) {
            const auto& spot = pattern.spots[index];
            if (spot.hkl.h == hkl.h && spot.hkl.k == hkl.k && spot.hkl.l == hkl.l) {
                return index;
            }
        }
        throw std::runtime_error("requested simulated spot was not found");
    };

    const std::size_t first_index = find_spot_index(match.first_hkl);
    const std::size_t second_index = find_spot_index(match.second_hkl);
    return {
        first_index,
        second_index,
        match.first_hkl,
        match.second_hkl,
        match.zone_axis,
        piep::indexing::detail::zone_multiplicity(match.first_hkl, match.second_hkl, fixture.centering),
        {
            pattern.spots[first_index].reciprocal_length,
            pattern.spots[second_index].reciprocal_length,
            piep::simulation::detail::angle_between_detector_vectors(
                pattern.spots[first_index].detector_coordinates_mm,
                pattern.spots[second_index].detector_coordinates_mm),
        },
    };
}

auto make_synthetic_detector_pattern(std::size_t slot,
                                     const piep::tests::CellFixture& fixture,
                                     const piep::search::SearchPattern& archived_pattern,
                                     const SyntheticObservationSettings& settings,
                                     std::uint64_t seed) -> piep::search::SearchPattern {
    const auto& archived = archived_pattern.prepared.restored.observation;
    const auto match = best_match_for_pattern(archived_pattern, fixture);
    const auto zone = piep::simulation::zone_direction_from_axis(match.zone_axis);
    const auto pattern = piep::simulation::simulate_zone_pattern("synthetic detector",
                                                                 fixture.cell,
                                                                 zone,
                                                                 {
                                                                     fixture.centering,
                                                                     archived.camera_constant,
                                                                     0.0,
                                                                     maximum_radius_mm(archived),
                                                                     true,
                                                                 });
    const auto selection = make_explicit_selection(pattern, fixture, match);
    const auto simulated = piep::simulation::simulate_observation_from_pair(
        "synthetic detector",
        pattern,
        selection,
        {
            settings.positional_sigma_mm,
            std::max(archived.first_radius_sigma, archived.second_radius_sigma),
            archived.angle_sigma_deg,
            archived.camera_constant_sigma,
            fixture.high_voltage_volts,
            seed,
        });

    const double wavelength_angstrom = piep::search::electron_wavelength_angstrom(fixture.high_voltage_volts);
    piep::search::PatternObservation observation = piep::search::observation_from_detector_geometry({
        archived.title,
        {
            simulated.first_detector_coordinates_mm[0] / settings.pixel_size_mm,
            simulated.first_detector_coordinates_mm[1] / settings.pixel_size_mm,
        },
        {
            simulated.second_detector_coordinates_mm[0] / settings.pixel_size_mm,
            simulated.second_detector_coordinates_mm[1] / settings.pixel_size_mm,
        },
        {0.0, 0.0},
        archived.camera_constant / wavelength_angstrom,
        wavelength_angstrom,
        settings.pixel_size_mm,
        settings.pixel_size_mm,
        archived.camera_constant_sigma,
        std::max(archived.first_radius_sigma, archived.second_radius_sigma),
        archived.angle_sigma_deg,
        archived.third_radius_sigma,
        fixture.high_voltage_volts,
    });
    observation.angle_deg += settings.angle_bias_deg;
    return piep::tests::prepared_pattern(slot, std::move(observation));
}

auto make_synthetic_legacy_pattern(std::size_t slot,
                                   const piep::tests::CellFixture& fixture,
                                   const piep::search::SearchPattern& archived_pattern,
                                   const SyntheticObservationSettings& settings,
                                   std::uint64_t seed) -> piep::search::SearchPattern {
    (void) seed;
    const auto& archived = archived_pattern.prepared.restored.observation;
    const auto match = best_match_for_pattern(archived_pattern, fixture);
    piep::search::PatternObservation observation = piep::indexing::simulate_pattern_observation(
        archived.title,
        fixture.cell,
        match.first_hkl,
        match.second_hkl,
        archived.camera_constant,
        archived.camera_constant_sigma,
        archived.angle_sigma_deg,
        fixture.high_voltage_volts);
    observation.angle_deg += settings.angle_bias_deg;
    return piep::tests::prepared_pattern(slot, std::move(observation));
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

template <typename Builder>
void run_archived_synthetic_pipeline_case(const piep::tests::CellFixture& fixture,
                                          const std::vector<piep::search::SearchPattern>& archived_patterns,
                                          std::size_t pattern_count,
                                          const std::vector<double>& angle_biases_deg,
                                          const SyntheticObservationSettings& settings,
                                          Builder builder,
                                          std::string_view label,
                                          double length_tolerance,
                                          double angle_tolerance,
                                          piep::postprocessing::CrystalSystem minimum_system) {
    require(pattern_count <= archived_patterns.size(), "archived pattern request exceeds available patterns");
    require(pattern_count == angle_biases_deg.size(), "angle-bias count mismatch");

    std::vector<piep::search::SearchPattern> synthetic_patterns;
    for (std::size_t index = 0; index < pattern_count; ++index) {
        SyntheticObservationSettings per_pattern_settings = settings;
        per_pattern_settings.angle_bias_deg = angle_biases_deg[index];
        synthetic_patterns.push_back(builder(index + 1, fixture, archived_patterns[index], per_pattern_settings, 1234 + index));
    }

    const auto search_result = exact_volume_result(synthetic_patterns, fixture);
    if (search_result.setup.status != piep::search::SearchGridStatus::ok) {
        throw std::runtime_error(std::string(label) + ": synthetic search setup failed");
    }
    if (search_result.candidates.empty()) {
        throw std::runtime_error(std::string(label) + ": synthetic search returned no candidates");
    }

    double best_error = std::numeric_limits<double>::infinity();
    std::string best_description;
    const std::size_t checked_candidate_count = search_result.candidates.size();
    for (std::size_t candidate_index = 0; candidate_index < checked_candidate_count; ++candidate_index) {
        const auto postprocessed = piep::postprocessing::conventionalize_cell(
            search_result.candidates[candidate_index].evaluation.reduced_cell,
            'P',
            {
                fixture.centering,
                minimum_system,
            });
        require(postprocessed.preferred_candidate.has_value(), "synthetic post-processing returned no candidate");

        const auto& actual = postprocessed.preferred_candidate->cell;
        const bool close = approx(actual.a, fixture.cell.a, length_tolerance) &&
                           approx(actual.b, fixture.cell.b, length_tolerance) &&
                           approx(actual.c, fixture.cell.c, length_tolerance) &&
                           approx(actual.alpha_deg, fixture.cell.alpha_deg, angle_tolerance) &&
                           approx(actual.beta_deg, fixture.cell.beta_deg, angle_tolerance) &&
                           approx(actual.gamma_deg, fixture.cell.gamma_deg, angle_tolerance);
        if (close) {
            return;
        }

        const double error = std::abs(actual.a - fixture.cell.a) + std::abs(actual.b - fixture.cell.b) +
                             std::abs(actual.c - fixture.cell.c) +
                             std::abs(actual.alpha_deg - fixture.cell.alpha_deg) +
                             std::abs(actual.beta_deg - fixture.cell.beta_deg) +
                             std::abs(actual.gamma_deg - fixture.cell.gamma_deg);
        if (error < best_error) {
            best_error = error;
            best_description = std::to_string(actual.a) + ", " + std::to_string(actual.b) + ", " +
                               std::to_string(actual.c) + ", " + std::to_string(actual.alpha_deg) + ", " +
                               std::to_string(actual.beta_deg) + ", " + std::to_string(actual.gamma_deg);
        }
    }
    throw std::runtime_error(std::string(label) + ": no top candidate conventionalized close enough; best was " +
                             best_description);
}

void test_synthetic_reciprocal_cupc_patterns_stay_self_consistent() {
    const auto fixture = piep::tests::cupc_cell_fixture();
    const auto archived = piep::tests::make_cupc_patterns();
    std::vector<piep::search::SearchPattern> synthetic_patterns;
    for (std::size_t index = 0; index < archived.size(); ++index) {
        synthetic_patterns.push_back(make_synthetic_legacy_pattern(
            index + 1,
            fixture,
            archived[index],
            {
                0.0,
                0.05,
                0.0,
            },
            1234 + index));
    }

    const auto evaluation = evaluate_known_candidate(synthetic_patterns, fixture);
    require(evaluation.status == piep::search::CandidateEvaluationStatus::ok,
            "CuPc synthetic reciprocal candidate evaluation failed");
    require(evaluation.pattern_matches.size() == synthetic_patterns.size(),
            "CuPc synthetic reciprocal pattern count mismatch");
    require(evaluation.aggregate_figure_of_merit < 2.0, "CuPc synthetic reciprocal FOM too large");
}

void test_synthetic_detector_grgds_patterns_stay_self_consistent() {
    const auto fixture = piep::tests::grgds_cell_fixture();
    const auto archived = piep::tests::make_grgds_patterns();
    std::vector<piep::search::SearchPattern> synthetic_patterns;
    const std::vector<double> angle_biases {0.20, -0.15, 0.10, -0.08, 0.05};
    for (std::size_t index = 0; index < archived.size(); ++index) {
        synthetic_patterns.push_back(make_synthetic_detector_pattern(
            index + 1,
            fixture,
            archived[index],
            {
                0.05,
                0.05,
                angle_biases[index],
            },
            2234 + index));
    }

    const auto evaluation = evaluate_known_candidate(synthetic_patterns, fixture);
    require(evaluation.status == piep::search::CandidateEvaluationStatus::ok,
            "GRGDS synthetic detector candidate evaluation failed");
    require(evaluation.pattern_matches.size() == synthetic_patterns.size(),
            "GRGDS synthetic detector pattern count mismatch");
    require(evaluation.aggregate_figure_of_merit < 1.5, "GRGDS synthetic detector FOM too large");
}

void test_synthetic_detector_pipeline_for_lysozyme() {
    run_archived_synthetic_pipeline_case(piep::tests::lysozyme_cell_fixture(),
                                         piep::tests::make_lysozyme_square_patterns(),
                                         4,
                                         {0.15, -0.12, 0.08, -0.06},
                                         {
                                             0.05,
                                             0.05,
                                             0.0,
                                         },
                                         make_synthetic_detector_pattern,
                                         "Lysozyme synthetic detector conventional cell mismatch",
                                         0.30,
                                         0.60,
                                         piep::postprocessing::CrystalSystem::orthorhombic);
}

}  // namespace

int main() {
    try {
        test_synthetic_reciprocal_cupc_patterns_stay_self_consistent();
        test_synthetic_detector_grgds_patterns_stay_self_consistent();
        test_synthetic_detector_pipeline_for_lysozyme();

        std::cout << "All synthetic pipeline checks passed.\n";
        return EXIT_SUCCESS;
    }
    catch (const std::exception& error) {
        std::cerr << error.what() << '\n';
        return EXIT_FAILURE;
    }
}
