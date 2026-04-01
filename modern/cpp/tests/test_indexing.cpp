#include <algorithm>
#include <cmath>
#include <cstdlib>
#include <iostream>
#include <stdexcept>
#include <string_view>

#include "piep/indexing/indexing_engine.hpp"
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

auto same_index(const piep::crystal::MillerIndex& lhs, const piep::crystal::MillerIndex& rhs) -> bool {
    return lhs.h == rhs.h && lhs.k == rhs.k && lhs.l == rhs.l;
}

auto find_match(const std::vector<piep::indexing::IndexingMatch>& matches,
                const piep::crystal::MillerIndex& first_hkl,
                const piep::crystal::MillerIndex& second_hkl) -> const piep::indexing::IndexingMatch& {
    const auto iterator = std::find_if(
        matches.begin(),
        matches.end(),
        [&](const piep::indexing::IndexingMatch& match) {
            return same_index(match.first_hkl, first_hkl) && same_index(match.second_hkl, second_hkl);
        });
    if (iterator == matches.end()) {
        throw std::runtime_error("expected indexing match not found");
    }
    return *iterator;
}

void test_centering_and_asymmetric_unit_rules() {
    using piep::crystal::MillerIndex;
    using piep::indexing::CrystalSystem;
    using piep::indexing::detail::is_reflection_allowed;
    using piep::indexing::detail::is_second_reflection_allowed;
    using piep::indexing::detail::zone_multiplicity;

    require(is_reflection_allowed('C', {1, 1, 0}), "C-centering acceptance failed");
    require(!is_reflection_allowed('C', {1, 0, 0}), "C-centering rejection failed");
    require(is_reflection_allowed('R', {1, 1, 0}), "R-centering acceptance failed");
    require(!is_reflection_allowed('R', {1, 0, 0}), "R-centering rejection failed");
    require(is_reflection_allowed('F', {1, 1, 1}), "F-centering odd acceptance failed");
    require(!is_reflection_allowed('F', {1, 1, 0}), "F-centering mixed rejection failed");

    require(is_second_reflection_allowed(CrystalSystem::triclinic, 'P', {-2, 1, 0}),
            "triclinic asymmetric-unit rule failed");
    require(!is_second_reflection_allowed(CrystalSystem::monoclinic, 'P', {-1, 1, 0}),
            "monoclinic asymmetric-unit rule failed");
    require(is_second_reflection_allowed(CrystalSystem::tetragonal, 'P', {2, 1, 0}),
            "tetragonal asymmetric-unit acceptance failed");
    require(!is_second_reflection_allowed(CrystalSystem::tetragonal, 'P', {1, 2, 0}),
            "tetragonal asymmetric-unit rejection failed");
    require(is_second_reflection_allowed(CrystalSystem::cubic, 'F', {2, 2, 2}), "cubic acceptance failed");
    require(!is_second_reflection_allowed(CrystalSystem::cubic, 'F', {2, 0, 2}), "cubic rejection failed");

    require(zone_multiplicity(MillerIndex {2, 0, 0}, MillerIndex {0, 2, 0}, 'P') == 4,
            "primitive multiplicity failed");
    require(zone_multiplicity(MillerIndex {1, 1, 0}, MillerIndex {1, -1, 0}, 'C') == 1,
            "centered multiplicity failed");
}

void test_synthetic_closed_loop_indexing() {
    using piep::crystal::CellParameters;
    using piep::crystal::MillerIndex;
    using piep::indexing::index_pattern;
    using piep::indexing::simulate_pattern_observation;

    const CellParameters cell {8.1, 10.3, 12.7, 91.2, 103.4, 109.8};
    const auto observation =
        simulate_pattern_observation("synthetic", cell, {1, 1, 0}, {0, 1, 1}, 500.0, 2.0, 0.2, 200000.0);
    const auto indexed = index_pattern(
        observation,
        cell,
        'P',
        {
            200000.0,
            5.0,
            5.0,
        });

    require(!indexed.overflow, "synthetic indexing overflowed");
    require(!indexed.matches.empty(), "synthetic indexing returned no matches");
    const auto match = find_match(indexed.matches, {1, 1, 0}, {0, 1, 1});
    require(match.figure_of_merit < 1.0e-6, "synthetic closed-loop FOM failed");
    require(same_index(match.zone_axis, {1, -1, 1}), "synthetic zone axis failed");
}

