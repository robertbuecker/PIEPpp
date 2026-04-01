#include <algorithm>
#include <cmath>
#include <cstdlib>
#include <iostream>
#include <stdexcept>
#include <string_view>
#include <vector>

#include "piep/simulation/sad_simulator.hpp"

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

auto find_spot(const piep::simulation::SimulatedPattern& pattern, const piep::crystal::MillerIndex& hkl)
    -> piep::simulation::SimulatedSpot {
    const auto iterator = std::find_if(
        pattern.spots.begin(),
        pattern.spots.end(),
        [&](const piep::simulation::SimulatedSpot& spot) { return same_index(spot.hkl, hkl); });
    if (iterator == pattern.spots.end()) {
        throw std::runtime_error("expected simulated spot not found");
    }
    return *iterator;
}

void test_exact_zone_pattern_matches_expected_cubic_geometry() {
    using piep::crystal::CellParameters;
    using piep::simulation::simulate_zone_pattern;
    using piep::simulation::zone_direction_from_axis;

    const CellParameters cell {10.0, 10.0, 10.0, 90.0, 90.0, 90.0};
    const auto pattern = simulate_zone_pattern(
        "cubic [001]",
        cell,
        zone_direction_from_axis({0, 0, 1}),
        {
            'P',
            1000.0,
            0.0,
            150.0,
            true,
        });

    require(!pattern.spots.empty(), "zone simulation returned no spots");
    const auto h100 = find_spot(pattern, {1, 0, 0});
    const auto h010 = find_spot(pattern, {0, 1, 0});
    const auto h110 = find_spot(pattern, {1, 1, 0});

    require(approx(h100.radius_mm, 100.0, 1.0e-9), "100 radius failed");
    require(approx(h100.detector_coordinates_mm[0], 100.0, 1.0e-9), "100 x failed");
    require(approx(h100.detector_coordinates_mm[1], 0.0, 1.0e-9), "100 y failed");
    require(approx(h010.radius_mm, 100.0, 1.0e-9), "010 radius failed");
    require(approx(h010.detector_coordinates_mm[0], 0.0, 1.0e-9), "010 x failed");
    require(approx(h010.detector_coordinates_mm[1], 100.0, 1.0e-9), "010 y failed");
    require(approx(h110.radius_mm, 100.0 * std::sqrt(2.0), 1.0e-9), "110 radius failed");
}

void test_fractional_zone_tolerance_selects_near_zone_reflections() {
    using piep::crystal::CellParameters;
    using piep::simulation::simulate_zone_pattern;

    const CellParameters cell {10.0, 10.0, 10.0, 90.0, 90.0, 90.0};
    const auto pattern = simulate_zone_pattern(
        "fractional zone",
        cell,
        {
            0.25,
            0.0,
            1.0,
            0.0,
            0.26,
        },
        {
            'P',
            1000.0,
            0.0,
            150.0,
            false,
        });

    require(!pattern.spots.empty(), "fractional zone simulation returned no spots");
    const auto near_zone = find_spot(pattern, {1, 0, 0});
    require(approx(near_zone.zone_condition_value, 0.25, 1.0e-12), "fractional zone condition failed");
    require(near_zone.zone_condition_residual <= 0.26, "fractional zone residual failed");

    const bool contains_far_reflection = std::find_if(
        pattern.spots.begin(),
        pattern.spots.end(),
        [](const piep::simulation::SimulatedSpot& spot) { return same_index(spot.hkl, {2, 0, 0}); }) != pattern.spots.end();
    require(!contains_far_reflection, "fractional zone admitted a far reflection");
}

void test_default_basis_pair_and_noisy_zone_ensemble() {
    using piep::crystal::CellParameters;
    using piep::simulation::select_default_basis_pair;
    using piep::simulation::simulate_zone_observation_ensemble;
    using piep::simulation::simulate_zone_pattern;
    using piep::simulation::zone_direction_from_axis;

    const CellParameters cell {10.0, 10.0, 10.0, 90.0, 90.0, 90.0};
    const auto pattern = simulate_zone_pattern(
        "cubic [001]",
        cell,
        zone_direction_from_axis({0, 0, 1}),
        {
            'P',
            1000.0,
            0.0,
            150.0,
            true,
        });
    const auto basis = select_default_basis_pair(pattern, 'P');

    require(approx(basis.ideal_basis.first_length, 0.1, 1.0e-12), "basis first length failed");
    require(approx(basis.ideal_basis.second_length, 0.1, 1.0e-12), "basis second length failed");
    require(approx(basis.ideal_basis.angle_deg, 90.0, 1.0e-9), "basis angle failed");
    require(same_index(basis.zone_axis, {0, 0, 1}), "basis zone axis failed");

    const auto ensemble = simulate_zone_observation_ensemble(
        "cubic",
        cell,
        std::vector<piep::simulation::ZoneDirection> {
            zone_direction_from_axis({0, 0, 1}),
            {
                0.1,
                1.0,
                0.0,
                0.0,
                0.11,
            },
        },
        {
            'P',
            1000.0,
            0.0,
            180.0,
            true,
        },
        2,
        {},
        {
            0.25,
            0.25,
            1.5,
            5.0,
            200000.0,
            1234,
        });

    require(ensemble.patterns.size() == 2, "ensemble pattern count failed");
    require(ensemble.observations.size() == 4, "ensemble observation count failed");
    require(ensemble.skipped_zones.empty(), "ensemble skipped zones failed");
    require(ensemble.observations.front().observation.high_voltage_volts == 200000.0,
            "ensemble high-voltage failed");
    require(ensemble.observations.front().observation.camera_constant_sigma == 5.0,
            "ensemble camera sigma failed");
    require(ensemble.observations.front().observation.first_radius_sigma == 0.25,
            "ensemble radius sigma failed");
    require(ensemble.observations.front().observation.angle_sigma_deg == 1.5, "ensemble angle sigma failed");
}

}  // namespace

int main() {
    try {
        test_exact_zone_pattern_matches_expected_cubic_geometry();
        test_fractional_zone_tolerance_selects_near_zone_reflections();
        test_default_basis_pair_and_noisy_zone_ensemble();

        std::cout << "All simulation checks passed.\n";
        return EXIT_SUCCESS;
    }
    catch (const std::exception& error) {
        std::cerr << error.what() << '\n';
        return EXIT_FAILURE;
    }
}
