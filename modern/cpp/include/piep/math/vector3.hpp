#pragma once

#include <array>
#include <cmath>

namespace piep::math {

struct Vector3 {
    double x {};
    double y {};
    double z {};

    [[nodiscard]] constexpr auto as_array() const -> std::array<double, 3> {
        return {x, y, z};
    }
};

[[nodiscard]] constexpr auto operator+(const Vector3& lhs, const Vector3& rhs) -> Vector3 {
    return {lhs.x + rhs.x, lhs.y + rhs.y, lhs.z + rhs.z};
}

[[nodiscard]] constexpr auto operator-(const Vector3& lhs, const Vector3& rhs) -> Vector3 {
    return {lhs.x - rhs.x, lhs.y - rhs.y, lhs.z - rhs.z};
}

[[nodiscard]] constexpr auto operator-(const Vector3& value) -> Vector3 {
    return {-value.x, -value.y, -value.z};
}

[[nodiscard]] constexpr auto operator*(const Vector3& value, double scalar) -> Vector3 {
    return {value.x * scalar, value.y * scalar, value.z * scalar};
}

[[nodiscard]] constexpr auto operator*(double scalar, const Vector3& value) -> Vector3 {
    return value * scalar;
}

[[nodiscard]] constexpr auto operator/(const Vector3& value, double scalar) -> Vector3 {
    return {value.x / scalar, value.y / scalar, value.z / scalar};
}

[[nodiscard]] constexpr auto dot(const Vector3& lhs, const Vector3& rhs) -> double {
    return lhs.x * rhs.x + lhs.y * rhs.y + lhs.z * rhs.z;
}

[[nodiscard]] constexpr auto cross(const Vector3& lhs, const Vector3& rhs) -> Vector3 {
    return {
        lhs.y * rhs.z - lhs.z * rhs.y,
        lhs.z * rhs.x - lhs.x * rhs.z,
        lhs.x * rhs.y - lhs.y * rhs.x,
    };
}

[[nodiscard]] inline auto norm(const Vector3& value) -> double {
    return std::sqrt(dot(value, value));
}

}  // namespace piep::math
