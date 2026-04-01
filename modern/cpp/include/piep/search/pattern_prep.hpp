#pragma once

#include <algorithm>
#include <array>
#include <cmath>
#include <stdexcept>
#include <string>
#include <utility>

#include "piep/crystal/cell.hpp"

namespace piep::search {

// This is the persisted 18-value sad.dat record written by PG/PS before PIEP
// mutates defaults or derives extra admissibility windows. It is deliberately
// not the transient c(15) parser buffer used by LES.
struct PatternObservation {
    std::string title {};
    double camera_constant {};
    double camera_constant_sigma {};
    double first_radius {};
    double first_radius_sigma {};
    double second_radius {};
    double second_radius_sigma {};
    double third_radius {};
    double third_radius_sigma {};
    double angle_deg {};
    double angle_sigma_deg {};
    double goniometer_alpha_deg {};
    double goniometer_beta_deg {};
    double goniometer_mode {};
    double laue_zone_zero_input {};
    double laue_zone_zero_sigma {};
    double laue_zone_one_minus_zero_input {};
    double laue_zone_one_minus_zero_sigma {};
    double high_voltage_volts {};
    double wavelength_override_angstrom {};

    [[nodiscard]] auto as_legacy_numeric_fields() const -> std::array<double, 18> {
        return {
            camera_constant,
            camera_constant_sigma,
            first_radius,
            first_radius_sigma,
            second_radius,
            second_radius_sigma,
            third_radius,
            third_radius_sigma,
            angle_deg,
            angle_sigma_deg,
            goniometer_alpha_deg,
            goniometer_beta_deg,
            goniometer_mode,
            laue_zone_zero_input,
            laue_zone_zero_sigma,
            laue_zone_one_minus_zero_input,
            laue_zone_one_minus_zero_sigma,
            high_voltage_volts,
        };
    }

