#include <algorithm>
#include <array>
#include <cmath>
#include <cstdlib>
#include <iostream>
#include <stdexcept>
#include <string_view>
#include <vector>

#include "piep/search/candidate_generator.hpp"
#include "piep/search/search_grid.hpp"
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

void require_points(const std::vector<piep::search::PlanePoint>& actual,
                    const std::vector<std::array<double, 2>>& expected,
                    std::string_view message,
                    double tolerance = 1.0e-9) {
    require(actual.size() == expected.size(), message);
    for (std::size_t index = 0; index < expected.size(); ++index) {
        require(approx(actual[index].x, expected[index][0], tolerance), message);
        require(approx(actual[index].y, expected[index][1], tolerance), message);
    }
}

void test_general_oblique_plane_order() {
    using piep::search::PatternSymmetryIndicator;
    using piep::search::SearchMode;
    using piep::search::enumerate_plane_points;

    const auto plane = enumerate_plane_points({
        1.0,
        1.0,
        1.0,
        0.5,
        SearchMode::general,
        PatternSymmetryIndicator::oblique,
        1,
    });

    require(plane.geometry.nx == 2, "general-oblique nx failed");
    require(plane.geometry.ny == 2, "general-oblique ny failed");
    require_points(plane.points,
                   {
                       {0.0, 0.0},
                       {0.5, 0.0},
                       {1.0, 0.0},
                       {-0.5, 0.5},
                       {0.0, 0.5},
                       {0.5, 0.5},
                       {1.0, 0.5},
                       {-0.5, 1.0},
                       {0.0, 1.0},
                       {0.5, 1.0},
                       {1.0, 1.0},
                   },
                   "general-oblique ordering failed");
}

void test_general_full_plane_order() {
    using piep::search::PatternSymmetryIndicator;
    using piep::search::SearchMode;
    using piep::search::enumerate_plane_points;

    const auto plane = enumerate_plane_points({
        1.0,
        1.0,
        1.0,
        0.5,
        SearchMode::general,
        PatternSymmetryIndicator::rectangular,
        1,
    });

    require_points(plane.points,
                   {
                       {0.0, 0.0},
                       {0.5, 0.0},
                       {1.0, 0.0},
                       {0.0, 0.5},
                       {0.5, 0.5},
                       {1.0, 0.5},
                       {0.0, 1.0},
                       {0.5, 1.0},
                       {1.0, 1.0},
                   },
                   "general-full ordering failed");
}

void test_centered_plane_order() {
    using piep::search::PatternSymmetryIndicator;
    using piep::search::SearchMode;
    using piep::search::enumerate_plane_points;

    const auto plane = enumerate_plane_points({
        1.0,
        1.0,
        1.0,
        0.5,
        SearchMode::centered,
        PatternSymmetryIndicator::equal_first_second,
        2,
    });

    require(plane.geometry.effective_wall_cycles == 2, "centered cycle count failed");
    require_points(plane.points,
                   {
                       {0.0, 0.0},
                       {1.0, 0.0},
                       {0.0, 0.5},
                       {1.0, 0.5},
                       {0.0, 1.0},
                       {1.0, 1.0},
                       {0.5, 0.0},
                       {0.5, 0.5},
                       {0.5, 1.0},
                   },
                   "centered ordering failed");
}

void test_rectangular_plane_order() {
    using piep::search::PatternSymmetryIndicator;
    using piep::search::SearchMode;
    using piep::search::enumerate_plane_points;

    const auto plane = enumerate_plane_points({
        1.0,
        1.0,
        1.0,
        0.5,
        SearchMode::rectangular,
        PatternSymmetryIndicator::rectangular,
        2,
    });

    require(plane.geometry.effective_wall_cycles == 2, "rectangular cycle count failed");
    require_points(plane.points,
                   {
                       {0.0, 0.0},
                       {1.0, 0.0},
                       {0.0, 0.5},
                       {1.0, 0.5},
                       {0.0, 1.0},
                       {1.0, 1.0},
                       {0.5, 0.0},
                       {0.5, 1.0},
                       {0.5, 0.5},
                   },
                   "rectangular ordering failed");
}

