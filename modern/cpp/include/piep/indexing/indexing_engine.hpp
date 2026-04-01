#pragma once

#include <algorithm>
#include <array>
#include <cctype>
#include <cmath>
#include <cstddef>
#include <limits>
#include <numeric>
#include <stdexcept>
#include <vector>

#include "piep/crystal/cell.hpp"
#include "piep/crystal/reflection.hpp"
#include "piep/math/vector3.hpp"
#include "piep/search/pattern_prep.hpp"

namespace piep::indexing {

enum class CrystalSystem {
    triclinic = 0,
    monoclinic = 1,
    hexagonal_or_trigonal = 2,
    orthorhombic = 3,
    tetragonal = 4,
    cubic = 5,
};

struct IndexingSettings {
    double weight_angle_deg {0.6};
    double weight_ratio_percent {0.8};
    double weight_camera_percent {0.3};
    std::size_t max_reflections_per_pool {1999};
    std::size_t max_stored_matches {199};
    int maximum_zone_multiplicity {2};
    bool enforce_camera_constant_window {true};
    bool enforce_laue_zone_window {};
    double size_filter_threshold {0.5};
    bool reject_zero_hk_zone_when_threshold_active {true};
};

struct ReflectionCandidate {
    crystal::MillerIndex hkl {};
    math::Vector3 orthogonal_vector {};
    double squared_length {};
};

struct ReflectionEnumerationResult {
    std::vector<ReflectionCandidate> first_pool {};
    std::vector<ReflectionCandidate> second_pool {};
    bool overflow {};
};

struct IndexingMatch {
    crystal::MillerIndex first_hkl {};
    crystal::MillerIndex second_hkl {};
    crystal::MillerIndex zone_axis {};
    int zone_multiplicity {1};
    double predicted_first_radius {};
    double predicted_second_radius {};
    double predicted_angle_deg {};
    double predicted_camera_constant {};
    double predicted_laue_zone_one_minus_zero {};
    double angle_error_deg {};
    double ratio_error_percent {};
    double camera_error_percent {};
    double figure_of_merit {std::numeric_limits<double>::infinity()};
};

struct PatternIndexingResult {
    CrystalSystem system {CrystalSystem::triclinic};
    char centering {'P'};
    ReflectionEnumerationResult enumeration {};
    std::vector<IndexingMatch> matches {};
    bool overflow {};
};

namespace detail {

struct CenteringInfo {
    int factor {1};
    std::array<std::array<int, 3>, 3> centered_to_primitive {{}};
};

[[nodiscard]] constexpr auto normalized_centering(char centering) -> char {
    return static_cast<char>(std::toupper(static_cast<unsigned char>(centering)));
}

[[nodiscard]] constexpr auto centering_info(char centering) -> CenteringInfo {
    switch (normalized_centering(centering)) {
    case 'P':
    case ' ':
        return {1, {{{1, 0, 0}, {0, 1, 0}, {0, 0, 1}}}};
    case 'A':
        return {2, {{{2, 0, 0}, {0, 1, -1}, {0, 1, 1}}}};
    case 'B':
        return {2, {{{1, 0, 1}, {0, 2, 0}, {-1, 0, 1}}}};
    case 'C':
        return {2, {{{1, -1, 0}, {1, 1, 0}, {0, 0, 2}}}};
    case 'R':
        return {3, {{{2, -1, -1}, {1, 1, -2}, {1, 1, 1}}}};
    case 'I':
        return {2, {{{-1, 1, 1}, {1, -1, 1}, {1, 1, -1}}}};
    case 'F':
        return {4, {{{0, 1, 1}, {1, 0, 1}, {1, 1, 0}}}};
    default:
        throw std::runtime_error("Unsupported centering symbol");
    }
}

[[nodiscard]] inline auto nearly_equal_ratio(double lhs, double rhs, double tolerance = 1.0e-5) -> bool {
    const double denominator = lhs + rhs;
    if (std::abs(denominator) < 1.0e-12) {
        return true;
    }
    return 2.0 * std::abs(lhs - rhs) / denominator < tolerance;
}

[[nodiscard]] inline auto rounded_legacy_integer(double value) -> int {
    return static_cast<int>(value + std::copysign(0.5, value));
}

[[nodiscard]] constexpr auto negate(const crystal::MillerIndex& index) -> crystal::MillerIndex {
    return {-index.h, -index.k, -index.l};
}

[[nodiscard]] constexpr auto cross(const crystal::MillerIndex& lhs, const crystal::MillerIndex& rhs)
    -> crystal::MillerIndex {
    return {
        lhs.k * rhs.l - lhs.l * rhs.k,
        lhs.l * rhs.h - lhs.h * rhs.l,
        lhs.h * rhs.k - lhs.k * rhs.h,
    };
}

[[nodiscard]] inline auto gcd3(int first, int second, int third) -> int {
    int divisor = 0;
    for (const int component : {first, second, third}) {
        const int absolute_component = std::abs(component);
        if (absolute_component == 0) {
            continue;
        }
        divisor = divisor == 0 ? absolute_component : std::gcd(divisor, absolute_component);
    }
    return std::max(divisor, 1);
}

[[nodiscard]] inline auto normalize_zone_axis(const crystal::MillerIndex& axis) -> crystal::MillerIndex {
    const int divisor = gcd3(axis.h, axis.k, axis.l);
    return {axis.h / divisor, axis.k / divisor, axis.l / divisor};
}

[[nodiscard]] inline auto to_primitive_reflection(const crystal::MillerIndex& centered, char centering)
    -> crystal::MillerIndex {
    const CenteringInfo info = centering_info(centering);
    const int primitive_h =
        centered.h * info.centered_to_primitive[0][0] + centered.k * info.centered_to_primitive[1][0] +
        centered.l * info.centered_to_primitive[2][0];
    const int primitive_k =
        centered.h * info.centered_to_primitive[0][1] + centered.k * info.centered_to_primitive[1][1] +
        centered.l * info.centered_to_primitive[2][1];
    const int primitive_l =
        centered.h * info.centered_to_primitive[0][2] + centered.k * info.centered_to_primitive[1][2] +
        centered.l * info.centered_to_primitive[2][2];
    return {primitive_h / info.factor, primitive_k / info.factor, primitive_l / info.factor};
}

[[nodiscard]] inline auto zone_multiplicity(const crystal::MillerIndex& first,
                                            const crystal::MillerIndex& second,
                                            char centering) -> int {
    const crystal::MillerIndex first_primitive = to_primitive_reflection(first, centering);
    const crystal::MillerIndex second_primitive = to_primitive_reflection(second, centering);
    const crystal::MillerIndex axis = cross(first_primitive, second_primitive);
    return gcd3(axis.h, axis.k, axis.l);
}

[[nodiscard]] inline auto zone_axis(const crystal::MillerIndex& first, const crystal::MillerIndex& second)
    -> crystal::MillerIndex {
    return normalize_zone_axis(cross(first, second));
}

// outp applies chgs before printing solutions, so we normalize the stored pair
// the same way. This keeps transcript-facing debug output stable even when eva
// reaches the same solution through the sign-flipped equivalent pair.
inline void canonicalize_pair_signs(crystal::MillerIndex& first, crystal::MillerIndex& second) {
    int nonzero_component_count = 0;
    int positive_component_count = 0;
    for (const int component : {first.h, first.k, first.l, second.h, second.k, second.l}) {
        if (component == 0) {
            continue;
        }
        ++nonzero_component_count;
        if (component > 0) {
            ++positive_component_count;
        }
    }

    if (positive_component_count * 2 >= nonzero_component_count + 1) {
        return;
    }

    first = negate(first);
    second = negate(second);
}

// The legacy symmetry classification used by indexing is intentionally narrow:
// it only decides which asymmetric-unit restrictions to use during reflection
// enumeration, not a full space-group model.
[[nodiscard]] inline auto classify_crystal_system(const crystal::CellParameters& cell) -> CrystalSystem {
    double a = cell.a;
    double b = cell.b;
    double c = cell.c;
    double alpha = cell.alpha_deg;
    double beta = cell.beta_deg;
    double gamma = cell.gamma_deg;

    if (nearly_equal_ratio(a, b)) {
        a = b;
    }
    if (nearly_equal_ratio(a, c)) {
        c = a;
    }

    if (std::abs(alpha - 90.0) >= 0.005) {
        if (nearly_equal_ratio(a, b) && nearly_equal_ratio(b, c) && std::abs(alpha - beta) < 0.005 &&
            std::abs(beta - gamma) < 0.005) {
            return CrystalSystem::hexagonal_or_trigonal;
        }
        return CrystalSystem::triclinic;
    }

    alpha = 90.0;
    if (std::abs(beta - 90.0) >= 0.005) {
        return std::abs(gamma - 90.0) < 0.005 ? CrystalSystem::monoclinic : CrystalSystem::triclinic;
    }

    beta = 90.0;
    if (std::abs(gamma - 90.0) < 0.005) {
        if (!nearly_equal_ratio(a, b)) {
            return CrystalSystem::orthorhombic;
        }
        if (nearly_equal_ratio(b, c)) {
            return CrystalSystem::cubic;
        }
        return CrystalSystem::tetragonal;
    }

    if (std::abs(gamma - 120.0) < 0.005 && nearly_equal_ratio(a, b)) {
        return CrystalSystem::hexagonal_or_trigonal;
    }
    return CrystalSystem::triclinic;
}

// The reflection conditions are copied directly from indi. They are centering
// conditions only; higher symmetry enters separately via the asymmetric-unit
// restrictions for the second reflection pool.
[[nodiscard]] inline auto is_reflection_allowed(char centering, const crystal::MillerIndex& hkl) -> bool {
    const char normalized = normalized_centering(centering);
    switch (normalized) {
    case 'P':
    case 'A':
    case ' ':
        return true;
    case 'B':
        return (hkl.h + hkl.l) % 2 == 0;
    case 'C':
        return (hkl.h + hkl.k) % 2 == 0;
    case 'R':
        return (-hkl.h + hkl.k + hkl.l) % 3 == 0;
    case 'I':
        return (hkl.h + hkl.k + hkl.l) % 2 == 0;
    case 'F': {
        const bool h_even = hkl.h % 2 == 0;
        const bool k_even = hkl.k % 2 == 0;
        const bool l_even = hkl.l % 2 == 0;
        return h_even == k_even && k_even == l_even;
    }
    default:
        throw std::runtime_error("Unsupported centering symbol");
    }
}

// indi stores the second reflection only inside the same asymmetric unit that
// the original indexing output uses. This removes symmetry-equivalent pairs
// before eva runs the expensive Cartesian product.
[[nodiscard]] inline auto is_second_reflection_allowed(CrystalSystem system,
                                                       char centering,
                                                       const crystal::MillerIndex& hkl) -> bool {
    const int h = hkl.h;
    const int k = hkl.k;
    const int l = hkl.l;

    if (l == 0) {
        if (system == CrystalSystem::triclinic) {
            return true;
        }
        if (k < 0 || h < 0) {
            return false;
        }
        if (system == CrystalSystem::monoclinic || system == CrystalSystem::orthorhombic) {
            return true;
        }
        if (k > h) {
            return false;
        }
        if (system != CrystalSystem::cubic) {
            return true;
        }
        return k > 0;
    }

    if (system == CrystalSystem::triclinic) {
        return true;
    }
    if (k < 0 || (l == 0 && h < 0)) {
        return false;
    }
    if (system == CrystalSystem::monoclinic) {
        return true;
    }
    if (h < 0) {
        return false;
    }
    if (system == CrystalSystem::orthorhombic || normalized_centering(centering) == 'R') {
        return true;
    }
    if (k > h) {
        return false;
    }
    if (system != CrystalSystem::cubic) {
        return true;
    }
    return l <= k;
}

[[nodiscard]] inline auto orthogonal_vector(const crystal::OrthogonalizationCoefficients& reciprocal,
                                            const crystal::MillerIndex& hkl) -> math::Vector3 {
    const double h = static_cast<double>(hkl.h);
    const double k = static_cast<double>(hkl.k);
    const double l = static_cast<double>(hkl.l);
    return {
        h * reciprocal[0] + k * reciprocal[1] + l * reciprocal[2],
        k * reciprocal[3] + l * reciprocal[4],
        l * reciprocal[5],
    };
}

[[nodiscard]] inline auto store_reflection_if_admissible(std::vector<ReflectionCandidate>& pool,
                                                         const crystal::MillerIndex& hkl,
                                                         const crystal::OrthogonalizationCoefficients& reciprocal,
                                                         double lower_bound,
                                                         double upper_bound,
                                                         std::size_t maximum_size) -> bool {
    const math::Vector3 vector = orthogonal_vector(reciprocal, hkl);
    const double squared_length = math::dot(vector, vector);
    if (squared_length < lower_bound || squared_length > upper_bound) {
        return true;
    }
    if (pool.size() >= maximum_size) {
        return false;
    }
    pool.push_back({hkl, vector, squared_length});
    return true;
}

}  // namespace detail

// This helper closes the loop for synthetic tests: it uses the same reciprocal
// geometry already present in the modern port to generate an exact SAD record
// from a known cell and a chosen reflection pair.
[[nodiscard]] inline auto simulate_pattern_observation(const std::string& title,
                                                       const crystal::CellParameters& direct_cell,
                                                       const crystal::MillerIndex& first_hkl,
                                                       const crystal::MillerIndex& second_hkl,
                                                       double camera_constant,
                                                       double camera_constant_sigma,
                                                       double angle_sigma_deg,
                                                       double high_voltage_volts = 0.0)
    -> search::PatternObservation {
    const crystal::CellMetric direct_metric = crystal::to_metric(direct_cell);
    const double direct_volume = crystal::direct_volume(direct_metric);
    const auto orthogonalization =
        crystal::orth(crystal::reciprocal_metric(direct_metric), direct_metric, direct_volume);

    const math::Vector3 first = detail::orthogonal_vector(orthogonalization.reciprocal, first_hkl);
    const math::Vector3 second = detail::orthogonal_vector(orthogonalization.reciprocal, second_hkl);
    const double first_length = math::norm(first);
    const double second_length = math::norm(second);
    const double closing_length = math::norm(first - second);
    const double angle_deg = crystal::rad_to_deg(std::acos(
        crystal::clamp_to_acos_domain(math::dot(first, second) / (first_length * second_length))));

    return {
        title,
        camera_constant,
        camera_constant_sigma,
        camera_constant * first_length,
        camera_constant_sigma * first_length,
        camera_constant * second_length,
        camera_constant_sigma * second_length,
        camera_constant * closing_length,
        0.0,
        angle_deg,
        angle_sigma_deg,
        0.0,
        0.0,
        0.0,
        0.0,
        5.0,
        0.0,
        5.0,
        high_voltage_volts,
    };
}

// This is a faithful port of indi with modern typed containers. The two output
// pools intentionally keep the same asymmetric-unit restrictions because eva's
// ranking and multiplicity checks depend on that exact enumeration surface.
[[nodiscard]] inline auto enumerate_reflections(const search::PreparedPattern& pattern,
                                                const crystal::CellParameters& direct_cell,
                                                char centering,
                                                const IndexingSettings& settings = {})
    -> ReflectionEnumerationResult {
    ReflectionEnumerationResult result;
    const crystal::CellMetric direct_metric = crystal::to_metric(direct_cell);
    const double direct_volume = crystal::direct_volume(direct_metric);
    const auto orthogonalization =
        crystal::orth(crystal::reciprocal_metric(direct_metric), direct_metric, direct_volume);
    const CrystalSystem system = detail::classify_crystal_system(direct_cell);

    const int maximum_h = static_cast<int>(pattern.reflection_search_limit * direct_cell.a);
    const int maximum_k = static_cast<int>(pattern.reflection_search_limit * direct_cell.b);
    const int maximum_l = static_cast<int>(pattern.reflection_search_limit * direct_cell.c);
    if (maximum_h == 0) {
        return result;
    }

    const auto& lower_bounds = pattern.normalized_radius_lower_bounds;
    const auto& upper_bounds = pattern.normalized_radius_upper_bounds;

    auto store_first = [&](const crystal::MillerIndex& hkl) -> bool {
        return detail::store_reflection_if_admissible(
            result.first_pool,
            hkl,
            orthogonalization.reciprocal,
            lower_bounds[0],
            upper_bounds[0],
            settings.max_reflections_per_pool);
    };
    auto store_second = [&](const crystal::MillerIndex& hkl) -> bool {
        return detail::store_reflection_if_admissible(
            result.second_pool,
            hkl,
            orthogonalization.reciprocal,
            lower_bounds[1],
            upper_bounds[1],
            settings.max_reflections_per_pool);
    };

    for (int h = 1; h <= maximum_h; ++h) {
        const crystal::MillerIndex h00 {h, 0, 0};
        if (!detail::is_reflection_allowed(centering, h00)) {
            continue;
        }
        if (!store_first(h00) || !store_second(h00)) {
            result.overflow = true;
            return result;
        }
    }

    if (maximum_k > 0) {
        for (int k = 1; k <= maximum_k; ++k) {
            for (int h = -maximum_h; h <= maximum_h; ++h) {
                const crystal::MillerIndex hk0 {h, k, 0};
                if (!detail::is_reflection_allowed(centering, hk0)) {
                    continue;
                }
                if (!store_first(hk0)) {
                    result.overflow = true;
                    return result;
                }
                if (!detail::is_second_reflection_allowed(system, centering, hk0)) {
                    continue;
                }
                if (!store_second(hk0)) {
                    result.overflow = true;
                    return result;
                }
            }
        }
    }

    if (maximum_l > 0) {
        for (int l = 1; l <= maximum_l; ++l) {
            for (int k = -maximum_k; k <= maximum_k; ++k) {
                for (int h = -maximum_h; h <= maximum_h; ++h) {
                    const crystal::MillerIndex hkl {h, k, l};
                    if (!detail::is_reflection_allowed(centering, hkl)) {
                        continue;
                    }
                    if (!store_first(hkl)) {
                        result.overflow = true;
                        return result;
                    }
                    if (!detail::is_second_reflection_allowed(system, centering, hkl)) {
                        continue;
                    }
                    if (!store_second(hkl)) {
                        result.overflow = true;
                        return result;
                    }
                }
            }
        }
    }

    return result;
}

// This ports the computational core of eva: evaluate all admissible reflection
// pairs for one pattern and sort them by the weighted FOM used throughout PIEP.
[[nodiscard]] inline auto index_prepared_pattern(const search::PreparedPattern& pattern,
                                                 const crystal::CellParameters& direct_cell,
                                                 char centering,
                                                 const IndexingSettings& settings = {}) -> PatternIndexingResult {
    PatternIndexingResult result;
    result.centering = detail::normalized_centering(centering);
    result.system = detail::classify_crystal_system(direct_cell);
    result.enumeration = enumerate_reflections(pattern, direct_cell, result.centering, settings);
    result.overflow = result.enumeration.overflow;
    if (result.overflow) {
        return result;
    }

    const crystal::CellMetric direct_metric = crystal::to_metric(direct_cell);
    const double direct_volume = crystal::direct_volume(direct_metric);
    const int centering_factor = detail::centering_info(result.centering).factor;
    const auto& observation = pattern.restored.observation;

    for (const ReflectionCandidate& second : result.enumeration.second_pool) {
        const double second_length = std::sqrt(second.squared_length);
        for (const ReflectionCandidate& first : result.enumeration.first_pool) {
            const double first_length = std::sqrt(first.squared_length);
            double cosine_angle =
                math::dot(first.orthogonal_vector, second.orthogonal_vector) / (first_length * second_length);
            cosine_angle = crystal::clamp_to_acos_domain(cosine_angle);
            const double absolute_cosine = std::abs(cosine_angle);
            if (absolute_cosine < pattern.angle_cosine_lower_bound || absolute_cosine > pattern.angle_cosine_upper_bound) {
                continue;
            }

            const double camera_constant =
                (observation.first_radius + observation.second_radius) / (first_length + second_length);
            const double predicted_first_radius = first_length * camera_constant;
            const double predicted_second_radius = second_length * camera_constant;
            if (settings.enforce_camera_constant_window &&
                (std::abs(camera_constant - observation.camera_constant) > observation.camera_constant_sigma ||
                 std::abs(predicted_first_radius - observation.first_radius) > observation.first_radius_sigma ||
                 std::abs(predicted_second_radius - observation.second_radius) > observation.second_radius_sigma)) {
                continue;
            }

            crystal::MillerIndex first_hkl = first.hkl;
            crystal::MillerIndex second_hkl = second.hkl;
            const int multiplicity = detail::zone_multiplicity(first_hkl, second_hkl, result.centering);
            if (settings.maximum_zone_multiplicity > 0 && multiplicity > settings.maximum_zone_multiplicity) {
                continue;
            }
            if (settings.size_filter_threshold >= 1.0 && settings.reject_zero_hk_zone_when_threshold_active) {
                const crystal::MillerIndex primitive_zone =
                    detail::normalize_zone_axis(detail::cross(detail::to_primitive_reflection(first_hkl, result.centering),
                                                              detail::to_primitive_reflection(second_hkl, result.centering)));
                if (primitive_zone.h == 0 && primitive_zone.k == 0) {
                    continue;
                }
            }

            double angle_deg = crystal::rad_to_deg(std::acos(cosine_angle));
            if (cosine_angle * pattern.angle_cosine < 0.0) {
                angle_deg = 180.0 - angle_deg;
                first_hkl = detail::negate(first_hkl);
            }
            detail::canonicalize_pair_signs(first_hkl, second_hkl);

            const double sine_angle = std::max(0.00001, std::sin(crystal::deg_to_rad(angle_deg)));
            const double laue_zone_difference =
                camera_constant * static_cast<double>(centering_factor) / (direct_volume * first_length * second_length * sine_angle);
            if (settings.enforce_laue_zone_window) {
                const double wavelength = pattern.restored.wavelength_angstrom;
                const double lower_bound = std::max(observation.laue_zone_zero_input - observation.laue_zone_zero_sigma, 0.0);
                const double upper_bound = observation.laue_zone_zero_input + observation.laue_zone_zero_sigma;
                const double admissible_lower =
                    wavelength > 0.0
                        ? (observation.camera_constant / wavelength) *
                              std::tan(std::acos(crystal::clamp_to_acos_domain(
                                               std::cos(std::atan(lower_bound / (observation.camera_constant / wavelength))) -
                                               laue_zone_difference * static_cast<double>(multiplicity) /
                                                   (observation.camera_constant / wavelength))) -
                                       std::atan(lower_bound / (observation.camera_constant / wavelength)))
                        : 0.0;
                const double admissible_upper =
                    wavelength > 0.0
                        ? (observation.camera_constant / wavelength) *
                              std::tan(std::acos(crystal::clamp_to_acos_domain(
                                               std::cos(std::atan(upper_bound / (observation.camera_constant / wavelength))) -
                                               laue_zone_difference * static_cast<double>(multiplicity) /
                                                   (observation.camera_constant / wavelength))) -
                                       std::atan(upper_bound / (observation.camera_constant / wavelength)))
                        : 0.0;
                if (admissible_lower < pattern.restored.laue_zone_one_lower_bound ||
                    admissible_upper > pattern.restored.laue_zone_one_upper_bound) {
                    continue;
                }
            }

            const double angle_error_deg = observation.angle_deg - angle_deg;
            const double ratio_error_percent =
                200.0 * (first_length * observation.second_radius - second_length * observation.first_radius) /
                (first_length * observation.second_radius + second_length * observation.first_radius);
            const double camera_error_percent = 100.0 * (camera_constant - observation.camera_constant) / observation.camera_constant;
            const double figure_of_merit =
                settings.weight_angle_deg * std::abs(angle_error_deg) +
                settings.weight_ratio_percent * std::abs(ratio_error_percent) +
                settings.weight_camera_percent * std::abs(camera_error_percent);

            result.matches.push_back({
                first_hkl,
                second_hkl,
                detail::zone_axis(first_hkl, second_hkl),
                multiplicity,
                predicted_first_radius,
                predicted_second_radius,
                angle_deg,
                camera_constant,
                std::clamp(laue_zone_difference, -999.99, 9999.99),
                angle_error_deg,
                ratio_error_percent,
                camera_error_percent,
                figure_of_merit,
            });
        }
    }

    std::stable_sort(result.matches.begin(),
                     result.matches.end(),
                     [](const IndexingMatch& lhs, const IndexingMatch& rhs) {
                         return lhs.figure_of_merit < rhs.figure_of_merit;
                     });
    if (result.matches.size() > settings.max_stored_matches) {
        result.matches.resize(settings.max_stored_matches);
    }
    return result;
}

[[nodiscard]] inline auto index_pattern(const search::PatternObservation& observation,
                                        const crystal::CellParameters& direct_cell,
                                        char centering,
                                        const search::PatternPreparationSettings& preparation_settings = {},
                                        const IndexingSettings& indexing_settings = {}) -> PatternIndexingResult {
    return index_prepared_pattern(search::prepare_pattern(observation, preparation_settings),
                                  direct_cell,
                                  centering,
                                  indexing_settings);
}

}  // namespace piep::indexing
