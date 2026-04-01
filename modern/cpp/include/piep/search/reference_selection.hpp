#pragma once

#include <algorithm>
#include <array>
#include <cmath>
#include <cstddef>
#include <limits>
#include <vector>

#include "piep/crystal/reflection.hpp"
#include "piep/search/pattern_prep.hpp"

namespace piep::search {

// Search setup operates on A-memory style slots rather than zero-based vector
// indices because the legacy protocols and publication transcripts refer to
// patterns by their 1-based memory numbers.
struct SearchPattern {
    std::size_t slot {};
    PreparedPattern prepared {};
    bool excluded {};
};

enum class ReferenceSelectionStatus {
    ok,
    insufficient_patterns,
};

// irf(5, i) in the legacy code. Values 3, 4, and 5 distinguish which pair of
// reciprocal vectors are metrically equal even though they all map to the same
// 2D search mode.
enum class PatternSymmetryIndicator {
    oblique = 1,
    rectangular = 2,
    equal_first_second = 3,
    equal_first_third = 4,
    equal_second_third = 5,
    square = 6,
    hexagonal = 7,
};

// i05 in the legacy code.
enum class SearchMode {
    general = 0,
    centered = 1,
    rectangular = 2,
    square = 6,
    hexagonal = 7,
};

struct PatternClassification {
    std::size_t slot {};
    PatternSymmetryIndicator symmetry {PatternSymmetryIndicator::oblique};
    double ordering_scalar {};
    double primitive_volume_estimate {};
    bool excluded {};
};

struct ReferenceSelectionSettings {
    double equal_length_relative_tolerance {0.001};
    double right_angle_tolerance_deg {0.2};
    double exact_square_hex_tolerance_deg {0.005};
    double exact_square_length_tolerance {0.0001};
    double underdetermined_ratio_tolerance {0.01};
    bool force_full_grid {};
    double wall_sigma_multiplier {};
};

struct ReferenceSelection {
    ReferenceSelectionStatus status {ReferenceSelectionStatus::insufficient_patterns};
    std::vector<PatternClassification> classifications {};
    std::vector<std::size_t> sorted_active_slots {};
    std::vector<std::size_t> active_sequence_slots {};
    std::vector<std::size_t> close_pattern_slots {};
    std::size_t active_pattern_count {};
    std::size_t excluded_pattern_count {};
    std::size_t reference_slot {};
    PatternSymmetryIndicator reference_symmetry {PatternSymmetryIndicator::oblique};
    SearchMode search_mode {SearchMode::general};
    double minimum_estimated_volume {};
    double maximum_estimated_volume {};
    double mean_estimated_volume {};
    double average_reference_sigma {};
    double relative_reference_sigma {};
    double wall_thickness {};
    bool underdetermined {};
};

namespace detail {

[[nodiscard]] constexpr auto legacy_code(PatternSymmetryIndicator indicator) -> int {
    return static_cast<int>(indicator);
}

[[nodiscard]] constexpr auto legacy_code(SearchMode mode) -> int {
    return static_cast<int>(mode);
}

[[nodiscard]] inline auto relative_difference(double lhs, double rhs) -> double {
    const double denominator = lhs + rhs;
    if (std::abs(denominator) < 1.0e-12) {
        return 0.0;
    }
    return std::abs(lhs - rhs) / denominator;
}

[[nodiscard]] inline auto pattern_symmetry_indicator(const PatternObservation& observation,
                                                     const ReferenceSelectionSettings& settings)
    -> PatternSymmetryIndicator {
    PatternSymmetryIndicator indicator = PatternSymmetryIndicator::oblique;

    if (observation.third_radius > 0.0 &&
        std::abs(observation.first_radius / observation.third_radius - 1.0) <
            settings.equal_length_relative_tolerance) {
        indicator = PatternSymmetryIndicator::equal_first_third;
    }
    if (observation.second_radius > 0.0 &&
        std::abs(observation.first_radius / observation.second_radius - 1.0) <
            settings.equal_length_relative_tolerance) {
        indicator = PatternSymmetryIndicator::equal_first_second;
    }
    if (observation.third_radius > 0.0 &&
        std::abs(observation.second_radius / observation.third_radius - 1.0) <
            settings.equal_length_relative_tolerance) {
        indicator = PatternSymmetryIndicator::equal_second_third;
    }
    if (std::abs(observation.angle_deg - 90.0) < settings.right_angle_tolerance_deg) {
        indicator = PatternSymmetryIndicator::rectangular;
    }

    const double radius_sum = observation.first_radius + observation.second_radius;
    if (radius_sum <= 0.0 ||
        relative_difference(observation.first_radius, observation.second_radius) >
            settings.exact_square_length_tolerance) {
        return indicator;
    }
    if (std::abs(observation.angle_deg - 90.0) < settings.exact_square_hex_tolerance_deg) {
        return PatternSymmetryIndicator::square;
    }
    if (std::abs(observation.angle_deg - 60.0) < settings.exact_square_hex_tolerance_deg) {
        return PatternSymmetryIndicator::hexagonal;
    }
    return indicator;
}

[[nodiscard]] constexpr auto search_mode_for_indicator(PatternSymmetryIndicator indicator) -> SearchMode {
    switch (indicator) {
    case PatternSymmetryIndicator::oblique:
        return SearchMode::general;
    case PatternSymmetryIndicator::rectangular:
        return SearchMode::rectangular;
    case PatternSymmetryIndicator::square:
        return SearchMode::square;
    case PatternSymmetryIndicator::hexagonal:
        return SearchMode::hexagonal;
    case PatternSymmetryIndicator::equal_first_second:
    case PatternSymmetryIndicator::equal_first_third:
    case PatternSymmetryIndicator::equal_second_third:
        return SearchMode::centered;
    }
    return SearchMode::general;
}

[[nodiscard]] inline auto ordering_scalar(const PatternObservation& observation) -> double {
    if (observation.camera_constant <= 0.0) {
        return std::numeric_limits<double>::infinity();
    }

    const double zone_area =
        observation.first_radius * observation.second_radius *
        std::sin(piep::crystal::deg_to_rad(observation.angle_deg));
    return std::sqrt(std::max(0.0, zone_area)) / observation.camera_constant;
}

[[nodiscard]] inline auto find_pattern(const std::vector<SearchPattern>& patterns, std::size_t slot)
    -> const SearchPattern& {
    const auto iterator = std::find_if(patterns.begin(), patterns.end(), [slot](const SearchPattern& pattern) {
        return pattern.slot == slot;
    });
    return *iterator;
}

[[nodiscard]] inline auto underdetermined_axes(const PatternObservation& observation,
                                               PatternSymmetryIndicator symmetry) -> std::array<double, 2> {
    const double reciprocal_first = observation.first_radius / observation.camera_constant;
    const double reciprocal_second = observation.second_radius / observation.camera_constant;
    const double reciprocal_third = observation.third_radius / observation.camera_constant;

    switch (symmetry) {
    case PatternSymmetryIndicator::equal_first_second:
        return {
            std::sqrt(std::max(0.0, std::pow(reciprocal_first + reciprocal_second, 2.0) -
                                        reciprocal_third * reciprocal_third)),
            reciprocal_third,
        };
    case PatternSymmetryIndicator::equal_first_third:
        return {
            std::sqrt(std::max(0.0, std::pow(reciprocal_first + reciprocal_third, 2.0) -
                                        reciprocal_second * reciprocal_second)),
            reciprocal_second,
        };
    case PatternSymmetryIndicator::equal_second_third:
        return {
            std::sqrt(std::max(0.0, std::pow(reciprocal_second + reciprocal_third, 2.0) -
                                        reciprocal_first * reciprocal_first)),
            reciprocal_first,
        };
    case PatternSymmetryIndicator::rectangular:
        return {reciprocal_first, reciprocal_second};
    case PatternSymmetryIndicator::oblique:
    case PatternSymmetryIndicator::square:
    case PatternSymmetryIndicator::hexagonal:
        break;
    }
    return {reciprocal_first, reciprocal_second};
}

[[nodiscard]] inline auto is_underdetermined(const SearchPattern& reference_pattern,
                                             PatternSymmetryIndicator reference_symmetry,
                                             SearchMode reference_mode,
                                             const SearchPattern& other_pattern,
                                             PatternSymmetryIndicator other_symmetry,
                                             const ReferenceSelectionSettings& settings) -> bool {
    const auto& reference = reference_pattern.prepared.restored.observation;
    const auto& other = other_pattern.prepared.restored.observation;

    if (reference_mode == SearchMode::general) {
        const std::array<double, 3> reference_ratios {
            reference.first_radius / reference.camera_constant,
            reference.second_radius / reference.camera_constant,
            reference.third_radius / reference.camera_constant,
        };
        const std::array<double, 3> other_ratios {
            other.first_radius / other.camera_constant,
            other.second_radius / other.camera_constant,
            other.third_radius / other.camera_constant,
        };

        for (double lhs : reference_ratios) {
            for (double rhs : other_ratios) {
                if (relative_difference(lhs, rhs) < settings.underdetermined_ratio_tolerance) {
                    return true;
                }
            }
        }
        return false;
    }

    if (legacy_code(reference_symmetry) > 5 || other_symmetry == PatternSymmetryIndicator::oblique) {
        return false;
    }

    const auto reference_axes = underdetermined_axes(reference, reference_symmetry);
    const auto other_axes = underdetermined_axes(other, other_symmetry);
    return !(relative_difference(reference_axes[0], other_axes[0]) > settings.underdetermined_ratio_tolerance &&
             relative_difference(reference_axes[0], other_axes[1]) > settings.underdetermined_ratio_tolerance &&
             relative_difference(reference_axes[1], other_axes[0]) > settings.underdetermined_ratio_tolerance &&
             relative_difference(reference_axes[1], other_axes[1]) > settings.underdetermined_ratio_tolerance);
}

}  // namespace detail

[[nodiscard]] inline auto select_reference_pattern(const std::vector<SearchPattern>& patterns,
                                                   const ReferenceSelectionSettings& settings = {})
    -> ReferenceSelection {
    ReferenceSelection selection;
    selection.classifications.reserve(patterns.size());

    PatternSymmetryIndicator highest_active_symmetry = PatternSymmetryIndicator::oblique;
    double volume_sum = 0.0;
    std::size_t volume_count = 0;
    selection.minimum_estimated_volume = std::numeric_limits<double>::infinity();

    for (const auto& pattern : patterns) {
        const auto& observation = pattern.prepared.restored.observation;
        if (observation.camera_constant <= 0.0) {
            continue;
        }

        const PatternClassification classification {
            pattern.slot,
            detail::pattern_symmetry_indicator(observation, settings),
            detail::ordering_scalar(observation),
            pattern.prepared.restored.primitive_volume_estimate,
            pattern.excluded,
        };
        selection.classifications.push_back(classification);

        if (pattern.excluded) {
            ++selection.excluded_pattern_count;
            continue;
        }

        ++selection.active_pattern_count;
        highest_active_symmetry =
            static_cast<PatternSymmetryIndicator>(
                std::max(detail::legacy_code(highest_active_symmetry), detail::legacy_code(classification.symmetry)));

        if (classification.primitive_volume_estimate >= 0.01 &&
            observation.laue_zone_one_minus_zero_input >= 0.0) {
            selection.minimum_estimated_volume =
                std::min(selection.minimum_estimated_volume, classification.primitive_volume_estimate);
            selection.maximum_estimated_volume =
                std::max(selection.maximum_estimated_volume, classification.primitive_volume_estimate);
            volume_sum += classification.primitive_volume_estimate;
            ++volume_count;
        }
    }

    if (volume_count == 0) {
        selection.minimum_estimated_volume = 0.0;
        selection.maximum_estimated_volume = 0.0;
    }
    else {
        selection.mean_estimated_volume = volume_sum / static_cast<double>(volume_count);
    }

    std::vector<PatternClassification> active_sorted;
    active_sorted.reserve(selection.active_pattern_count);
    for (const auto& classification : selection.classifications) {
        if (!classification.excluded) {
            active_sorted.push_back(classification);
        }
    }

    std::stable_sort(active_sorted.begin(),
                     active_sorted.end(),
                     [](const PatternClassification& lhs, const PatternClassification& rhs) {
                         return lhs.ordering_scalar < rhs.ordering_scalar;
                     });
    for (const auto& classification : active_sorted) {
        selection.sorted_active_slots.push_back(classification.slot);
    }

    if (selection.active_pattern_count < 2 || active_sorted.size() < 2) {
        return selection;
    }

    std::size_t reference_index = 0;
    SearchMode search_mode = detail::search_mode_for_indicator(active_sorted.front().symmetry);
    if (settings.force_full_grid) {
        search_mode = SearchMode::general;
    }
    else if (detail::legacy_code(search_mode) <= 5 &&
             !(detail::legacy_code(search_mode) > 0 && detail::legacy_code(highest_active_symmetry) < 6)) {
        for (std::size_t index = 1; index < active_sorted.size(); ++index) {
            const PatternSymmetryIndicator candidate_symmetry = active_sorted[index].symmetry;
            if (candidate_symmetry == PatternSymmetryIndicator::oblique) {
                continue;
            }
            if (detail::legacy_code(highest_active_symmetry) > 5 &&
                detail::legacy_code(candidate_symmetry) < 6) {
                continue;
            }
            reference_index = index;
            search_mode = detail::search_mode_for_indicator(candidate_symmetry);
            break;
        }
    }

    const PatternClassification& reference_classification = active_sorted[reference_index];
    selection.reference_slot = reference_classification.slot;
    selection.reference_symmetry = reference_classification.symmetry;
    selection.search_mode = settings.force_full_grid ? SearchMode::general : search_mode;
    selection.status = ReferenceSelectionStatus::ok;

    const SearchPattern& reference_pattern = detail::find_pattern(patterns, selection.reference_slot);
    const auto& reference_observation = reference_pattern.prepared.restored.observation;
    selection.average_reference_sigma =
        0.5 * (reference_observation.first_radius_sigma + reference_observation.second_radius_sigma);
    selection.relative_reference_sigma =
        reference_observation.camera_constant > 0.0 ? selection.average_reference_sigma / reference_observation.camera_constant
                                                    : 0.0;
    if (!settings.force_full_grid && settings.wall_sigma_multiplier > 0.0) {
        selection.wall_thickness = settings.wall_sigma_multiplier * selection.relative_reference_sigma;
    }

    for (std::size_t index = 0; index < active_sorted.size(); ++index) {
        if (index != reference_index) {
            selection.active_sequence_slots.push_back(active_sorted[index].slot);
        }
    }

    if (active_sorted.size() == 2) {
        const SearchPattern& other_pattern = detail::find_pattern(patterns, selection.active_sequence_slots.front());
        selection.underdetermined =
            detail::is_underdetermined(reference_pattern,
                                       reference_classification.symmetry,
                                       selection.search_mode,
                                       other_pattern,
                                       active_sorted[reference_index == 0 ? 1 : 0].symmetry,
                                       settings);
    }

    const auto reference_basis =
        piep::crystal::reduce_zone_basis(
            {reference_observation.first_radius, reference_observation.second_radius, reference_observation.angle_deg})
            .reduced_basis;
    for (std::size_t slot : selection.active_sequence_slots) {
        const SearchPattern& other_pattern = detail::find_pattern(patterns, slot);
        const auto& other_observation = other_pattern.prepared.restored.observation;
        const auto other_basis =
            piep::crystal::reduce_zone_basis(
                {other_observation.first_radius, other_observation.second_radius, other_observation.angle_deg})
                .reduced_basis;
        const double camera_scale = reference_observation.camera_constant / other_observation.camera_constant;
        if (std::abs(1.0 - camera_scale * other_basis.first_length / reference_basis.first_length) >
                2.0 * reference_observation.first_radius_sigma / reference_observation.first_radius ||
            std::abs(1.0 - camera_scale * other_basis.second_length / reference_basis.second_length) >
                2.0 * reference_observation.second_radius_sigma / reference_observation.second_radius ||
            std::abs(other_basis.angle_deg - reference_basis.angle_deg) > 2.0 * reference_observation.angle_sigma_deg) {
            continue;
        }
        selection.close_pattern_slots.push_back(slot);
    }

    return selection;
}

}  // namespace piep::search
