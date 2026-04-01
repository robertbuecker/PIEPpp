#pragma once

#include <algorithm>
#include <cmath>
#include <cstddef>
#include <limits>

#include "piep/crystal/cell.hpp"
#include "piep/math/matrix3.hpp"
#include "piep/search/reference_selection.hpp"

namespace piep::search {

enum class SearchGridStatus {
    ok,
    insufficient_patterns,
    invalid_volume_range,
    too_many_grid_points,
    maximum_p_exceeded,
};

enum class IncrementMode {
    factor_of_default,
    absolute,
};

struct IncrementSpecification {
    IncrementMode mode {IncrementMode::factor_of_default};
    double value {1.0};
};

struct VolumeRangeRequest {
    double minimum {};
    double maximum {};
};

struct SearchGridDefaults {
    double default_increment {0.035};
    double default_angular_increment {0.035};
    double relative_sigma_floor_scale {0.55};
    double angular_sigma_floor_scale {0.65};
    double maximum_p_without_warning {15.0};
    double minimum_suggested_volume {10.0};
    double grid_point_limit {1.0e7};
};

struct PlanePointCount {
    std::size_t count {};
    int nx1 {};
    int ny1 {};
    int wall_cycles {1};
    bool exceeds_limit {};
};

struct SearchGridSetup {
    SearchGridStatus status {SearchGridStatus::insufficient_patterns};
    ReferenceSelection reference {};
    VolumeRangeRequest suggested_range {};
    VolumeRangeRequest chosen_range {};
    double reduced_reference_first {};
    double reduced_reference_second {};
    double reduced_reference_angle_deg {};
    double flc {};
    double h0 {};
    double minimum_volume_floor {};
    double first_layer_height {};
    double last_layer_height {};
    double first_layer_p {};
    double last_layer_p {};
    double half_width_x {};
    double half_width_y {};
    double absolute_increment {};
    double layer_scale {1.0};
    double relative_sigma_floor {};
    double angular_sigma_floor_radians {};
    int layer_count {};
    std::size_t total_grid_points {};
    PlanePointCount first_layer_plane {};
    int minimum_wall_cycles {1};
    int maximum_wall_cycles {1};
};

namespace detail {

[[nodiscard]] inline auto legacy_rounded_positive(double value, double minimum_value = 1.0) -> int {
    return static_cast<int>(std::max(value, minimum_value));
}

[[nodiscard]] inline auto plane_point_count(double layer_height,
                                            double absolute_increment,
                                            double half_width_x,
                                            double half_width_y,
                                            SearchMode mode,
                                            PatternSymmetryIndicator reference_symmetry,
                                            double wall_thickness,
                                            double grid_point_limit) -> PlanePointCount {
    PlanePointCount count;
    if (detail::legacy_code(mode) >= 6) {
        count.count = 2;
        return count;
    }

    const double delta = absolute_increment * layer_height;
    count.nx1 = legacy_rounded_positive(half_width_x / delta + 0.5) + 1;
    count.ny1 = legacy_rounded_positive(half_width_y / delta + 0.5) + 1;
    const int nx = count.nx1 - 1;
    const int ny = count.ny1 - 1;
    const std::size_t full_count = static_cast<std::size_t>(count.nx1) * static_cast<std::size_t>(count.ny1);

    if (mode == SearchMode::general) {
        if (reference_symmetry != PatternSymmetryIndicator::oblique) {
            count.count = full_count;
        }
        else {
            count.count =
                full_count + static_cast<std::size_t>(std::max(nx - 1, 0)) * static_cast<std::size_t>(ny);
        }
        count.exceeds_limit = static_cast<double>(count.count) > grid_point_limit;
        return count;
    }

    count.wall_cycles = 1;
    if (wall_thickness > 0.0) {
        count.wall_cycles = static_cast<int>(wall_thickness / delta + 1.5);
    }
    const int mode_code = detail::legacy_code(mode);
    count.count = full_count -
                  static_cast<std::size_t>(std::max(0, count.nx1 - 2 * count.wall_cycles)) *
                      static_cast<std::size_t>(std::max(0, count.ny1 - mode_code * count.wall_cycles));
    count.exceeds_limit = static_cast<double>(count.count) > grid_point_limit;
    return count;
}

[[nodiscard]] inline auto normalize_increment(const IncrementSpecification& specification,
                                              const SearchGridDefaults& defaults) -> double {
    double control = specification.value;
    if (specification.mode == IncrementMode::absolute) {
        control = -std::abs(control);
    }

    if (std::abs(control) <= 0.0001 || control > 6.0 || control < -0.2) {
        control = 1.0;
    }
    if (control < 0.0) {
        return -control;
    }
    return control * defaults.default_increment;
}

[[nodiscard]] inline auto normalize_angular_increment(const IncrementSpecification& specification,
                                                      const SearchGridDefaults& defaults) -> double {
    double control = specification.value;
    if (specification.mode == IncrementMode::absolute) {
        control = -std::abs(control);
    }

    if (std::abs(control) <= 0.0001 || control > 6.0 || control < -0.2) {
        control = 1.0;
    }
    if (control < 0.0) {
        return -control;
    }
    return control * defaults.default_angular_increment;
}

}  // namespace detail

// This is the default, non-interactive path through ldini and npl:
// choose the reference pattern, derive the reduced in-plane basis, clamp the
// requested volume range, and count the layer-by-layer search points. Manual
// prompt overrides remain out of scope for now.
[[nodiscard]] inline auto initialize_search_grid(
    const std::vector<SearchPattern>& patterns,
    const VolumeRangeRequest& requested_range,
    const IncrementSpecification& increment = {},
    const ReferenceSelectionSettings& selection_settings = {},
    const SearchGridDefaults& defaults = {}) -> SearchGridSetup {
    SearchGridSetup setup;
    setup.reference = select_reference_pattern(patterns, selection_settings);
    if (setup.reference.status != ReferenceSelectionStatus::ok) {
        return setup;
    }

    const SearchPattern& reference_pattern = detail::find_pattern(patterns, setup.reference.reference_slot);
    const auto& reference = reference_pattern.prepared.restored.observation;

    double normalized_first = reference.first_radius / reference.camera_constant;
    double normalized_second = reference.second_radius / reference.camera_constant;
    double reduced_gamma_deg = reference.angle_deg;
    double reduced_cos_gamma = std::cos(piep::crystal::deg_to_rad(reduced_gamma_deg));
    double reduced_sin_gamma = std::sqrt(std::max(0.0, 1.0 - reduced_cos_gamma * reduced_cos_gamma));

    setup.flc = normalized_first * normalized_second * reduced_sin_gamma;
    setup.h0 = std::sqrt(setup.flc);

    piep::math::Matrix3 reduced_basis({{
        {normalized_first, normalized_second * reduced_cos_gamma, 0.0},
        {0.0, reduced_sin_gamma * normalized_second, 0.0},
        {0.0, 0.0, setup.h0},
    }});

    for (int pass = 0; pass < 2; ++pass) {
        piep::crystal::detail::mini1(reduced_basis, 0, 1);
        piep::crystal::detail::mini1(reduced_basis, 1, 0);
    }

    const piep::crystal::CellMetric reduced_metric = piep::crystal::xtodg(reduced_basis);
    reduced_cos_gamma = std::abs(reduced_metric.cos_gamma);
    reduced_gamma_deg = piep::crystal::rad_to_deg(std::acos(reduced_cos_gamma));

    const double reduced_sum = reduced_metric.a + reduced_metric.b;
    normalized_first = std::min(reduced_metric.a, reduced_metric.b);
    normalized_second = reduced_sum - normalized_first;

    if (std::abs(reduced_gamma_deg - 90.0) >= selection_settings.right_angle_tolerance_deg &&
        std::abs(normalized_first / normalized_second - 1.0) <= selection_settings.equal_length_relative_tolerance) {
        normalized_second = std::sqrt(normalized_first * normalized_second);
        normalized_first = normalized_second * std::sqrt(2.0 * (1.0 - reduced_cos_gamma));
        reduced_gamma_deg = 90.0 - 0.5 * reduced_gamma_deg;
        reduced_cos_gamma = std::cos(piep::crystal::deg_to_rad(reduced_gamma_deg));
    }

    reduced_sin_gamma = std::sqrt(std::max(0.0, 1.0 - reduced_cos_gamma * reduced_cos_gamma));
    setup.reduced_reference_first = normalized_first;
    setup.reduced_reference_second = normalized_second;
    setup.reduced_reference_angle_deg = reduced_gamma_deg;

    double minimum_reciprocal_ratio = std::numeric_limits<double>::infinity();
    for (std::size_t slot : setup.reference.active_sequence_slots) {
        const auto& observation = detail::find_pattern(patterns, slot).prepared.restored.observation;
        const double camera_lower = observation.camera_constant - observation.camera_constant_sigma;
        if (camera_lower <= 0.0) {
            continue;
        }
        minimum_reciprocal_ratio =
            std::min(minimum_reciprocal_ratio,
                     std::max(observation.first_radius + observation.first_radius_sigma,
                              observation.second_radius + observation.second_radius_sigma) /
                         camera_lower);
    }
    if (!std::isfinite(minimum_reciprocal_ratio) || minimum_reciprocal_ratio <= 0.0) {
        setup.status = SearchGridStatus::invalid_volume_range;
        return setup;
    }
    setup.minimum_volume_floor = 1.0 / (minimum_reciprocal_ratio * normalized_first * normalized_second * reduced_sin_gamma);

    if (setup.reference.maximum_estimated_volume >= 0.1 &&
        setup.reference.maximum_estimated_volume != setup.reference.minimum_estimated_volume) {
        const double volume_span =
            std::max(setup.reference.mean_estimated_volume - setup.reference.minimum_estimated_volume,
                     setup.reference.maximum_estimated_volume - setup.reference.mean_estimated_volume) +
            0.05 * setup.reference.mean_estimated_volume;
        setup.suggested_range.minimum =
            std::max(setup.reference.mean_estimated_volume - volume_span, defaults.minimum_suggested_volume);
        setup.suggested_range.maximum = setup.reference.mean_estimated_volume + volume_span;
    }

    if (requested_range.minimum <= 0.0 && requested_range.maximum < defaults.minimum_suggested_volume) {
        if (setup.suggested_range.maximum < defaults.minimum_suggested_volume) {
            setup.status = SearchGridStatus::invalid_volume_range;
            return setup;
        }
        setup.chosen_range = setup.suggested_range;
    }
    else {
        double minimum_volume = requested_range.minimum;
        double maximum_volume = requested_range.maximum;
        if (maximum_volume <= 0.0) {
            maximum_volume = minimum_volume;
        }
        minimum_volume = std::max(minimum_volume, setup.minimum_volume_floor);
        maximum_volume = std::max(maximum_volume, setup.minimum_volume_floor);
        setup.chosen_range.maximum = std::max(minimum_volume, maximum_volume);
        setup.chosen_range.minimum = minimum_volume + maximum_volume - setup.chosen_range.maximum;
    }

    const double reciprocal_minimum = 1.0 / setup.chosen_range.minimum;
    const double reciprocal_maximum = 1.0 / setup.chosen_range.maximum;
    setup.first_layer_height = reciprocal_minimum / setup.flc;
    setup.last_layer_height = reciprocal_maximum / setup.flc;
    setup.first_layer_p = setup.h0 / setup.first_layer_height;
    setup.last_layer_p = setup.h0 / setup.last_layer_height;
    if (setup.last_layer_p > defaults.maximum_p_without_warning) {
        setup.status = SearchGridStatus::maximum_p_exceeded;
        return setup;
    }

    setup.half_width_x = 0.5 * normalized_first;
    setup.half_width_y = 0.5 * normalized_second * reduced_sin_gamma;
    setup.absolute_increment = detail::normalize_increment(increment, defaults);
    setup.relative_sigma_floor = defaults.relative_sigma_floor_scale * setup.absolute_increment;
    setup.angular_sigma_floor_radians =
        defaults.angular_sigma_floor_scale * detail::normalize_angular_increment(increment, defaults) /
        piep::crystal::rad_to_deg(1.0);

    const double preliminary_scale = 1.0 - setup.absolute_increment;
    const double height_ratio = setup.last_layer_height / setup.first_layer_height;
    const int layer_steps =
        setup.chosen_range.maximum - setup.chosen_range.minimum < 0.1
            ? 0
            : detail::legacy_rounded_positive(std::log(height_ratio) / std::log(preliminary_scale) + 0.5);
    setup.layer_count = layer_steps + 1;
    setup.layer_scale = std::exp(std::log(height_ratio) / std::max(layer_steps, 1));

    setup.first_layer_plane = detail::plane_point_count(
        setup.first_layer_height,
        setup.absolute_increment,
        setup.half_width_x,
        setup.half_width_y,
        setup.reference.search_mode,
        setup.reference.reference_symmetry,
        setup.reference.wall_thickness,
        defaults.grid_point_limit);
    if (setup.first_layer_plane.exceeds_limit) {
        setup.status = SearchGridStatus::too_many_grid_points;
        return setup;
    }

    setup.minimum_wall_cycles = 10000;
    setup.maximum_wall_cycles = 0;
    double layer_height = setup.first_layer_height / setup.layer_scale;
    for (int layer = 0; layer <= layer_steps; ++layer) {
        layer_height *= setup.layer_scale;
        const PlanePointCount plane = detail::plane_point_count(
            layer_height,
            setup.absolute_increment,
            setup.half_width_x,
            setup.half_width_y,
            setup.reference.search_mode,
            setup.reference.reference_symmetry,
            setup.reference.wall_thickness,
            defaults.grid_point_limit);
        if (plane.exceeds_limit || static_cast<double>(setup.total_grid_points + plane.count) > defaults.grid_point_limit) {
            setup.status = SearchGridStatus::too_many_grid_points;
            return setup;
        }

        setup.total_grid_points += plane.count;
        if (detail::legacy_code(setup.reference.search_mode) < 6) {
            setup.minimum_wall_cycles = std::min(setup.minimum_wall_cycles, plane.wall_cycles);
            setup.maximum_wall_cycles = std::max(setup.maximum_wall_cycles, plane.wall_cycles);
            setup.minimum_wall_cycles = std::min(setup.minimum_wall_cycles, plane.nx1 / 2);
            setup.minimum_wall_cycles = std::min(setup.minimum_wall_cycles, plane.ny1 / 2);
            setup.maximum_wall_cycles = std::min(setup.maximum_wall_cycles, plane.nx1 / 2);
            setup.maximum_wall_cycles = std::min(setup.maximum_wall_cycles, plane.ny1 / 2);
        }
    }

    if (detail::legacy_code(setup.reference.search_mode) >= 6) {
        setup.minimum_wall_cycles = 1;
        setup.maximum_wall_cycles = 1;
    }

    setup.status = SearchGridStatus::ok;
    return setup;
}

}  // namespace piep::search