void test_square_and_hex_plane_order() {
    using piep::search::PatternSymmetryIndicator;
    using piep::search::SearchMode;
    using piep::search::enumerate_plane_points;

    const auto square = enumerate_plane_points({
        1.0,
        1.0,
        1.0,
        0.25,
        SearchMode::square,
        PatternSymmetryIndicator::square,
        1,
    });
    require_points(square.points, {{0.0, 0.0}, {1.0, 1.0}}, "square ordering failed");

    const auto hex = enumerate_plane_points({
        1.0,
        1.0,
        1.0,
        0.25,
        SearchMode::hexagonal,
        PatternSymmetryIndicator::hexagonal,
        1,
    });
    require_points(hex.points, {{0.0, 0.0}, {1.0, 2.0 / 3.0}}, "hex ordering failed");
}

void test_cupc_candidate_generation() {
    using piep::search::CandidateGenerationStatus;
    using piep::search::IncrementMode;
    using piep::search::generate_search_candidates;
    using piep::search::initialize_search_grid;

    const auto setup = initialize_search_grid(
        piep::tests::make_cupc_patterns(),
        {0.0, 1000.0},
        {IncrementMode::absolute, 0.025});
    const auto generated = generate_search_candidates(setup);

    require(generated.status == CandidateGenerationStatus::ok, "CuPc candidate generation failed");
    require(generated.layers.size() == 12, "CuPc layer count failed");
    require(generated.total_candidate_count == 786, "CuPc candidate count failed");
    require(generated.candidates.size() == 786, "CuPc stored candidate count failed");
    require(generated.layers.front().point_count == 56, "CuPc first layer count failed");
    require(approx(generated.layers.front().direct_volume, setup.chosen_range.minimum, 1.0),
            "CuPc first-layer volume failed");
    require(approx(generated.candidates.front().x, 0.0), "CuPc first x failed");
    require(approx(generated.candidates.front().y, 0.0), "CuPc first y failed");
    require(approx(generated.candidates.front().z, setup.first_layer_height, 1.0e-12), "CuPc first z failed");
    require(!generated.candidates.front().minimized, "CuPc first candidate minimization failed");
}

void test_grgds_candidate_generation() {
    using piep::search::CandidateGenerationStatus;
    using piep::search::IncrementMode;
    using piep::search::generate_search_candidates;
    using piep::search::initialize_search_grid;

    const auto setup = initialize_search_grid(
        piep::tests::make_grgds_patterns(),
        {0.0, 1500.0},
        {IncrementMode::absolute, 0.025});
    const auto generated = generate_search_candidates(setup);

    require(generated.status == CandidateGenerationStatus::ok, "GRGDS candidate generation failed");
    require(generated.total_candidate_count == 8642, "GRGDS candidate count failed");
    require(generated.layers.front().point_count == 43, "GRGDS first layer count failed");
    require(approx(generated.candidates[0].x, 0.0), "GRGDS first x failed");
    require(approx(generated.candidates[0].y, 0.0), "GRGDS first y failed");
    require(approx(generated.candidates[1].x, setup.half_width_x, 1.0e-12), "GRGDS second x failed");
    require(approx(generated.candidates[1].y, 0.0), "GRGDS second y failed");
}

void test_lysozyme_square_candidate_generation() {
    using piep::search::CandidateGenerationStatus;
    using piep::search::IncrementMode;
    using piep::search::generate_search_candidates;
    using piep::search::initialize_search_grid;

    const auto setup = initialize_search_grid(
        piep::tests::make_lysozyme_square_patterns(),
        {0.0, 300000.0},
        {IncrementMode::absolute, 0.025});
    const auto generated = generate_search_candidates(setup);

    require(generated.status == CandidateGenerationStatus::ok, "Lysozyme square candidate generation failed");
    require(generated.total_candidate_count == 102, "Lysozyme square candidate count failed");
    require(generated.layers.front().point_count == 2, "Lysozyme square first layer count failed");
    require(approx(generated.candidates[0].x, 0.0), "Lysozyme square first x failed");
    require(approx(generated.candidates[0].y, 0.0), "Lysozyme square first y failed");
    require(approx(generated.candidates[1].x, setup.half_width_x, 1.0e-12), "Lysozyme square second x failed");
    require(approx(generated.candidates[1].y, setup.half_width_y, 1.0e-12), "Lysozyme square second y failed");
}