    [[nodiscard]] static auto from_legacy_numeric_fields(std::string title_value,
                                                         const std::array<double, 18>& fields)
        -> PatternObservation {
        return {
            std::move(title_value),
            fields[0],
            fields[1],
            fields[2],
            fields[3],
            fields[4],
            fields[5],
            fields[6],
            fields[7],
            fields[8],
            fields[9],
            fields[10],
            fields[11],
            fields[12],
            fields[13],
            fields[14],
            fields[15],
            fields[16],
            fields[17],
        };
    }
};

// A modern caller often knows the two observed reciprocal-space vectors
// directly, without ever writing down a legacy camera constant in mm*Angstrom.
// This adapter keeps that path explicit while still producing the same typed
// PatternObservation consumed by the search preparation layer.
struct ReciprocalVectorPairObservationInput {
    std::string title {};
    std::array<double, 2> first_vector_inverse_angstrom {};
    std::array<double, 2> second_vector_inverse_angstrom {};
    double camera_constant {1.0};
    double camera_constant_sigma {};
    double first_length_sigma_inverse_angstrom {};
    double second_length_sigma_inverse_angstrom {};
    double angle_sigma_deg {2.5};
    double third_radius_sigma {};
    double high_voltage_volts {};
    double wavelength_angstrom {};
};

// Detector geometry is the most notebook-friendly entry point: pixel
// coordinates, pixel size, detector distance, and wavelength fully determine
// the camera constant and the radii/angle recorded in the SAD record.
struct DetectorGeometryObservationInput {
    std::string title {};
    std::array<double, 2> first_spot_pixels {};
    std::array<double, 2> second_spot_pixels {};
    std::array<double, 2> direct_beam_pixels {};
    double detector_distance_mm {};
    double wavelength_angstrom {};
    double pixel_size_x_mm {};
    double pixel_size_y_mm {};
    double camera_constant_sigma {};
    double radius_sigma_mm {};
    double angle_sigma_deg {2.5};
    double third_radius_sigma {};
    double high_voltage_volts {};
};

struct PatternPreparationSettings {
    double default_high_voltage_volts {};
    double default_laue_zone_zero_sigma {};
    double default_laue_zone_one_sigma {};
    double minimum_camera_lower_fraction {0.2};
    double minimum_radius_floor {0.1};
    double lower_limit_floor {0.1};
    double cosine_zero_guard {1.0e-15};
    double infinite_upper_bound {1.0e20};
};

struct TemporaryErrorSettings {
    double minimum_relative_sigma_fraction {};
    double minimum_angle_sigma_deg {};
};

// resto-derived normalization that later search code depends on even before prep1.
struct RestoredPattern {
    PatternObservation observation {};
    int rounded_high_voltage_kv {};
    double wavelength_angstrom {};
    double primitive_volume_estimate {};
    double camera_upper_squared {};
    double camera_lower_squared {};
    double laue_zone_one_lower_bound {};
    double laue_zone_one_upper_bound {};
    bool has_laue_zone_information {};
    bool laue_zone_one_is_lower_limit {};
};

// prep1 augments the restored pattern with the actual windows used by indi/eva.
struct PreparedPattern {
    RestoredPattern restored {};
    std::array<double, 2> normalized_radius_lower_bounds {};
    std::array<double, 2> normalized_radius_upper_bounds {};
    double angle_cosine {};
    double angle_cosine_upper_bound {};
    double angle_cosine_lower_bound {};
    double reflection_search_limit {};
};

[[nodiscard]] inline auto electron_wavelength_angstrom(double high_voltage_volts) -> double {
    return 12.2639 / std::sqrt(high_voltage_volts * (1.0 + 0.97845e-06 * high_voltage_volts));
}

[[nodiscard]] inline auto rounded_high_voltage_kv(double high_voltage_volts) -> int {
    return static_cast<int>(0.5 + high_voltage_volts * 0.001);
}

[[nodiscard]] inline auto reciprocal_vector_length(const std::array<double, 2>& vector_inverse_angstrom) -> double {
    return std::hypot(vector_inverse_angstrom[0], vector_inverse_angstrom[1]);
}

[[nodiscard]] inline auto reciprocal_vector_angle_deg(const std::array<double, 2>& first_vector_inverse_angstrom,
                                                      const std::array<double, 2>& second_vector_inverse_angstrom)
    -> double {
    const double first_length = reciprocal_vector_length(first_vector_inverse_angstrom);
    const double second_length = reciprocal_vector_length(second_vector_inverse_angstrom);
    const double denominator = std::max(first_length * second_length, 1.0e-12);
    const double cosine = (first_vector_inverse_angstrom[0] * second_vector_inverse_angstrom[0] +
                           first_vector_inverse_angstrom[1] * second_vector_inverse_angstrom[1]) /
                          denominator;
    return crystal::rad_to_deg(std::acos(crystal::clamp_to_acos_domain(cosine)));
}

[[nodiscard]] inline auto observation_from_reciprocal_vectors(const ReciprocalVectorPairObservationInput& input)
    -> PatternObservation {
    const double first_length = reciprocal_vector_length(input.first_vector_inverse_angstrom);
    const double second_length = reciprocal_vector_length(input.second_vector_inverse_angstrom);
    const std::array<double, 2> closing_vector {
        input.first_vector_inverse_angstrom[0] - input.second_vector_inverse_angstrom[0],
        input.first_vector_inverse_angstrom[1] - input.second_vector_inverse_angstrom[1],
    };
    const double closing_length = reciprocal_vector_length(closing_vector);

    return {
        input.title,
        input.camera_constant,
        input.camera_constant_sigma,
        input.camera_constant * first_length,
        input.camera_constant * input.first_length_sigma_inverse_angstrom,
        input.camera_constant * second_length,
        input.camera_constant * input.second_length_sigma_inverse_angstrom,
        input.camera_constant * closing_length,
        input.third_radius_sigma,
        reciprocal_vector_angle_deg(input.first_vector_inverse_angstrom, input.second_vector_inverse_angstrom),
        input.angle_sigma_deg,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        input.high_voltage_volts,
        input.wavelength_angstrom,
    };
}

[[nodiscard]] inline auto observation_from_detector_geometry(const DetectorGeometryObservationInput& input)
    -> PatternObservation {
    if (input.detector_distance_mm <= 0.0) {
        throw std::runtime_error("Detector distance must be positive");
    }
    if (input.wavelength_angstrom <= 0.0) {
        throw std::runtime_error("Wavelength must be positive");
    }
    if (input.pixel_size_x_mm <= 0.0) {
        throw std::runtime_error("Pixel size x must be positive");
    }

    const double pixel_size_y_mm = input.pixel_size_y_mm > 0.0 ? input.pixel_size_y_mm : input.pixel_size_x_mm;
    const std::array<double, 2> first_detector_mm {
        (input.first_spot_pixels[0] - input.direct_beam_pixels[0]) * input.pixel_size_x_mm,
        (input.first_spot_pixels[1] - input.direct_beam_pixels[1]) * pixel_size_y_mm,
    };
    const std::array<double, 2> second_detector_mm {
        (input.second_spot_pixels[0] - input.direct_beam_pixels[0]) * input.pixel_size_x_mm,
        (input.second_spot_pixels[1] - input.direct_beam_pixels[1]) * pixel_size_y_mm,
    };
    const double camera_constant = input.detector_distance_mm * input.wavelength_angstrom;

    return {
        input.title,
        camera_constant,
        input.camera_constant_sigma,
        std::hypot(first_detector_mm[0], first_detector_mm[1]),
        input.radius_sigma_mm,
        std::hypot(second_detector_mm[0], second_detector_mm[1]),
        input.radius_sigma_mm,
        std::hypot(first_detector_mm[0] - second_detector_mm[0], first_detector_mm[1] - second_detector_mm[1]),
        input.third_radius_sigma,
        reciprocal_vector_angle_deg(first_detector_mm, second_detector_mm),
        input.angle_sigma_deg,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        input.high_voltage_volts,
        input.wavelength_angstrom,
    };
}

// cvol stores the primitive-volume estimate vca in A-memory when Laue-zone
// radii are available. Search preparation uses that estimate only as a hint
// for suggested volume ranges, so the modern port keeps it with the restored
// pattern instead of tying it to later grid logic.
[[nodiscard]] inline auto primitive_volume_estimate(const PatternObservation& observation,
                                                    double wavelength_angstrom) -> double {
    const double laue_zone_one_difference = std::abs(observation.laue_zone_one_minus_zero_input);
    if (laue_zone_one_difference < 0.0001 || wavelength_angstrom <= 0.0) {
        return 0.0;
    }

    const double camera_constant_over_wavelength = observation.camera_constant / wavelength_angstrom;
    if (camera_constant_over_wavelength <= 0.0) {
        return 0.0;
    }

    const double zone_area =
        observation.first_radius * observation.second_radius *
        std::sin(piep::crystal::deg_to_rad(observation.angle_deg));
    if (std::abs(zone_area) < 1.0e-12) {
        return 0.0;
    }

    const double laue_zone_zero_tilt = std::atan(observation.laue_zone_zero_input / camera_constant_over_wavelength);
    const double denominator =
        zone_area * camera_constant_over_wavelength *
        (std::cos(laue_zone_zero_tilt) -
         std::cos(std::atan(laue_zone_one_difference / camera_constant_over_wavelength) + laue_zone_zero_tilt));
    if (std::abs(denominator) < 1.0e-12) {
        return 0.0;
    }

    return std::pow(observation.camera_constant, 3.0) / denominator;
}

// restore_pattern is the object-level equivalent of resto for the fields that
// matter to search preparation.
[[nodiscard]] inline auto restore_pattern(PatternObservation observation,
                                          const PatternPreparationSettings& settings) -> RestoredPattern {
    if (observation.laue_zone_zero_sigma < 0.0001) {
        observation.laue_zone_zero_sigma = settings.default_laue_zone_zero_sigma;
    }

    const bool laue_zone_one_is_lower_limit = observation.laue_zone_one_minus_zero_input < 0.0;
    const double laue_zone_one_abs = std::abs(observation.laue_zone_one_minus_zero_input);

    if (observation.laue_zone_one_minus_zero_sigma < 0.0001) {
        observation.laue_zone_one_minus_zero_sigma = settings.default_laue_zone_one_sigma;
    }
    if (laue_zone_one_is_lower_limit) {
        observation.laue_zone_one_minus_zero_sigma = 0.0;
    }

    if (observation.high_voltage_volts <= 0.0) {
        observation.high_voltage_volts = settings.default_high_voltage_volts;
    }

    const double wavelength_angstrom =
        observation.wavelength_override_angstrom > 0.0 ? observation.wavelength_override_angstrom
                                                       : electron_wavelength_angstrom(observation.high_voltage_volts);

    return {
        observation,
        rounded_high_voltage_kv(observation.high_voltage_volts),
        wavelength_angstrom,
        primitive_volume_estimate(observation, wavelength_angstrom),
        std::pow(observation.camera_constant + observation.camera_constant_sigma, 2.0),
        std::pow(std::max(settings.minimum_camera_lower_fraction * observation.camera_constant,
                          observation.camera_constant - observation.camera_constant_sigma),
                 2.0),
        std::max(settings.lower_limit_floor, laue_zone_one_abs - observation.laue_zone_one_minus_zero_sigma),
        laue_zone_one_is_lower_limit ? settings.infinite_upper_bound
                                     : laue_zone_one_abs + observation.laue_zone_one_minus_zero_sigma,
        laue_zone_one_abs > 0.0,
        laue_zone_one_is_lower_limit,
    };
}

// prep1 is ported as written: it constructs radius windows normalized by the
// camera constant and angular admissibility bounds in cosine space.
[[nodiscard]] inline auto prepare_pattern(const PatternObservation& observation,
                                          const PatternPreparationSettings& settings) -> PreparedPattern {
    const RestoredPattern restored = restore_pattern(observation, settings);

    const double angle_radians = piep::crystal::deg_to_rad(restored.observation.angle_deg);
    const double angle_sigma_radians = piep::crystal::deg_to_rad(restored.observation.angle_sigma_deg);

    double angle_cosine = std::cos(angle_radians);
    if (std::abs(angle_cosine) < settings.cosine_zero_guard) {
        angle_cosine = settings.cosine_zero_guard;
    }

    double upper_cosine = std::cos(angle_radians + angle_sigma_radians);
    double lower_cosine = std::cos(std::max(0.0, angle_radians - angle_sigma_radians));
    if (restored.observation.angle_deg + restored.observation.angle_sigma_deg >= 180.0) {
        upper_cosine = -1.0;
    }
    if (restored.observation.angle_deg < restored.observation.angle_sigma_deg) {
        lower_cosine = 1.0;
    }

    const double radius_lower_1 = std::pow(std::max(settings.minimum_radius_floor,
                                                    restored.observation.first_radius -
                                                        restored.observation.first_radius_sigma),
                                           2.0) /
                                  restored.camera_upper_squared;
    const double radius_lower_2 = std::pow(std::max(settings.minimum_radius_floor,
                                                    restored.observation.second_radius -
                                                        restored.observation.second_radius_sigma),
                                           2.0) /
                                  restored.camera_upper_squared;
    const double radius_upper_1 =
        std::pow(restored.observation.first_radius + restored.observation.first_radius_sigma, 2.0) /
        restored.camera_lower_squared;
    const double radius_upper_2 =
        std::pow(restored.observation.second_radius + restored.observation.second_radius_sigma, 2.0) /
        restored.camera_lower_squared;

    return {
        restored,
        {radius_lower_1, radius_lower_2},
        {radius_upper_1, radius_upper_2},
        angle_cosine,
        std::max(std::abs(upper_cosine), std::abs(lower_cosine)),
        upper_cosine * lower_cosine <= 0.0 ? 0.0 : std::min(std::abs(upper_cosine), std::abs(lower_cosine)),
        std::sqrt(std::max(radius_upper_1, radius_upper_2)),
    };
}

// rfo temporarily inflates or floors the sigmas in A-memory before recomputing
// the same prepared windows as prep1.
[[nodiscard]] inline auto apply_temporary_errors(PatternObservation observation,
                                                 const TemporaryErrorSettings& settings) -> PatternObservation {
    observation.camera_constant_sigma =
        std::max(observation.camera_constant_sigma, settings.minimum_relative_sigma_fraction * observation.camera_constant);
    observation.first_radius_sigma =
        std::max(observation.first_radius_sigma, settings.minimum_relative_sigma_fraction * observation.first_radius);
    observation.second_radius_sigma =
        std::max(observation.second_radius_sigma, settings.minimum_relative_sigma_fraction * observation.second_radius);
    observation.angle_sigma_deg = std::max(observation.angle_sigma_deg, settings.minimum_angle_sigma_deg);
    return observation;
}

[[nodiscard]] inline auto prepare_pattern_with_temporary_errors(
    const PatternObservation& observation,
    const PatternPreparationSettings& settings,
    const TemporaryErrorSettings& temporary_errors) -> PreparedPattern {
    return prepare_pattern(apply_temporary_errors(observation, temporary_errors), settings);
}

}  // namespace piep::search
