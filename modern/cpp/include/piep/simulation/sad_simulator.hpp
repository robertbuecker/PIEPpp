#pragma once

#include <algorithm>
#include <array>
#include <cmath>
#include <cstddef>
#include <cstdint>
#include <limits>
#include <numeric>
#include <random>
#include <sstream>
#include <stdexcept>
#include <string>
#include <tuple>
#include <vector>

#include "piep/crystal/cell.hpp"
#include "piep/crystal/reflection.hpp"
#include "piep/indexing/indexing_engine.hpp"
#include "piep/math/matrix3.hpp"
#include "piep/math/vector3.hpp"
#include "piep/search/pattern_prep.hpp"

namespace piep::simulation {

struct ZoneDirection {
    double u {};
    double v {};
    double w {};
    double target {};
    double tolerance {};

    [[nodiscard]] constexpr auto as_array() const -> std::array<double, 5> {
        return {u, v, w, target, tolerance};
    }
};

struct SpotSimulationSettings {
    char centering {'P'};
    double camera_constant {};
    double minimum_radius_mm {};
    double maximum_radius_mm {};
    bool include_friedel_mates {true};
    bool include_origin {};
    double reciprocal_length_padding_fraction {0.02};
    std::size_t maximum_spot_count {};
};

struct ZoneAxisEnumerationSettings {
    int maximum_index {3};
    bool primitive_only {true};
    bool canonical_half_space_only {true};
    std::size_t maximum_zone_count {};
};

struct SimulatedSpot {
    crystal::MillerIndex hkl {};
    math::Vector3 reciprocal_vector_crystal {};
    math::Vector3 detector_vector_crystal {};
    std::array<double, 2> detector_coordinates_mm {};
    double reciprocal_length {};
    double radius_mm {};
    double zone_condition_value {};
    double zone_condition_residual {};
};

struct SimulatedPattern {
    std::string title {};
    ZoneDirection zone {};
    std::vector<SimulatedSpot> spots {};
};

struct BasisPairSelectionSettings {
    double minimum_angle_deg {5.0};
    double maximum_angle_deg {175.0};
    int maximum_zone_multiplicity {1};
};

struct BasisPairSelection {
    std::size_t first_spot_index {};
    std::size_t second_spot_index {};
    crystal::MillerIndex first_hkl {};
    crystal::MillerIndex second_hkl {};
    crystal::MillerIndex zone_axis {};
    int zone_multiplicity {1};
    crystal::ZoneBasisObservation ideal_basis {};
};

struct ObservationNoiseSettings {
    double positional_sigma_mm {};
    double reported_radius_sigma_mm {};
    double reported_angle_sigma_deg {2.5};
    double camera_constant_sigma {};
    double high_voltage_volts {};
    std::uint64_t seed {};
};

struct SimulatedObservation {
    std::string title {};
    search::PatternObservation observation {};
    BasisPairSelection pair_selection {};
    std::array<double, 2> first_detector_coordinates_mm {};
    std::array<double, 2> second_detector_coordinates_mm {};
};

struct ObservationEnsembleResult {
    std::vector<SimulatedPattern> patterns {};
    std::vector<SimulatedObservation> observations {};
    std::vector<ZoneDirection> skipped_zones {};
};

namespace detail {

[[nodiscard]] inline auto normalized(const math::Vector3& vector) -> math::Vector3 {
    const double length = math::norm(vector);
    if (length <= 1.0e-12) {
        throw std::runtime_error("Vector cannot be normalized");
    }
    return vector / length;
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

[[nodiscard]] inline auto normalize_axis(const crystal::MillerIndex& axis) -> crystal::MillerIndex {
    const int divisor = gcd3(axis.h, axis.k, axis.l);
    return {axis.h / divisor, axis.k / divisor, axis.l / divisor};
}

[[nodiscard]] inline auto canonical_half_space(const crystal::MillerIndex& axis) -> crystal::MillerIndex {
    crystal::MillerIndex normalized_axis = normalize_axis(axis);
    for (const int component : {normalized_axis.h, normalized_axis.k, normalized_axis.l}) {
        if (component > 0) {
            return normalized_axis;
        }
        if (component < 0) {
            return {-normalized_axis.h, -normalized_axis.k, -normalized_axis.l};
        }
    }
    return normalized_axis;
}

[[nodiscard]] inline auto reciprocal_orthogonalization(const crystal::CellParameters& cell)
    -> crystal::OrthogonalizationCoefficients {
    const crystal::CellMetric metric = crystal::to_metric(cell);
    const double volume = crystal::direct_volume(metric);
    return crystal::orth(crystal::reciprocal_metric(metric), metric, volume).reciprocal;
}

[[nodiscard]] inline auto direct_orthogonalization(const crystal::CellParameters& cell)
    -> crystal::OrthogonalizationCoefficients {
    const crystal::CellMetric metric = crystal::to_metric(cell);
    const double volume = crystal::direct_volume(metric);
    return crystal::orth(crystal::reciprocal_metric(metric), metric, volume).direct;
}

[[nodiscard]] inline auto reciprocal_vector_crystal(const crystal::OrthogonalizationCoefficients& reciprocal,
                                                    const crystal::MillerIndex& hkl) -> math::Vector3 {
    return indexing::detail::orthogonal_vector(reciprocal, hkl);
}

[[nodiscard]] inline auto direct_vector_crystal(const crystal::OrthogonalizationCoefficients& direct,
                                                const ZoneDirection& zone) -> math::Vector3 {
    const math::Matrix3 coordinates = math::Matrix3::from_columns({zone.u, zone.v, zone.w}, {0.0, 0.0, 0.0}, {0.0, 0.0, 0.0});
    return crystal::trd(coordinates, direct).column(0);
}

[[nodiscard]] inline auto detector_basis_from_zone(const crystal::CellParameters& cell, const ZoneDirection& zone)
    -> math::Matrix3 {
    const math::Vector3 beam = normalized(direct_vector_crystal(direct_orthogonalization(cell), zone));
    const math::Vector3 reference = std::abs(beam.z) < 0.9 ? math::Vector3 {0.0, 0.0, 1.0}
                                                           : math::Vector3 {0.0, 1.0, 0.0};
    const math::Vector3 detector_x = normalized(math::cross(reference, beam));
    const math::Vector3 detector_y = math::cross(beam, detector_x);

    return math::Matrix3({{
        {detector_x.x, detector_x.y, detector_x.z},
        {detector_y.x, detector_y.y, detector_y.z},
        {beam.x, beam.y, beam.z},
    }});
}

[[nodiscard]] inline auto reciprocal_length_limit(const SpotSimulationSettings& settings) -> double {
    if (settings.camera_constant <= 0.0) {
        throw std::runtime_error("Camera constant must be positive");
    }
    if (settings.maximum_radius_mm <= 0.0) {
        throw std::runtime_error("Maximum radius must be positive");
    }
    return settings.maximum_radius_mm / settings.camera_constant;
}

[[nodiscard]] inline auto reflection_search_bounds(const crystal::CellParameters& cell,
                                                   const SpotSimulationSettings& settings) -> std::array<int, 3> {
    const double limit =
        reciprocal_length_limit(settings) * (1.0 + std::max(0.0, settings.reciprocal_length_padding_fraction));
    return {
        std::max(1, static_cast<int>(std::ceil(limit * cell.a)) + 1),
        std::max(1, static_cast<int>(std::ceil(limit * cell.b)) + 1),
        std::max(1, static_cast<int>(std::ceil(limit * cell.c)) + 1),
    };
}

[[nodiscard]] inline auto zone_condition_value(const crystal::MillerIndex& hkl, const ZoneDirection& zone) -> double {
    return static_cast<double>(hkl.h) * zone.u + static_cast<double>(hkl.k) * zone.v + static_cast<double>(hkl.l) * zone.w;
}

[[nodiscard]] inline auto radius_in_range(double radius_mm, const SpotSimulationSettings& settings) -> bool {
    return radius_mm >= settings.minimum_radius_mm && radius_mm <= settings.maximum_radius_mm;
}

[[nodiscard]] inline auto angle_between_detector_vectors(const std::array<double, 2>& first,
                                                         const std::array<double, 2>& second) -> double {
    const double first_length = std::hypot(first[0], first[1]);
    const double second_length = std::hypot(second[0], second[1]);
    const double cosine =
        (first[0] * second[0] + first[1] * second[1]) / std::max(first_length * second_length, 1.0e-12);
    return crystal::rad_to_deg(std::acos(crystal::clamp_to_acos_domain(cosine)));
}

inline void sort_spots(std::vector<SimulatedSpot>& spots) {
    std::stable_sort(spots.begin(),
                     spots.end(),
                     [](const SimulatedSpot& lhs, const SimulatedSpot& rhs) {
                         if (std::abs(lhs.radius_mm - rhs.radius_mm) > 1.0e-9) {
                             return lhs.radius_mm < rhs.radius_mm;
                         }
                         return lhs.hkl.as_array() < rhs.hkl.as_array();
                     });
}

[[nodiscard]] inline auto make_title_with_zone(const std::string& title_prefix,
                                               const ZoneDirection& zone,
                                               std::size_t realization_index = std::numeric_limits<std::size_t>::max())
    -> std::string {
    std::ostringstream stream;
    stream << title_prefix << " [" << zone.u << ' ' << zone.v << ' ' << zone.w << ']';
    if (zone.tolerance > 0.0) {
        stream << " +/-" << zone.tolerance;
    }
    if (realization_index != std::numeric_limits<std::size_t>::max()) {
        stream << " #" << (realization_index + 1);
    }
    return stream.str();
}

}  // namespace detail

[[nodiscard]] inline auto zone_direction_from_axis(const crystal::MillerIndex& axis, double tolerance = 0.0)
    -> ZoneDirection {
    const crystal::MillerIndex canonical_axis = detail::canonical_half_space(axis);
    return {
        static_cast<double>(canonical_axis.h),
        static_cast<double>(canonical_axis.k),
        static_cast<double>(canonical_axis.l),
        0.0,
        tolerance,
    };
}

// Exact integer zones are still useful for regression fixtures, so the
// simulator keeps a small helper that enumerates canonical primitive axes.
[[nodiscard]] inline auto enumerate_zone_axes(const ZoneAxisEnumerationSettings& settings)
    -> std::vector<crystal::MillerIndex> {
    if (settings.maximum_index < 1) {
        return {};
    }

    std::vector<crystal::MillerIndex> axes;
    for (int h = -settings.maximum_index; h <= settings.maximum_index; ++h) {
        for (int k = -settings.maximum_index; k <= settings.maximum_index; ++k) {
            for (int l = -settings.maximum_index; l <= settings.maximum_index; ++l) {
                if (h == 0 && k == 0 && l == 0) {
                    continue;
                }

                crystal::MillerIndex axis {h, k, l};
                if (settings.primitive_only) {
                    axis = detail::normalize_axis(axis);
                }
                if (settings.canonical_half_space_only) {
                    axis = detail::canonical_half_space(axis);
                }

                const bool already_present = std::find_if(
                    axes.begin(),
                    axes.end(),
                    [&](const crystal::MillerIndex& existing) {
                        return existing.h == axis.h && existing.k == axis.k && existing.l == axis.l;
                    }) != axes.end();
                if (already_present) {
                    continue;
                }

                axes.push_back(axis);
                if (settings.maximum_zone_count > 0 && axes.size() >= settings.maximum_zone_count) {
                    return axes;
                }
            }
        }
    }

    std::stable_sort(axes.begin(),
                     axes.end(),
                     [](const crystal::MillerIndex& lhs, const crystal::MillerIndex& rhs) {
                         const auto lhs_key = std::tuple {std::abs(lhs.h) + std::abs(lhs.k) + std::abs(lhs.l),
                                                          std::abs(lhs.h),
                                                          std::abs(lhs.k),
                                                          std::abs(lhs.l),
                                                          lhs.h,
                                                          lhs.k,
                                                          lhs.l};
                         const auto rhs_key = std::tuple {std::abs(rhs.h) + std::abs(rhs.k) + std::abs(rhs.l),
                                                          std::abs(rhs.h),
                                                          std::abs(rhs.k),
                                                          std::abs(rhs.l),
                                                          rhs.h,
                                                          rhs.k,
                                                          rhs.l};
                         return lhs_key < rhs_key;
                     });
    return axes;
}

// This forward model is intentionally narrow: select reflections by a
// user-specified `u, v, w` direction and a residual window on the zone
// condition. Integer zones use `target = 0, tolerance = 0`; approximate
// ensembles can widen that window or perturb the direction itself.
[[nodiscard]] inline auto simulate_zone_pattern(const std::string& title,
                                                const crystal::CellParameters& direct_cell,
                                                const ZoneDirection& zone,
                                                const SpotSimulationSettings& settings) -> SimulatedPattern {
    if (std::abs(zone.u) < 1.0e-12 && std::abs(zone.v) < 1.0e-12 && std::abs(zone.w) < 1.0e-12) {
        throw std::runtime_error("Zone direction must be non-zero");
    }

    SimulatedPattern pattern;
    pattern.title = title;
    pattern.zone = zone;

    const auto reciprocal = detail::reciprocal_orthogonalization(direct_cell);
    const auto detector_basis = detail::detector_basis_from_zone(direct_cell, zone);
    const auto bounds = detail::reflection_search_bounds(direct_cell, settings);

    for (int h = -bounds[0]; h <= bounds[0]; ++h) {
        for (int k = -bounds[1]; k <= bounds[1]; ++k) {
            for (int l = -bounds[2]; l <= bounds[2]; ++l) {
                if (!settings.include_origin && h == 0 && k == 0 && l == 0) {
                    continue;
                }

                const crystal::MillerIndex hkl {h, k, l};
                if (!settings.include_friedel_mates) {
                    const crystal::MillerIndex canonical_hkl = detail::canonical_half_space(hkl);
                    if (canonical_hkl.h != hkl.h || canonical_hkl.k != hkl.k || canonical_hkl.l != hkl.l) {
                        continue;
                    }
                }
                if (!indexing::detail::is_reflection_allowed(settings.centering, hkl)) {
                    continue;
                }

                const double condition_value = detail::zone_condition_value(hkl, zone);
                const double condition_residual = std::abs(condition_value - zone.target);
                if (condition_residual > zone.tolerance) {
                    continue;
                }

                const math::Vector3 reciprocal_vector = detail::reciprocal_vector_crystal(reciprocal, hkl);
                const math::Vector3 detector_vector = math::multiply(detector_basis, reciprocal_vector);
                const std::array<double, 2> detector_coordinates {
                    settings.camera_constant * detector_vector.x,
                    settings.camera_constant * detector_vector.y,
                };
                const double radius_mm = std::hypot(detector_coordinates[0], detector_coordinates[1]);
                if (!detail::radius_in_range(radius_mm, settings)) {
                    continue;
                }

                pattern.spots.push_back({
                    hkl,
                    reciprocal_vector,
                    detector_vector,
                    detector_coordinates,
                    math::norm(reciprocal_vector),
                    radius_mm,
                    condition_value,
                    condition_residual,
                });
            }
        }
    }

    detail::sort_spots(pattern.spots);
    if (settings.maximum_spot_count > 0 && pattern.spots.size() > settings.maximum_spot_count) {
        pattern.spots.resize(settings.maximum_spot_count);
    }
    return pattern;
}

// A deterministic default pair is enough for synthetic regression cases. The
// policy below chooses the shortest admissible literal pair rather than trying
// to optimize a more elaborate reduced-basis criterion.
[[nodiscard]] inline auto select_default_basis_pair(const SimulatedPattern& pattern,
                                                    char centering,
                                                    const BasisPairSelectionSettings& settings = {})
    -> BasisPairSelection {
    bool found = false;
    BasisPairSelection best_selection;
    auto best_key = std::tuple {std::numeric_limits<int>::max(),
                                std::numeric_limits<double>::infinity(),
                                std::numeric_limits<double>::infinity(),
                                std::numeric_limits<double>::infinity(),
                                std::numeric_limits<std::size_t>::max(),
                                std::numeric_limits<std::size_t>::max()};

    for (std::size_t first_index = 0; first_index < pattern.spots.size(); ++first_index) {
        for (std::size_t second_index = first_index + 1; second_index < pattern.spots.size(); ++second_index) {
            const SimulatedSpot& first = pattern.spots[first_index];
            const SimulatedSpot& second = pattern.spots[second_index];
            const double angle_deg =
                detail::angle_between_detector_vectors(first.detector_coordinates_mm, second.detector_coordinates_mm);
            if (angle_deg < settings.minimum_angle_deg || angle_deg > settings.maximum_angle_deg) {
                continue;
            }

            const int multiplicity = indexing::detail::zone_multiplicity(first.hkl, second.hkl, centering);
            if (settings.maximum_zone_multiplicity > 0 && multiplicity > settings.maximum_zone_multiplicity) {
                continue;
            }

            const auto key = std::tuple {
                multiplicity,
                first.reciprocal_length,
                second.reciprocal_length,
                std::abs(angle_deg - 90.0),
                first_index,
                second_index,
            };
            if (key >= best_key) {
                continue;
            }

            best_key = key;
            best_selection = {
                first_index,
                second_index,
                first.hkl,
                second.hkl,
                indexing::detail::zone_axis(first.hkl, second.hkl),
                multiplicity,
                {
                    first.reciprocal_length,
                    second.reciprocal_length,
                    angle_deg,
                },
            };
            found = true;
        }
    }

    if (!found) {
        throw std::runtime_error("No admissible basis pair found in simulated pattern");
    }
    return best_selection;
}

template <typename RandomEngine>
[[nodiscard]] inline auto simulate_observation_from_pair(const std::string& title,
                                                         const SimulatedPattern& pattern,
                                                         const BasisPairSelection& selection,
                                                         const ObservationNoiseSettings& noise,
                                                         RandomEngine& engine) -> SimulatedObservation {
    if (selection.first_spot_index >= pattern.spots.size() || selection.second_spot_index >= pattern.spots.size()) {
        throw std::runtime_error("Basis-pair indices are out of range");
    }

    const SimulatedSpot& first = pattern.spots[selection.first_spot_index];
    const SimulatedSpot& second = pattern.spots[selection.second_spot_index];

    auto sample_zero_mean_noise = [&engine](double sigma) {
        if (sigma <= 0.0) {
            return 0.0;
        }
        std::normal_distribution<double> distribution(0.0, sigma);
        return distribution(engine);
    };

    const std::array<double, 2> first_detector = {
        first.detector_coordinates_mm[0] + sample_zero_mean_noise(noise.positional_sigma_mm),
        first.detector_coordinates_mm[1] + sample_zero_mean_noise(noise.positional_sigma_mm),
    };
    const std::array<double, 2> second_detector = {
        second.detector_coordinates_mm[0] + sample_zero_mean_noise(noise.positional_sigma_mm),
        second.detector_coordinates_mm[1] + sample_zero_mean_noise(noise.positional_sigma_mm),
    };
    const std::array<double, 2> closing_detector = {
        first_detector[0] - second_detector[0],
        first_detector[1] - second_detector[1],
    };

    const double first_radius = std::hypot(first_detector[0], first_detector[1]);
    const double second_radius = std::hypot(second_detector[0], second_detector[1]);
    const double third_radius = std::hypot(closing_detector[0], closing_detector[1]);
    const double angle_deg = detail::angle_between_detector_vectors(first_detector, second_detector);

    SimulatedObservation simulated;
    simulated.title = title;
    simulated.pair_selection = selection;
    simulated.first_detector_coordinates_mm = first_detector;
    simulated.second_detector_coordinates_mm = second_detector;
    simulated.observation = {
        title,
        first.radius_mm / std::max(first.reciprocal_length, 1.0e-12) + sample_zero_mean_noise(noise.camera_constant_sigma),
        noise.camera_constant_sigma,
        first_radius,
        std::max(noise.reported_radius_sigma_mm, noise.positional_sigma_mm),
        second_radius,
        std::max(noise.reported_radius_sigma_mm, noise.positional_sigma_mm),
        third_radius,
        std::max(noise.reported_radius_sigma_mm, noise.positional_sigma_mm),
        angle_deg,
        noise.reported_angle_sigma_deg,
        0.0,
        0.0,
        0.0,
        0.0,
        5.0,
        0.0,
        5.0,
        noise.high_voltage_volts,
    };
    return simulated;
}

[[nodiscard]] inline auto simulate_observation_from_pair(const std::string& title,
                                                         const SimulatedPattern& pattern,
                                                         const BasisPairSelection& selection,
                                                         const ObservationNoiseSettings& noise = {})
    -> SimulatedObservation {
    std::mt19937_64 engine(noise.seed);
    return simulate_observation_from_pair(title, pattern, selection, noise, engine);
}

// This is the batch hook for regression expansion: feed a list of exact or
// approximate zones, let the simulator generate the corresponding spot lists,
// pick a default basis pair in each one, and produce as many noisy synthetic
// observations as requested.
[[nodiscard]] inline auto simulate_zone_observation_ensemble(
    const std::string& title_prefix,
    const crystal::CellParameters& direct_cell,
    const std::vector<ZoneDirection>& zones,
    const SpotSimulationSettings& pattern_settings,
    std::size_t realizations_per_zone,
    const BasisPairSelectionSettings& pair_selection_settings = {},
    const ObservationNoiseSettings& noise = {}) -> ObservationEnsembleResult {
    ObservationEnsembleResult result;
    std::mt19937_64 engine(noise.seed);

    for (const ZoneDirection& zone : zones) {
        result.patterns.push_back(simulate_zone_pattern(detail::make_title_with_zone(title_prefix, zone),
                                                        direct_cell,
                                                        zone,
                                                        pattern_settings));
        try {
            const BasisPairSelection selection =
                select_default_basis_pair(result.patterns.back(), pattern_settings.centering, pair_selection_settings);
            for (std::size_t realization_index = 0; realization_index < realizations_per_zone; ++realization_index) {
                result.observations.push_back(simulate_observation_from_pair(
                    detail::make_title_with_zone(title_prefix, zone, realization_index),
                    result.patterns.back(),
                    selection,
                    noise,
                    engine));
            }
        }
        catch (const std::runtime_error&) {
            result.skipped_zones.push_back(zone);
        }
    }

    return result;
}

[[nodiscard]] inline auto simulate_zone_observation_ensemble(
    const std::string& title_prefix,
    const crystal::CellParameters& direct_cell,
    const std::vector<crystal::MillerIndex>& zones,
    const SpotSimulationSettings& pattern_settings,
    std::size_t realizations_per_zone,
    double tolerance = 0.0,
    const BasisPairSelectionSettings& pair_selection_settings = {},
    const ObservationNoiseSettings& noise = {}) -> ObservationEnsembleResult {
    std::vector<ZoneDirection> zone_directions;
    zone_directions.reserve(zones.size());
    for (const crystal::MillerIndex& zone : zones) {
        zone_directions.push_back(zone_direction_from_axis(zone, tolerance));
    }
    return simulate_zone_observation_ensemble(title_prefix,
                                              direct_cell,
                                              zone_directions,
                                              pattern_settings,
                                              realizations_per_zone,
                                              pair_selection_settings,
                                              noise);
}

}  // namespace piep::simulation
