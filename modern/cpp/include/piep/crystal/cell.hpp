#pragma once

#include <algorithm>
#include <array>
#include <cctype>
#include <cmath>
#include <cstddef>
#include <numbers>
#include <stdexcept>
#include <utility>

#include "piep/math/matrix3.hpp"

namespace piep::crystal {

constexpr double kRadiansPerDegree = std::numbers::pi / 180.0;
constexpr double kDegreesPerRadian = 180.0 / std::numbers::pi;
constexpr double kLegacyMetricTolerance = 1.0e-7;
constexpr double kLegacyAngleSnapToleranceDeg = 1.0e-4;

struct CellParameters {
    double a {};
    double b {};
    double c {};
    double alpha_deg {};
    double beta_deg {};
    double gamma_deg {};

    [[nodiscard]] constexpr auto as_array() const -> std::array<double, 6> {
        return {a, b, c, alpha_deg, beta_deg, gamma_deg};
    }
};

// PIEP stores cells internally as lengths plus cosines of alpha, beta, gamma.
struct CellMetric {
    double a {};
    double b {};
    double c {};
    double cos_alpha {};
    double cos_beta {};
    double cos_gamma {};

    [[nodiscard]] constexpr auto as_array() const -> std::array<double, 6> {
        return {a, b, c, cos_alpha, cos_beta, cos_gamma};
    }
};

// The six coefficients match the legacy triangular matrices used by orth/orth1.
struct OrthogonalizationCoefficients {
    std::array<double, 6> values {};

    [[nodiscard]] constexpr auto as_array() const -> std::array<double, 6> {
        return values;
    }