void test_lysozyme_rectangular_candidate_generation() {
    using piep::search::CandidateGenerationStatus;
    using piep::search::IncrementMode;
    using piep::search::generate_search_candidates;
    using piep::search::initialize_search_grid;

    const auto setup = initialize_search_grid(
        piep::tests::make_lysozyme_second_patterns(),
        {0.0, 300000.0},
        {IncrementMode::absolute, 0.025});
    const auto generated = generate_search_candidates(setup);

    require(generated.status == CandidateGenerationStatus::ok, "Lysozyme rectangular candidate generation failed");
    require(generated.total_candidate_count == 29492, "Lysozyme rectangular candidate count failed");
    require(generated.layers.front().point_count == 102, "Lysozyme rectangular first layer count failed");
    require(approx(generated.candidates[0].x, 0.0), "Lysozyme rectangular first x failed");
    require(approx(generated.candidates[0].y, 0.0), "Lysozyme rectangular first y failed");
    require(approx(generated.candidates[1].x, setup.half_width_x, 1.0e-12), "Lysozyme rectangular second x failed");
    require(approx(generated.candidates[1].y, 0.0), "Lysozyme rectangular second y failed");
}

void test_candidate_preview_limit() {
    using piep::search::CandidateGenerationStatus;
    using piep::search::IncrementMode;
    using piep::search::generate_search_candidates;
    using piep::search::initialize_search_grid;

    const auto setup = initialize_search_grid(
        piep::tests::make_cupc_patterns(),
        {0.0, 1000.0},
        {IncrementMode::absolute, 0.025});
    const auto preview = generate_search_candidates(setup, {0.5, 3});

    require(preview.status == CandidateGenerationStatus::ok, "preview candidate generation failed");
    require(preview.total_candidate_count == 786, "preview candidate count failed");
    require(preview.candidates.size() == 3, "preview storage limit failed");
    require(preview.truncated, "preview truncation flag failed");
}

void test_minni_is_applied_when_required() {
    using piep::search::CandidateGenerationStatus;
    using piep::search::PatternSymmetryIndicator;
    using piep::search::SearchGridSetup;
    using piep::search::SearchGridStatus;
    using piep::search::SearchMode;
    using piep::search::generate_search_candidates;

    SearchGridSetup setup;
    setup.status = SearchGridStatus::ok;
    setup.reference.status = piep::search::ReferenceSelectionStatus::ok;
    setup.reference.search_mode = SearchMode::general;
    setup.reference.reference_symmetry = PatternSymmetryIndicator::oblique;
    setup.reduced_reference_first = 1.0;
    setup.reduced_reference_second = 1.0;
    setup.reduced_reference_angle_deg = 90.0;
    setup.flc = 1.0;
    setup.h0 = 1.0;
    setup.first_layer_height = 1.0;
    setup.last_layer_height = 1.0;
    setup.half_width_x = 1.0;
    setup.half_width_y = 1.0;
    setup.absolute_increment = 0.25;
    setup.layer_scale = 1.0;
    setup.layer_count = 1;

    const auto generated = generate_search_candidates(setup);

    require(generated.status == CandidateGenerationStatus::ok, "synthetic candidate generation failed");
    const auto iterator = std::find_if(
        generated.candidates.begin(),
        generated.candidates.end(),
        [](const piep::search::SearchCandidate& candidate) { return candidate.minimized; });
    require(iterator != generated.candidates.end(), "synthetic minimization trigger failed");
    require(iterator->direct_volume > 0.0, "synthetic direct volume failed");
}

}  // namespace

int main() {
    try {
        test_general_oblique_plane_order();
        test_general_full_plane_order();
        test_centered_plane_order();
        test_rectangular_plane_order();
        test_square_and_hex_plane_order();
        test_cupc_candidate_generation();
        test_grgds_candidate_generation();
        test_lysozyme_square_candidate_generation();
        test_lysozyme_rectangular_candidate_generation();
        test_candidate_preview_limit();
        test_minni_is_applied_when_required();

        std::cout << "All candidate-generation checks passed.\n";
        return EXIT_SUCCESS;
    }
    catch (const std::exception& error) {
        std::cerr << error.what() << '\n';
        return EXIT_FAILURE;
    }
}