void test_cupc_pattern_19_indexes_consistently() {
    using piep::crystal::CellParameters;
    using piep::indexing::index_prepared_pattern;

    const auto patterns = piep::tests::make_cupc_patterns();
    const CellParameters cell {17.3289, 25.5672, 3.8175, 89.80, 95.35, 91.30};
    const auto indexed = index_prepared_pattern(patterns.front().prepared, cell, 'C');

    require(!indexed.overflow, "CuPc indexing overflowed");
    require(!indexed.matches.empty(), "CuPc indexing returned no matches");
    const auto& top = indexed.matches.front();
    require(same_index(top.first_hkl, {1, 3, 0}), "CuPc top first reflection failed");
    require(same_index(top.second_hkl, {1, -1, -1}), "CuPc top second reflection failed");
    require(same_index(top.zone_axis, {-3, 1, -4}), "CuPc top zone axis failed");
    require(approx(top.figure_of_merit, 0.62, 0.05), "CuPc top FOM failed");
    require(approx(top.predicted_camera_constant, 1099.0, 2.0), "CuPc camera constant failed");
}

void test_grgds_pattern_1_indexes_consistently() {
    using piep::crystal::CellParameters;
    using piep::indexing::index_prepared_pattern;

    const auto patterns = piep::tests::make_grgds_patterns();
    const CellParameters cell {28.6756, 4.4446, 19.4660, 90.00, 105.47, 89.98};
    const auto indexed = index_prepared_pattern(patterns.front().prepared, cell, 'C');

    require(!indexed.overflow, "GRGDS indexing overflowed");
    require(!indexed.matches.empty(), "GRGDS indexing returned no matches");
    const auto& top = indexed.matches.front();
    require(same_index(top.first_hkl, {2, 0, 0}), "GRGDS top first reflection failed");
    require(same_index(top.second_hkl, {1, 1, 0}), "GRGDS top second reflection failed");
    require(same_index(top.zone_axis, {0, 0, 1}), "GRGDS top zone axis failed");
    require(top.figure_of_merit < 0.05, "GRGDS top FOM failed");
}

void test_lysozyme_pattern_14_indexes_consistently() {
    using piep::crystal::CellParameters;
    using piep::indexing::index_prepared_pattern;

    const auto pattern = piep::tests::legacy_pattern(
        14,
        "14 P.2.0753",
        {719.420, 35.971, 19.0276, 0.5708, 46.5243, 1.3957, 49.8649, 0.0000, 88.7038, 2.5000, 0.0, 0.0, 0.0, 0.0,
         5.0, 0.0, 5.0, 200000.0});
    const CellParameters cell {79.0641, 79.0641, 38.2168, 90.00, 90.00, 90.00};
    const auto indexed = index_prepared_pattern(pattern.prepared, cell, 'P');

    require(!indexed.overflow, "Lysozyme indexing overflowed");
    require(!indexed.matches.empty(), "Lysozyme indexing returned no matches");
    const auto& top = indexed.matches.front();
    require(same_index(top.first_hkl, {0, 0, 1}), "Lysozyme top first reflection failed");
    require(same_index(top.second_hkl, {5, 1, 0}), "Lysozyme top second reflection failed");
    require(same_index(top.zone_axis, {-1, 5, 0}), "Lysozyme top zone axis failed");
    require(approx(top.figure_of_merit, 1.57, 0.08), "Lysozyme top FOM failed");
}

}  // namespace

int main() {
    try {
        test_centering_and_asymmetric_unit_rules();
        test_synthetic_closed_loop_indexing();
        test_cupc_pattern_19_indexes_consistently();
        test_grgds_pattern_1_indexes_consistently();
        test_lysozyme_pattern_14_indexes_consistently();

        std::cout << "All indexing checks passed.\n";
        return EXIT_SUCCESS;
    }
    catch (const std::exception& error) {
        std::cerr << error.what() << '\n';
        return EXIT_FAILURE;
    }
}
