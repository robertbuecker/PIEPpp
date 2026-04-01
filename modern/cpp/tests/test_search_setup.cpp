#include <algorithm>
#include <array>
#include <cmath>
#include <cstdlib>
#include <iostream>
#include <stdexcept>
#include <string>
#include <string_view>
#include <vector>

#include "piep/search/pattern_prep.hpp"
#include "piep/search/reference_selection.hpp"
#include "piep/search/search_grid.hpp"

namespace {

auto approx(double lhs, double rhs, double tolerance = 1.0e-9) -> bool {
    return std::abs(lhs - rhs) <= tolerance;
}

void require(bool condition, std::string_view message) {
    if (!condition) {
        throw std::runtime_error(std::string(message));
    }
}

void require_slots(const std::vector<std::size_t>& actual,
                   const std::vector<std::size_t>& expected,
                   std::string_view message) {
    require(actual == expected, message);
}

auto legacy_pattern(std::size_t slot,
                    std::string title,
                    const std::array<double, 18>& fields,
                    bool excluded = false) -> piep::search::SearchPattern {
    return {
        slot,
        piep::search::prepare_pattern(
            piep::search::PatternObservation::from_legacy_numeric_fields(std::move(title), fields),
            {
                200000.0,
                5.0,
                5.0,
            }),
        excluded,
    };
}

auto find_classification(const piep::search::ReferenceSelection& selection, std::size_t slot)
    -> const piep::search::PatternClassification& {
    const auto iterator = std::find_if(
        selection.classifications.begin(),
        selection.classifications.end(),
        [slot](const piep::search::PatternClassification& classification) { return classification.slot == slot; });
    return *iterator;
}

void test_low_level_symmetry_classification() {
    using piep::search::PatternSymmetryIndicator;
    using piep::search::SearchMode;
    using piep::search::select_reference_pattern;

    const std::vector<piep::search::SearchPattern> patterns {
        legacy_pattern(1,
                       "oblique",
                       {100.0, 5.0, 10.0, 0.3, 12.0, 0.3, 14.0, 0.0, 80.0, 2.5, 0.0, 0.0, 0.0, 0.0, 5.0, 0.0, 5.0,
                        200000.0}),
        legacy_pattern(2,
                       "rectangular",
                       {100.0, 5.0, 10.0, 0.3, 12.0, 0.3, 15.620499, 0.0, 90.0, 2.5, 0.0, 0.0, 0.0, 0.0, 5.0, 0.0, 5.0,
                        200000.0}),
        legacy_pattern(3,
                       "centered",
                       {100.0, 5.0, 10.0, 0.3, 10.0, 0.3, 12.0, 0.0, 70.0, 2.5, 0.0, 0.0, 0.0, 0.0, 5.0, 0.0, 5.0,
                        200000.0}),
        legacy_pattern(4,
                       "square",
                       {100.0, 5.0, 10.0, 0.3, 10.0, 0.3, 14.142136, 0.0, 90.0, 2.5, 0.0, 0.0, 0.0, 0.0, 5.0, 0.0, 5.0,
                        200000.0}),
        legacy_pattern(5,
                       "hex",
                       {100.0, 5.0, 10.0, 0.3, 10.0, 0.3, 10.0, 0.0, 60.0, 2.5, 0.0, 0.0, 0.0, 0.0, 5.0, 0.0, 5.0,
                        200000.0}),
    };

    const auto selection = select_reference_pattern(patterns);
    require(find_classification(selection, 1).symmetry == PatternSymmetryIndicator::oblique, "oblique symmetry failed");
    require(find_classification(selection, 2).symmetry == PatternSymmetryIndicator::rectangular,
            "rectangular symmetry failed");
    require(find_classification(selection, 3).symmetry == PatternSymmetryIndicator::equal_first_second,
            "centered symmetry failed");
    require(find_classification(selection, 4).symmetry == PatternSymmetryIndicator::square, "square symmetry failed");
    require(find_classification(selection, 5).symmetry == PatternSymmetryIndicator::hexagonal, "hex symmetry failed");
}

void test_cupc_reference_selection_and_grid() {
    using piep::search::IncrementMode;
    using piep::search::IncrementSpecification;
    using piep::search::SearchGridStatus;
    using piep::search::SearchMode;
    using piep::search::initialize_search_grid;

    const std::vector<piep::search::SearchPattern> patterns {
        legacy_pattern(1, "1 CuPc pattern 19",
                       {1100.0000, 55.0000, 145.0000, 4.3500, 293.2600, 8.7978, 334.5031, 0.0000, 93.2800, 2.5000, 0.0,
                        0.0, 0.0, 0.0, 5.0, 0.0, 5.0, 300000.0}),
        legacy_pattern(2, "2 CuPc pattern 20",
                       {1100.0000, 55.0000, 144.8900, 4.3467, 310.2700, 9.3081, 305.4153, 0.0000, 74.5300, 2.5000, 0.0,
                        0.0, 0.0, 0.0, 5.0, 0.0, 5.0, 300000.0}),
        legacy_pattern(3, "3 CuPc pattern 24",
                       {1100.0000, 55.0000, 129.2900, 3.8787, 419.2200, 12.5766, 450.5573, 0.0000, 95.5800, 2.5000, 0.0,
                        0.0, 0.0, 0.0, 5.0, 0.0, 5.0, 300000.0}),
        legacy_pattern(4, "4 CuPc pattern 29",
                       {1100.0000, 55.0000, 86.2100, 2.5863, 370.6000, 11.1180, 379.5663, 0.0000, 89.3670, 2.5000, 0.0,
                        0.0, 0.0, 0.0, 5.0, 0.0, 5.0, 300000.0}),
        legacy_pattern(5, "5 CuPc pattern 30",
                       {1100.0000, 55.0000, 86.2600, 2.5878, 414.9200, 12.4476, 433.3040, 0.0000, 96.5400, 2.5000, 0.0,
                        0.0, 0.0, 0.0, 5.0, 0.0, 5.0, 300000.0}),
        legacy_pattern(6, "6 CuPc pattern 31",
                       {1100.0000, 55.0000, 86.2600, 2.5878, 511.5500, 15.3465, 512.6692, 0.0000, 85.9100, 2.5000, 0.0,
                        0.0, 0.0, 0.0, 5.0, 0.0, 5.0, 300000.0}),
        legacy_pattern(7, "7 CuPc pattern 32",
                       {1100.0000, 55.0000, 77.7300, 2.3319, 76.1300, 2.2839, 86.0699, 0.0000, 68.0200, 2.5000, 0.0,
                        0.0, 0.0, 0.0, 5.0, 0.0, 5.0, 300000.0}),
    };

    const auto setup = initialize_search_grid(
        patterns,
        {0.0, 1000.0},
        {IncrementMode::absolute, 0.025});

    require(setup.status == SearchGridStatus::ok, "CuPc grid setup failed");
    require(setup.reference.search_mode == SearchMode::general, "CuPc search mode failed");
    require(setup.reference.reference_slot == 7, "CuPc reference slot failed");
    require_slots(setup.reference.sorted_active_slots, {7, 4, 5, 1, 2, 6, 3}, "CuPc sorted order failed");
    require_slots(setup.reference.active_sequence_slots, {4, 5, 1, 2, 6, 3}, "CuPc sequence failed");
    require(setup.total_grid_points == 786, "CuPc total grid count failed");
    require(setup.layer_count == 12, "CuPc layer count failed");
    require(setup.first_layer_plane.count == 56, "CuPc first-layer grid count failed");
    require(approx(setup.first_layer_p, 0.233, 0.002), "CuPc first-layer p failed");
    require(approx(setup.last_layer_p, 0.305, 0.002), "CuPc last-layer p failed");
    require(approx(setup.chosen_range.minimum, 762.9, 0.8), "CuPc chosen Vmin failed");
}

void test_lysozyme_square_reference_and_grid() {
    using piep::search::IncrementMode;
    using piep::search::SearchGridStatus;
    using piep::search::SearchMode;
    using piep::search::initialize_search_grid;

    const std::vector<piep::search::SearchPattern> patterns {
        legacy_pattern(1, "1 P.2.0434 [001]",
                       {719.420, 35.971, 9.0992, 0.2730, 9.0992, 0.2730, 12.8682, 0.0000, 90.0000, 2.5000, 0.0, 0.0,
                        0.0, 0.0, 5.0, 0.0, 5.0, 200000.0}),
        legacy_pattern(2, "2 P.2.0038",
                       {719.420, 35.971, 9.2851, 0.2786, 111.3000, 3.3390, 111.6866, 0.0000, 90.0000, 2.5000, 0.0, 0.0,
                        0.0, 0.0, 5.0, 0.0, 5.0, 200000.0}),
        legacy_pattern(3, "3 P.2.0063",
                       {719.420, 35.971, 9.1075, 0.2732, 49.0000, 1.4700, 49.8392, 0.0000, 90.0000, 2.5000, 0.0, 0.0,
                        0.0, 0.0, 5.0, 0.0, 5.0, 200000.0}),
        legacy_pattern(4, "4 P.2.1152",
                       {719.420, 35.971, 9.3286, 0.2799, 75.5000, 2.2650, 76.0741, 0.0000, 90.0000, 2.5000, 0.0, 0.0,
                        0.0, 0.0, 5.0, 0.0, 5.0, 200000.0}),
        legacy_pattern(5, "5 P.2.0836",
                       {719.420, 35.971, 9.1996, 0.2760, 84.4000, 2.5320, 84.8999, 0.0000, 90.0000, 2.5000, 0.0, 0.0,
                        0.0, 0.0, 5.0, 0.0, 5.0, 200000.0}),
        legacy_pattern(6, "6 P.2.0974",
                       {719.420, 35.971, 9.0334, 0.2710, 59.5000, 1.7850, 60.1818, 0.0000, 90.0000, 2.5000, 0.0, 0.0,
                        0.0, 0.0, 5.0, 0.0, 5.0, 200000.0}),
    };

    const auto setup = initialize_search_grid(
        patterns,
        {0.0, 300000.0},
        {IncrementMode::absolute, 0.025});

    require(setup.status == SearchGridStatus::ok, "Lysozyme square grid setup failed");
    require(setup.reference.search_mode == SearchMode::square, "Lysozyme square search mode failed");
    require(setup.reference.reference_slot == 1, "Lysozyme square reference failed");
    require_slots(setup.reference.sorted_active_slots, {1, 3, 6, 4, 5, 2}, "Lysozyme square sort failed");
    require_slots(setup.reference.active_sequence_slots, {3, 6, 4, 5, 2}, "Lysozyme square sequence failed");
    require(setup.total_grid_points == 102, "Lysozyme square total grid count failed");
    require(setup.layer_count == 51, "Lysozyme square layer count failed");
    require(setup.first_layer_plane.count == 2, "Lysozyme square first-layer count failed");
    require(approx(setup.first_layer_p, 0.171, 0.002), "Lysozyme square first-layer p failed");
    require(approx(setup.last_layer_p, 0.607, 0.003), "Lysozyme square last-layer p failed");
    require(approx(setup.chosen_range.minimum, 84651.3, 1.5), "Lysozyme square chosen Vmin failed");
}

void test_lysozyme_second_grid_after_exclusions() {
    using piep::search::IncrementMode;
    using piep::search::SearchGridStatus;
    using piep::search::SearchMode;
    using piep::search::initialize_search_grid;

    const std::vector<piep::search::SearchPattern> patterns {
        legacy_pattern(1, "1 P.2.0434 [001]",
                       {719.420, 35.971, 9.0992, 0.2730, 9.0992, 0.2730, 12.8682, 0.0000, 90.0000, 2.5000, 0.0, 0.0,
                        0.0, 0.0, 5.0, 0.0, 5.0, 200000.0},
                       true),
        legacy_pattern(2, "2 P.2.0038",
                       {719.420, 35.971, 9.2851, 0.2786, 111.3000, 3.3390, 111.6866, 0.0000, 90.0000, 2.5000, 0.0, 0.0,
                        0.0, 0.0, 5.0, 0.0, 5.0, 200000.0}),
        legacy_pattern(3, "3 P.2.0063",
                       {719.420, 35.971, 9.1075, 0.2732, 49.0000, 1.4700, 49.8392, 0.0000, 90.0000, 2.5000, 0.0, 0.0,
                        0.0, 0.0, 5.0, 0.0, 5.0, 200000.0}),
        legacy_pattern(4, "4 P.2.1152",
                       {719.420, 35.971, 9.3286, 0.2799, 75.5000, 2.2650, 76.0741, 0.0000, 90.0000, 2.5000, 0.0, 0.0,
                        0.0, 0.0, 5.0, 0.0, 5.0, 200000.0}),
        legacy_pattern(5, "5 P.2.0836",
                       {719.420, 35.971, 9.1996, 0.2760, 84.4000, 2.5320, 84.8999, 0.0000, 90.0000, 2.5000, 0.0, 0.0,
                        0.0, 0.0, 5.0, 0.0, 5.0, 200000.0}),
        legacy_pattern(6, "6 P.2.0974",
                       {719.420, 35.971, 9.0334, 0.2710, 59.5000, 1.7850, 60.1818, 0.0000, 90.0000, 2.5000, 0.0, 0.0,
                        0.0, 0.0, 5.0, 0.0, 5.0, 200000.0}),
        legacy_pattern(7, "7 P.2.1064",
                       {719.420, 35.971, 12.9200, 0.3876, 80.1000, 2.4030, 81.1353, 0.0000, 90.0000, 2.5000, 0.0, 0.0,
                        0.0, 0.0, 5.0, 0.0, 5.0, 200000.0},
                       true),
        legacy_pattern(8, "8 P.2.0007",
                       {719.420, 35.971, 13.3156, 0.3995, 56.4000, 1.6921, 57.8826, 0.0000, 89.7000, 2.5000, 0.0, 0.0,
                        0.0, 0.0, 5.0, 0.0, 5.0, 200000.0},
                       true),
        legacy_pattern(9, "9 P.2.0028",
                       {719.420, 35.971, 12.9533, 0.3886, 20.8768, 0.6263, 21.1133, 0.0000, 73.0300, 2.5000, 0.0, 0.0,
                        0.0, 0.0, 5.0, 0.0, 5.0, 200000.0}),
    };

    const auto setup = initialize_search_grid(
        patterns,
        {0.0, 300000.0},
        {IncrementMode::absolute, 0.025});

    require(setup.status == SearchGridStatus::ok, "Lysozyme second grid setup failed");
    require(setup.reference.search_mode == SearchMode::rectangular, "Lysozyme second search mode failed");
    require(setup.reference.reference_slot == 3, "Lysozyme second reference failed");
    require_slots(setup.reference.active_sequence_slots, {9, 6, 4, 5, 2}, "Lysozyme second sequence failed");
    require(setup.total_grid_points == 29492, "Lysozyme second total grid count failed");
    require(setup.layer_count == 84, "Lysozyme second layer count failed");
    require(setup.first_layer_plane.count == 102, "Lysozyme second first-layer count failed");
    require(approx(setup.first_layer_p, 0.933, 0.004), "Lysozyme second first-layer p failed");
    require(approx(setup.last_layer_p, 7.596, 0.01), "Lysozyme second last-layer p failed");
    require(approx(setup.chosen_range.minimum, 36862.3, 1.0), "Lysozyme second chosen Vmin failed");
}

void test_grgds_reference_and_grid() {
    using piep::search::IncrementMode;
    using piep::search::SearchGridStatus;
    using piep::search::SearchMode;
    using piep::search::initialize_search_grid;

    const std::vector<piep::search::SearchPattern> patterns {
        legacy_pattern(1, "1 2.32",
                       {358.9000, 17.5930, 25.9724, 0.7792, 81.7823, 2.4535, 81.7925, 0.0000, 80.8861, 2.5000, 0.0,
                        0.0, 0.0, 0.0, 5.0, 0.0, 5.0, 200000.0}),
        legacy_pattern(2, "2 2.71",
                       {358.9000, 17.5930, 27.7292, 0.8319, 91.8230, 2.7547, 93.8435, 0.0000, 85.5651, 2.5000, 0.0,
                        0.0, 0.0, 0.0, 5.0, 0.0, 5.0, 200000.0}),
        legacy_pattern(3, "3 3.21",
                       {358.9000, 17.5930, 50.5200, 1.5156, 81.2344, 2.4370, 88.5512, 0.0000, 80.8163, 2.5000, 0.0,
                        0.0, 0.0, 0.0, 5.0, 0.0, 5.0, 200000.0}),
        legacy_pattern(4, "4 4.39",
                       {358.9000, 17.5930, 75.3997, 2.2620, 81.6313, 2.4489, 101.5291, 0.0000, 80.4580, 2.5000, 0.0,
                        0.0, 0.0, 0.0, 5.0, 0.0, 5.0, 200000.0}),
        legacy_pattern(5, "5 3.3",
                       {358.9000, 17.5930, 27.6289, 0.8289, 244.3731, 7.3312, 245.4994, 0.0000, 89.1019, 2.5000, 0.0,
                        0.0, 0.0, 0.0, 5.0, 0.0, 5.0, 200000.0}),
    };

    const auto setup = initialize_search_grid(
        patterns,
        {0.0, 1500.0},
        {IncrementMode::absolute, 0.025});

    require(setup.status == SearchGridStatus::ok, "GRGDS grid setup failed");
    require(setup.reference.search_mode == SearchMode::centered, "GRGDS search mode failed");
    require(setup.reference.reference_slot == 1, "GRGDS reference slot failed");
    require_slots(setup.reference.sorted_active_slots, {1, 2, 3, 4, 5}, "GRGDS sorted order failed");
    require_slots(setup.reference.active_sequence_slots, {2, 3, 4, 5}, "GRGDS sequence failed");
    require(setup.total_grid_points == 8642, "GRGDS total grid count failed");
    require(setup.layer_count == 72, "GRGDS layer count failed");
    require(setup.first_layer_plane.count == 43, "GRGDS first-layer count failed");
    require(approx(setup.first_layer_p, 0.521, 0.003), "GRGDS first-layer p failed");
    require(approx(setup.last_layer_p, 3.116, 0.01), "GRGDS last-layer p failed");
    require(approx(setup.chosen_range.minimum, 250.5, 1.0), "GRGDS chosen Vmin failed");
}

}  // namespace

int main() {
    try {
        test_low_level_symmetry_classification();
        test_cupc_reference_selection_and_grid();
        test_lysozyme_square_reference_and_grid();
        test_lysozyme_second_grid_after_exclusions();
        test_grgds_reference_and_grid();

        std::cout << "All search-setup checks passed.\n";
        return EXIT_SUCCESS;
    }
    catch (const std::exception& error) {
        std::cerr << error.what() << '\n';
        return EXIT_FAILURE;
    }
}
