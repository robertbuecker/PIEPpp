#include <array>
#include <cmath>
#include <cstdlib>
#include <iostream>
#include <stdexcept>
#include <string_view>

#include "piep/crystal/cell.hpp"
#include "piep/search/pattern_prep.hpp"

namespace {

auto approx(double lhs, double rhs, double tolerance = 1.0e-9) -> bool {
    return std::abs(lhs - rhs) <= tolerance;
}

void require(bool condition, std::string_view message) {
    if (!condition) {
        throw std::runtime_error(std::string(message));
    }
}

template <std::size_t Count>
void require_array_close(const std::array<double, Count>& actual,
                         const std::array<double, Count>& expected,
                         double tolerance,
                         std::string_view message) {
    for (std::size_t index = 0; index < Count; ++index) {
        if (!approx(actual[index], expected[index], tolerance)) {
            throw std::runtime_error(std::string(message));
        }
    }
}

auto make_observation(std::string_view title,
                      double camera_constant,
                      double camera_constant_sigma,
                      double first_radius,
                      double first_radius_sigma,
                      double second_radius,
                      double second_radius_sigma,
                      double third_radius,
                      double third_radius_sigma,
                      double angle_deg,
                      double angle_sigma_deg,
                      double goniometer_alpha_deg = 0.0,
                      double goniometer_beta_deg = 0.0,
                      double goniometer_mode = 0.0,
                      double laue_zone_zero_input = 0.0,
                      double laue_zone_zero_sigma = 0.0,
                      double laue_zone_one_minus_zero_input = 0.0,
                      double laue_zone_one_minus_zero_sigma = 0.0,
                      double high_voltage_volts = 0.0) -> piep::search::PatternObservation {
    return {
        std::string(title),
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

auto legacy_settings() -> piep::search::PatternPreparationSettings {
    return {
        200000.0,
        5.0,
        5.0,
    };
}

void test_saved_sad_record_round_trip() {
    using piep::search::PatternObservation;

    // From tests/legacy_transcripts/protocols/cupc.json pattern 1.
    const std::array<double, 18> fields {
        1100.0000,
        55.0000,
        145.0000,
        4.3500,
        293.2600,
        8.7978,
        334.5031,
        0.0000,
        93.2800,
        2.5000,
        0.00,
        0.00,
        0.00,
        0.00,
        5.00,
        0.00,
        5.00,
        300000.0,
    };

    const PatternObservation observation =
        PatternObservation::from_legacy_numeric_fields("1 CuPc pattern 19", fields);

    require(observation.title == "1 CuPc pattern 19", "record title round-trip failed");
    require_array_close(observation.as_legacy_numeric_fields(), fields, 1.0e-12, "record field order mismatch");
}

void test_restore_pattern_applies_legacy_defaults_and_lower_limits() {
    using piep::search::electron_wavelength_angstrom;
    using piep::search::restore_pattern;

    const piep::search::PatternPreparationSettings settings {
        200000.0,
        0.5,
        0.6,
    };

    const auto restored = restore_pattern(
        make_observation("lower-limit", 100.0, 10.0, 20.0, 1.0, 25.0, 2.0, 30.0, 0.0, 90.0, 5.0, 1.0, 2.0, 1.0, 0.0,
                         0.0, -3.0, 0.0, 0.0),
        settings);

    require(approx(restored.observation.laue_zone_zero_sigma, 0.5, 1.0e-12), "default Lz0 sigma failed");
    require(approx(restored.observation.laue_zone_one_minus_zero_sigma, 0.0, 1.0e-12),
            "lower-limit sigma reset failed");
    require(approx(restored.observation.high_voltage_volts, 200000.0, 1.0e-12), "default high voltage failed");
    require(restored.rounded_high_voltage_kv == 200, "high voltage rounding failed");
    require(approx(restored.wavelength_angstrom, electron_wavelength_angstrom(200000.0), 1.0e-12),
            "electron wavelength failed");
    require(approx(restored.camera_upper_squared, 12100.0, 1.0e-12), "camera upper bound failed");
    require(approx(restored.camera_lower_squared, 8100.0, 1.0e-12), "camera lower bound failed");
    require(approx(restored.laue_zone_one_lower_bound, 3.0, 1.0e-12), "lower-limit bound failed");
    require(approx(restored.laue_zone_one_upper_bound, settings.infinite_upper_bound, 1.0),
            "lower-limit upper bound failed");
    require(restored.has_laue_zone_information, "Laue-zone availability failed");
    require(restored.laue_zone_one_is_lower_limit, "Laue-zone lower-limit flag failed");
}

void test_prepare_pattern_matches_prep1_bounds() {
    using piep::crystal::deg_to_rad;
    using piep::search::prepare_pattern;

    const piep::search::PatternPreparationSettings settings {
        200000.0,
        5.0,
        5.0,
    };

    const auto prepared = prepare_pattern(
        make_observation("prep1", 100.0, 10.0, 20.0, 1.0, 25.0, 2.0, 30.0, 0.0, 90.0, 5.0, 0.0, 0.0, 0.0, 0.0, 5.0, 0.0,
                         5.0, 200000.0),
        settings);

    const double expected_radius_lower_1 = (19.0 * 19.0) / 12100.0;
    const double expected_radius_lower_2 = (23.0 * 23.0) / 12100.0;
    const double expected_radius_upper_1 = (21.0 * 21.0) / 8100.0;
    const double expected_radius_upper_2 = (27.0 * 27.0) / 8100.0;

    require_array_close(
        prepared.normalized_radius_lower_bounds,
        {expected_radius_lower_1, expected_radius_lower_2},
        1.0e-12,
        "lower radius windows failed");
    require_array_close(
        prepared.normalized_radius_upper_bounds,
        {expected_radius_upper_1, expected_radius_upper_2},
        1.0e-12,
        "upper radius windows failed");
    require(approx(prepared.angle_cosine, settings.cosine_zero_guard, 1.0e-18), "cosine zero guard failed");
    require(approx(prepared.angle_cosine_upper_bound, std::abs(std::cos(deg_to_rad(95.0))), 1.0e-12),
            "angle upper bound failed");
    require(approx(prepared.angle_cosine_lower_bound, 0.0, 1.0e-12), "angle lower bound failed");
    require(approx(prepared.reflection_search_limit, std::sqrt(expected_radius_upper_2), 1.0e-12),
            "reflection search limit failed");
}

void test_temporary_error_floor_matches_rfo() {
    using piep::search::apply_temporary_errors;
    using piep::search::prepare_pattern_with_temporary_errors;

    const auto observation =
        make_observation("rfo", 100.0, 0.5, 20.0, 0.5, 30.0, 0.5, 40.0, 0.0, 60.0, 1.0, 0.0, 0.0, 0.0, 0.0, 5.0, 0.0, 5.0,
                         200000.0);
    const piep::search::TemporaryErrorSettings temporary_errors {
        0.1,
        2.5,
    };

    const auto inflated = apply_temporary_errors(observation, temporary_errors);
    require(approx(inflated.camera_constant_sigma, 10.0, 1.0e-12), "camera sigma floor failed");
    require(approx(inflated.first_radius_sigma, 2.0, 1.0e-12), "first radius sigma floor failed");
    require(approx(inflated.second_radius_sigma, 3.0, 1.0e-12), "second radius sigma floor failed");
    require(approx(inflated.angle_sigma_deg, 2.5, 1.0e-12), "angle sigma floor failed");

    const auto prepared =
        prepare_pattern_with_temporary_errors(observation, legacy_settings(), temporary_errors);
    require(approx(prepared.restored.camera_upper_squared, 12100.0, 1.0e-12),
            "temporary-error camera upper bound failed");
    require(approx(prepared.restored.camera_lower_squared, 8100.0, 1.0e-12),
            "temporary-error camera lower bound failed");
}

void test_reciprocal_vector_factory_preserves_metric_geometry() {
    const auto observation = piep::search::observation_from_reciprocal_vectors({
        "reciprocal vectors",
        {0.10, 0.00},
        {0.00, 0.20},
        1.0,
        0.02,
        0.003,
        0.004,
        1.5,
        0.0,
        200000.0,
        0.0251,
    });

    require(approx(observation.camera_constant, 1.0, 1.0e-12), "reciprocal-vector camera constant failed");
    require(approx(observation.camera_constant_sigma, 0.02, 1.0e-12), "reciprocal-vector camera sigma failed");
    require(approx(observation.first_radius, 0.10, 1.0e-12), "reciprocal-vector first radius failed");
    require(approx(observation.first_radius_sigma, 0.003, 1.0e-12), "reciprocal-vector first sigma failed");
    require(approx(observation.second_radius, 0.20, 1.0e-12), "reciprocal-vector second radius failed");
    require(approx(observation.second_radius_sigma, 0.004, 1.0e-12), "reciprocal-vector second sigma failed");
    require(approx(observation.third_radius, std::sqrt(0.05), 1.0e-12), "reciprocal-vector closing radius failed");
    require(approx(observation.angle_deg, 90.0, 1.0e-12), "reciprocal-vector angle failed");

    const auto restored = piep::search::restore_pattern(observation, legacy_settings());
    require(approx(restored.wavelength_angstrom, 0.0251, 1.0e-12), "reciprocal-vector wavelength override failed");
}

void test_detector_geometry_factory_matches_expected_camera_geometry() {
    const auto observation = piep::search::observation_from_detector_geometry({
        "detector geometry",
        {100.0, 0.0},
        {0.0, 100.0},
        {0.0, 0.0},
        1000.0,
        0.0250,
        0.1,
        0.1,
        0.5,
        0.2,
        2.5,
        0.0,
        200000.0,
    });

    require(approx(observation.camera_constant, 25.0, 1.0e-12), "detector camera constant failed");
    require(approx(observation.camera_constant_sigma, 0.5, 1.0e-12), "detector camera sigma failed");
    require(approx(observation.first_radius, 10.0, 1.0e-12), "detector first radius failed");
    require(approx(observation.second_radius, 10.0, 1.0e-12), "detector second radius failed");
    require(approx(observation.third_radius, std::sqrt(200.0), 1.0e-12), "detector closing radius failed");
    require(approx(observation.first_radius_sigma, 0.2, 1.0e-12), "detector first sigma failed");
    require(approx(observation.second_radius_sigma, 0.2, 1.0e-12), "detector second sigma failed");
    require(approx(observation.angle_deg, 90.0, 1.0e-12), "detector angle failed");

    const auto restored = piep::search::restore_pattern(observation, legacy_settings());
    require(approx(restored.wavelength_angstrom, 0.0250, 1.0e-12), "detector wavelength override failed");
}

void test_real_cupc_record_prepares_consistently() {
    using piep::crystal::deg_to_rad;
    using piep::search::PatternObservation;
    using piep::search::prepare_pattern;

    const std::array<double, 18> fields {
        1100.0000,
        55.0000,
        145.0000,
        4.3500,
        293.2600,
        8.7978,
        334.5031,
        0.0000,
        93.2800,
        2.5000,
        0.00,
        0.00,
        0.00,
        0.00,
        5.00,
        0.00,
        5.00,
        300000.0,
    };

    const PatternObservation observation =
        PatternObservation::from_legacy_numeric_fields("1 CuPc pattern 19", fields);
    const auto prepared = prepare_pattern(observation, legacy_settings());

    const double expected_camera_upper = std::pow(1100.0 + 55.0, 2.0);
    const double expected_camera_lower = std::pow(std::max(0.2 * 1100.0, 1100.0 - 55.0), 2.0);
    const double expected_radius_lower_1 = std::pow(145.0 - 4.35, 2.0) / expected_camera_upper;
    const double expected_radius_upper_2 = std::pow(293.26 + 8.7978, 2.0) / expected_camera_lower;
    const double upper_cosine = std::cos(deg_to_rad(93.28 + 2.5));
    const double lower_cosine = std::cos(deg_to_rad(93.28 - 2.5));

    require(prepared.restored.rounded_high_voltage_kv == 300, "CuPc high voltage rounding failed");
    require(!prepared.restored.has_laue_zone_information, "CuPc Laue-zone flag failed");
    require(approx(prepared.restored.laue_zone_one_lower_bound, 0.1, 1.0e-12), "CuPc lower-limit floor failed");
    require(approx(prepared.normalized_radius_lower_bounds[0], expected_radius_lower_1, 1.0e-12),
            "CuPc first lower radius window failed");
    require(approx(prepared.normalized_radius_upper_bounds[1], expected_radius_upper_2, 1.0e-12),
            "CuPc second upper radius window failed");
    require(prepared.angle_cosine < 0.0, "CuPc angle cosine sign failed");
    require(approx(prepared.angle_cosine_upper_bound, std::max(std::abs(upper_cosine), std::abs(lower_cosine)), 1.0e-12),
            "CuPc angle upper admissibility failed");
    require(approx(prepared.angle_cosine_lower_bound, std::min(std::abs(upper_cosine), std::abs(lower_cosine)), 1.0e-12),
            "CuPc angle lower admissibility failed");
}

}  // namespace

int main() {
    try {
        test_saved_sad_record_round_trip();
        test_restore_pattern_applies_legacy_defaults_and_lower_limits();
        test_prepare_pattern_matches_prep1_bounds();
        test_temporary_error_floor_matches_rfo();
        test_reciprocal_vector_factory_preserves_metric_geometry();
        test_detector_geometry_factory_matches_expected_camera_geometry();
        test_real_cupc_record_prepares_consistently();

        std::cout << "All pattern preparation checks passed.\n";
        return EXIT_SUCCESS;
    }
    catch (const std::exception& error) {
        std::cerr << error.what() << '\n';
        return EXIT_FAILURE;
    }
}
