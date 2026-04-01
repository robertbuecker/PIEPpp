#pragma once

#include <array>
#include <cmath>

#include "piep/crystal/cell.hpp"
#include "piep/math/matrix3.hpp"

namespace piep::crystal {

struct MillerIndex {
    int h {};
    int k {};
    int l {};

    [[nodiscard]] constexpr auto as_array() const -> std::array<int, 3> {
        return {h, k, l};
    }
};

// This is the compact pattern description that enters PIEP before search/indexing:
// two reciprocal-space basis vectors and their included angle.
struct ZoneBasisObservation {
    double first_length {};
    double second_length {};
    double angle_deg {};

    [[nodiscard]] constexpr auto as_array() const -> std::array<double, 3> {
        return {first_length, second_length, angle_deg};
    }
};

enum class ZoneBasisReductionStatus {
    unchanged = 0,
    angle_changed = 1,
    vectors_swapped = 2,
};

struct ZoneBasisReduction {
    ZoneBasisObservation reduced_basis {};
    double closing_length {};
    ZoneBasisReductionStatus status {ZoneBasisReductionStatus::unchanged};

    [[nodiscard]] constexpr auto as_array() const -> std::array<double, 5> {
        return {
            reduced_basis.first_length,
            reduced_basis.second_length,
            reduced_basis.angle_deg,
            closing_length,
            static_cast<double>(status),
        };
    }
};

// This is a direct port of uni and is the right low-level normalization to test
// before translating full pattern preparation.
[[nodiscard]] inline auto reduce_zone_basis(const ZoneBasisObservation& observation) -> ZoneBasisReduction {
    math::Matrix3 basis {};
    basis.values[0][0] = observation.first_length;
    basis.values[0][1] = observation.second_length * std::cos(deg_to_rad(observation.angle_deg));
    basis.values[1][1] = observation.second_length * std::sin(deg_to_rad(observation.angle_deg));

    detail::mini1(basis, 0, 1);
    detail::mini1(basis, 1, 0);
    detail::mini1(basis, 0, 1);
    detail::mini1(basis, 1, 0);

    const math::Vector3 first = basis.column(0);
    const math::Vector3 second = basis.column(1);

    double first_length = math::norm(first);
    double second_length = math::norm(second);
    double angle_cosine = std::abs(math::dot(first, second) / (first_length * second_length));
    const double closing_length = std::sqrt(first_length * first_length + second_length * second_length -
                                            2.0 * first_length * second_length * angle_cosine);
    const double reduced_angle = acos_deg(angle_cosine);

    ZoneBasisReductionStatus status = ZoneBasisReductionStatus::unchanged;
    if (std::abs(observation.angle_deg - reduced_angle) > 0.01) {
        status = ZoneBasisReductionStatus::angle_changed;
    }
    else if (first_length != second_length && first_length == std::max(first_length, second_length)) {
        status = ZoneBasisReductionStatus::vectors_swapped;
    }

    const double total_length = first_length + second_length;
    first_length = std::min(first_length, second_length);
    second_length = total_length - first_length;

    return {{first_length, second_length, reduced_angle}, closing_length, status};
}

}  // namespace piep::crystal