    [[nodiscard]] constexpr auto operator[](std::size_t index) const -> double {
        return values[index];
    }
};

struct OrthogonalizationPair {
    OrthogonalizationCoefficients reciprocal {};
    OrthogonalizationCoefficients direct {};
    double sine_gamma {};
};

struct ReciprocalCellResult {
    CellMetric metric {};
    CellParameters parameters {};
    double direct_volume {};
};

[[nodiscard]] constexpr auto deg_to_rad(double degrees) -> double {
    return degrees * kRadiansPerDegree;
}

[[nodiscard]] constexpr auto rad_to_deg(double radians) -> double {
    return radians * kDegreesPerRadian;
}

[[nodiscard]] inline auto clamp_to_acos_domain(double value) -> double {
    return std::clamp(value, -1.0, 1.0);
}

[[nodiscard]] inline auto acos_deg(double cosine_value) -> double {
    return rad_to_deg(std::acos(clamp_to_acos_domain(cosine_value)));
}

[[nodiscard]] inline auto to_metric(const CellParameters& cell) -> CellMetric {
    return {
        cell.a,
        cell.b,
        cell.c,
        std::cos(deg_to_rad(cell.alpha_deg)),
        std::cos(deg_to_rad(cell.beta_deg)),
        std::cos(deg_to_rad(cell.gamma_deg)),
    };
}

[[nodiscard]] inline auto to_parameters(const CellMetric& metric) -> CellParameters {
    return {
        metric.a,
        metric.b,
        metric.c,
        acos_deg(metric.cos_alpha),
        acos_deg(metric.cos_beta),
        acos_deg(metric.cos_gamma),
    };
}

// The direct-space volume factor appears throughout PIEP as
// 1 - ca^2 - cb^2 - cg^2 + 2 ca cb cg.
[[nodiscard]] inline auto volume_factor(const CellMetric& metric) -> double {
    return 1.0 - metric.cos_alpha * metric.cos_alpha - metric.cos_beta * metric.cos_beta -
           metric.cos_gamma * metric.cos_gamma +
           2.0 * metric.cos_alpha * metric.cos_beta * metric.cos_gamma;
}

[[nodiscard]] inline auto direct_volume(const CellMetric& metric) -> double {
    return metric.a * metric.b * metric.c * std::sqrt(std::max(0.0, volume_factor(metric)));
}

[[nodiscard]] inline auto direct_volume(const CellParameters& cell) -> double {
    return direct_volume(to_metric(cell));
}

// This is a faithful port of dire: the same formulas are used for direct->reciprocal
// and reciprocal->direct conversion because the metric relations are symmetric.
[[nodiscard]] inline auto reciprocal_from_metric(const CellMetric& direct_metric) -> ReciprocalCellResult {
    const double factor = volume_factor(direct_metric);
    if (factor <= kLegacyMetricTolerance) {
        throw std::runtime_error("Cell metric is singular");
    }

    const double volume = direct_volume(direct_metric);
    if (volume < kLegacyMetricTolerance) {
        throw std::runtime_error("Cell volume is singular");
    }

    const double inverse_volume = 1.0 / volume;
    const double sin_alpha = std::sqrt(std::max(0.0, 1.0 - direct_metric.cos_alpha * direct_metric.cos_alpha));
    const double sin_beta = std::sqrt(std::max(0.0, 1.0 - direct_metric.cos_beta * direct_metric.cos_beta));
    const double sin_gamma = std::sqrt(std::max(0.0, 1.0 - direct_metric.cos_gamma * direct_metric.cos_gamma));

    CellMetric reciprocal {
        direct_metric.b * direct_metric.c * sin_alpha * inverse_volume,
        direct_metric.c * direct_metric.a * sin_beta * inverse_volume,
        direct_metric.a * direct_metric.b * sin_gamma * inverse_volume,
        (direct_metric.cos_beta * direct_metric.cos_gamma - direct_metric.cos_alpha) / (sin_beta * sin_gamma),
        (direct_metric.cos_gamma * direct_metric.cos_alpha - direct_metric.cos_beta) / (sin_gamma * sin_alpha),
        (direct_metric.cos_alpha * direct_metric.cos_beta - direct_metric.cos_gamma) / (sin_alpha * sin_beta),
    };

    CellParameters reciprocal_parameters = to_parameters(reciprocal);

    auto snap_if_close = [&reciprocal, &reciprocal_parameters](double CellParameters::* angle_member,
                                                               double CellMetric::* cosine_member,
                                                               double target_angle,
                                                               double target_cosine) {
        if (std::abs(reciprocal_parameters.*angle_member - target_angle) <= kLegacyAngleSnapToleranceDeg) {
            reciprocal_parameters.*angle_member = target_angle;
            reciprocal.*cosine_member = target_cosine;
        }
    };

    snap_if_close(&CellParameters::alpha_deg, &CellMetric::cos_alpha, 90.0, 0.0);
    snap_if_close(&CellParameters::beta_deg, &CellMetric::cos_beta, 90.0, 0.0);
    snap_if_close(&CellParameters::gamma_deg, &CellMetric::cos_gamma, 90.0, 0.0);
    snap_if_close(&CellParameters::gamma_deg, &CellMetric::cos_gamma, 120.0, -0.5);
    snap_if_close(&CellParameters::gamma_deg, &CellMetric::cos_gamma, 60.0, 0.5);

    return {reciprocal, reciprocal_parameters, volume};
}

[[nodiscard]] inline auto reciprocal_metric(const CellMetric& direct_metric) -> CellMetric {
    return reciprocal_from_metric(direct_metric).metric;
}

[[nodiscard]] inline auto reciprocal_cell(const CellParameters& direct_cell) -> CellParameters {
    return reciprocal_from_metric(to_metric(direct_cell)).parameters;
}

[[nodiscard]] inline auto direct_cell_from_reciprocal(const CellParameters& reciprocal_cell_parameters)
    -> CellParameters {
    return reciprocal_from_metric(to_metric(reciprocal_cell_parameters)).parameters;
}

// orth1 builds the direct-space triangular coefficients used by tr/trd.
[[nodiscard]] inline auto orth1(const CellMetric& metric, double volume) -> OrthogonalizationCoefficients {
    const double sine_gamma = std::sqrt(std::max(0.0, 1.0 - metric.cos_gamma * metric.cos_gamma));
    if (sine_gamma <= 0.0) {
        throw std::runtime_error("Gamma is singular in orth1");
    }

    return {{
        metric.a,
        metric.b * metric.cos_gamma,
        metric.c * metric.cos_beta,
        metric.b * sine_gamma,
        metric.c * (metric.cos_alpha - metric.cos_beta * metric.cos_gamma) / sine_gamma,
        volume / (metric.a * metric.b * sine_gamma),
    }};
}

// orth computes the reciprocal-space matrix and the matching direct-space inverse.
[[nodiscard]] inline auto orth(const CellMetric& reciprocal_metric_value,
                               const CellMetric& direct_metric,
                               double direct_volume_value) -> OrthogonalizationPair {
    const double sine_gamma = std::sqrt(
        std::max(0.0, 1.0 - reciprocal_metric_value.cos_gamma * reciprocal_metric_value.cos_gamma));
    if (sine_gamma <= 0.0) {
        throw std::runtime_error("Gamma is singular in orth");
    }

    const OrthogonalizationCoefficients reciprocal {{
        reciprocal_metric_value.a,
        reciprocal_metric_value.b * reciprocal_metric_value.cos_gamma,
        reciprocal_metric_value.c * reciprocal_metric_value.cos_beta,
        reciprocal_metric_value.b * sine_gamma,
        reciprocal_metric_value.c *
            (reciprocal_metric_value.cos_alpha - reciprocal_metric_value.cos_beta * reciprocal_metric_value.cos_gamma) /
            sine_gamma,
        1.0 / direct_metric.c,
    }};

    const OrthogonalizationCoefficients direct {{
        1.0 / reciprocal[0],
        -reciprocal[1] * reciprocal[5] * direct_volume_value,
        (reciprocal[1] * reciprocal[4] - reciprocal[2] * reciprocal[3]) * direct_volume_value,
        reciprocal[0] * reciprocal[5] * direct_volume_value,
        -reciprocal[0] * reciprocal[4] * direct_volume_value,
        reciprocal[0] * reciprocal[3] * direct_volume_value,
    }};

    return {reciprocal, direct, sine_gamma};
}

// tr follows the reciprocal-space triangular layout from the FORTRAN code.
[[nodiscard]] inline auto tr(const math::Matrix3& coordinates, const OrthogonalizationCoefficients& coeffs)
    -> math::Matrix3 {
    math::Matrix3 cartesian {};
    for (std::size_t column = 0; column < 3; ++column) {
        cartesian.values[0][column] = coordinates.values[0][column] * coeffs[0] +
                                      coordinates.values[1][column] * coeffs[1] +
                                      coordinates.values[2][column] * coeffs[2];
        cartesian.values[1][column] =
            coordinates.values[1][column] * coeffs[3] + coordinates.values[2][column] * coeffs[4];
        cartesian.values[2][column] = coordinates.values[2][column] * coeffs[5];
    }
    return cartesian;
}

// trd uses the direct-space triangular layout and is what MV/MA applies to cells.
[[nodiscard]] inline auto trd(const math::Matrix3& coordinates, const OrthogonalizationCoefficients& coeffs)
    -> math::Matrix3 {
    math::Matrix3 cartesian {};
    for (std::size_t column = 0; column < 3; ++column) {
        cartesian.values[2][column] = coordinates.values[0][column] * coeffs[2] +
                                      coordinates.values[1][column] * coeffs[4] +
                                      coordinates.values[2][column] * coeffs[5];
        cartesian.values[1][column] =
            coordinates.values[0][column] * coeffs[1] + coordinates.values[1][column] * coeffs[3];
        cartesian.values[0][column] = coordinates.values[0][column] * coeffs[0];
    }
    return cartesian;
}

// xtodg reconstructs lengths and cosine angles from three Cartesian basis vectors.
[[nodiscard]] inline auto xtodg(const math::Matrix3& cartesian_basis) -> CellMetric {
    const math::Vector3 first = cartesian_basis.column(0);
    const math::Vector3 second = cartesian_basis.column(1);
    const math::Vector3 third = cartesian_basis.column(2);

    const double a = math::norm(first);
    const double b = math::norm(second);
    const double c = math::norm(third);

    return {
        a,
        b,
        c,
        math::dot(second, third) / (b * c),
        math::dot(first, third) / (a * c),
        math::dot(second, first) / (b * a),
    };
}

namespace detail {

[[nodiscard]] inline auto rounded_legacy_multiple(double numerator, double denominator) -> int {
    const double rounded = numerator / denominator + std::copysign(0.5, numerator);
    return static_cast<int>(rounded);
}

inline void mini1(math::Matrix3& basis, std::size_t first_column, std::size_t second_column) {
    const math::Vector3 first = basis.column(first_column);
    const math::Vector3 second = basis.column(second_column);
    const int multiple = rounded_legacy_multiple(math::dot(first, second), math::dot(second, second));
    const math::Vector3 reduced = first - static_cast<double>(multiple) * second;

    basis.values[0][first_column] = reduced.x;
    basis.values[1][first_column] = reduced.y;
    basis.values[2][first_column] = reduced.z;
}

inline void minni(math::Matrix3& basis, int passes) {
    for (int pass = 0; pass < passes; ++pass) {
        mini1(basis, 0, 1);
        mini1(basis, 1, 0);
        mini1(basis, 0, 2);
        mini1(basis, 2, 0);
        mini1(basis, 1, 2);
        mini1(basis, 2, 1);
    }
}

inline void ord(CellMetric& metric, std::size_t first_axis, std::size_t second_axis) {
    std::array<double, 3> lengths {metric.a, metric.b, metric.c};
    std::array<double, 3> cosines {metric.cos_alpha, metric.cos_beta, metric.cos_gamma};
    std::swap(lengths[first_axis], lengths[second_axis]);
    std::swap(cosines[first_axis], cosines[second_axis]);
    metric = {lengths[0], lengths[1], lengths[2], cosines[0], cosines[1], cosines[2]};
}

inline void orden(CellMetric& metric) {
    if (std::abs(metric.cos_alpha) < 1.0e-12) {
        metric.cos_alpha = 0.0;
    }
    if (std::abs(metric.cos_beta) < 1.0e-12) {
        metric.cos_beta = 0.0;
    }
    if (std::abs(metric.cos_gamma) < 1.0e-12) {
        metric.cos_gamma = 0.0;
    }

    if (metric.cos_alpha * metric.cos_beta * metric.cos_gamma > 0.0) {
        metric.cos_alpha = std::abs(metric.cos_alpha);
        metric.cos_beta = std::abs(metric.cos_beta);
        metric.cos_gamma = std::abs(metric.cos_gamma);
    }
    else {
        metric.cos_alpha = -std::abs(metric.cos_alpha);
        metric.cos_beta = -std::abs(metric.cos_beta);
        metric.cos_gamma = -std::abs(metric.cos_gamma);
    }

    if (metric.c < metric.b) {
        ord(metric, 1, 2);
    }
    if (metric.a > metric.b) {
        ord(metric, 0, 1);
        orden(metric);
    }
}

}  // namespace detail

// del1 is the legacy reduced-cell routine used before ranking and output.
[[nodiscard]] inline auto del1(const CellMetric& metric, double volume) -> CellMetric {
    const OrthogonalizationCoefficients coeffs = orth1(metric, volume);
    math::Matrix3 reduced_basis = tr(math::Matrix3::identity(), coeffs);

    for (int outer_pass = 0; outer_pass < 2; ++outer_pass) {
        detail::minni(reduced_basis, 3);

        const math::Vector3 first = reduced_basis.column(0);
        const math::Vector3 second = reduced_basis.column(1);
        const math::Vector3 third = reduced_basis.column(2);

        const std::array<math::Vector3, 4> one_one_one {
            first + second + third,
            first + second - third,
            first - second + third,
            -first + second + third,
        };

        double shortest_norm_squared = 1.0e20;
        std::size_t shortest_index = 0;
        for (std::size_t index = 0; index < one_one_one.size(); ++index) {
            const double norm_squared = math::dot(one_one_one[index], one_one_one[index]);
            if (norm_squared < shortest_norm_squared) {
                shortest_norm_squared = norm_squared;
                shortest_index = index;
            }
        }

        const double shortest_length = std::sqrt(shortest_norm_squared) + 0.0001;
        const std::array<double, 3> lengths {
            math::norm(first),
            math::norm(second),
            math::norm(third),
        };

        if (shortest_length >= lengths[0] && shortest_length >= lengths[1] && shortest_length >= lengths[2]) {
            break;
        }

        std::size_t longest_index = 0;
        if (lengths[1] > lengths[0]) {
            longest_index = 1;
        }
        if (lengths[2] > std::max(lengths[0], lengths[1])) {
            longest_index = 2;
        }

        reduced_basis.values[0][longest_index] = one_one_one[shortest_index].x;
        reduced_basis.values[1][longest_index] = one_one_one[shortest_index].y;
        reduced_basis.values[2][longest_index] = one_one_one[shortest_index].z;
    }

    CellMetric reduced_metric = xtodg(reduced_basis);
    detail::orden(reduced_metric);
    return reduced_metric;
}

// MV/MA applies an integer basis-change matrix to the current direct cell.
[[nodiscard]] inline auto apply_basis_change(const CellParameters& cell, const math::Matrix3& transform)
    -> CellParameters {
    const CellMetric metric = to_metric(cell);
    const double volume = direct_volume(metric);
    const OrthogonalizationPair pair = orth(reciprocal_metric(metric), metric, volume);
    return to_parameters(xtodg(trd(transform, pair.direct)));
}

// Centered cells need a primitive-basis conversion before Delaunay reduction.
[[nodiscard]] inline auto primitive_basis_change(char centering) -> math::Matrix3 {
    switch (std::toupper(static_cast<unsigned char>(centering))) {
    case 'P':
    case ' ':
        return math::Matrix3::identity();
    case 'A':
        return math::Matrix3::from_columns({1.0, 0.0, 0.0}, {0.0, 0.5, 0.5}, {0.0, -0.5, 0.5});
    case 'B':
        return math::Matrix3::from_columns({0.5, 0.0, 0.5}, {0.0, 1.0, 0.0}, {-0.5, 0.0, 0.5});
    case 'C':
        return math::Matrix3::from_columns({0.5, 0.5, 0.0}, {-0.5, 0.5, 0.0}, {0.0, 0.0, 1.0});
    case 'I':
        return math::Matrix3::from_columns({0.5, 0.5, -0.5}, {-0.5, 0.5, 0.5}, {0.5, -0.5, 0.5});
    case 'F':
        return math::Matrix3::from_columns({0.0, 0.5, 0.5}, {0.5, 0.0, 0.5}, {0.5, 0.5, 0.0});
    case 'R':
        return math::Matrix3::from_columns({2.0 / 3.0, 1.0 / 3.0, 1.0 / 3.0},
                                           {-1.0 / 3.0, 1.0 / 3.0, 1.0 / 3.0},
                                           {-1.0 / 3.0, -2.0 / 3.0, 1.0 / 3.0});
    default:
        throw std::runtime_error("Unsupported centering symbol");
    }
}

[[nodiscard]] inline auto to_primitive_cell(const CellParameters& cell, char centering) -> CellParameters {
    return apply_basis_change(cell, primitive_basis_change(centering));
}

[[nodiscard]] inline auto reduce_cell(const CellParameters& cell, char centering = 'P') -> CellParameters {
    const CellParameters primitive = to_primitive_cell(cell, centering);
    const CellMetric metric = to_metric(primitive);
    return to_parameters(del1(metric, direct_volume(metric)));
}

}  // namespace piep::crystal
