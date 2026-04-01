#pragma once

#include <array>
#include <cmath>
#include <cstddef>
#include <stdexcept>

#include "piep/math/vector3.hpp"

namespace piep::math {

struct Matrix3 {
    // Storage is row-major: values[row][column].
    std::array<std::array<double, 3>, 3> values {};

    constexpr Matrix3() = default;

    constexpr explicit Matrix3(std::array<std::array<double, 3>, 3> init) : values(init) {}

    [[nodiscard]] static constexpr auto identity() -> Matrix3 {
        return Matrix3({{{1.0, 0.0, 0.0}, {0.0, 1.0, 0.0}, {0.0, 0.0, 1.0}}});
    }

    [[nodiscard]] static constexpr auto from_columns(const Vector3& first, const Vector3& second, const Vector3& third)
        -> Matrix3 {
        return Matrix3({{{first.x, second.x, third.x}, {first.y, second.y, third.y}, {first.z, second.z, third.z}}});
    }

    [[nodiscard]] constexpr auto column(std::size_t index) const -> Vector3 {
        return {values[0][index], values[1][index], values[2][index]};
    }
};

[[nodiscard]] constexpr auto determinant(const Matrix3& matrix) -> double {
    const auto& m = matrix.values;
    return m[0][0] * (m[1][1] * m[2][2] - m[1][2] * m[2][1]) -
           m[0][1] * (m[1][0] * m[2][2] - m[1][2] * m[2][0]) +
           m[0][2] * (m[1][0] * m[2][1] - m[1][1] * m[2][0]);
}

[[nodiscard]] inline auto inverse(const Matrix3& matrix) -> Matrix3 {
    const double det = determinant(matrix);
    if (std::abs(det) < 1.0e-12) {
        throw std::runtime_error("Matrix3 is singular");
    }

    const auto& m = matrix.values;
    return Matrix3({{
        {(m[1][1] * m[2][2] - m[1][2] * m[2][1]) / det,
         (m[0][2] * m[2][1] - m[0][1] * m[2][2]) / det,
         (m[0][1] * m[1][2] - m[0][2] * m[1][1]) / det},
        {(m[1][2] * m[2][0] - m[1][0] * m[2][2]) / det,
         (m[0][0] * m[2][2] - m[0][2] * m[2][0]) / det,
         (m[0][2] * m[1][0] - m[0][0] * m[1][2]) / det},
        {(m[1][0] * m[2][1] - m[1][1] * m[2][0]) / det,
         (m[0][1] * m[2][0] - m[0][0] * m[2][1]) / det,
         (m[0][0] * m[1][1] - m[0][1] * m[1][0]) / det},
    }});
}

[[nodiscard]] constexpr auto multiply(const Matrix3& matrix, const Vector3& vector) -> Vector3 {
    const auto& m = matrix.values;
    return {
        m[0][0] * vector.x + m[0][1] * vector.y + m[0][2] * vector.z,
        m[1][0] * vector.x + m[1][1] * vector.y + m[1][2] * vector.z,
        m[2][0] * vector.x + m[2][1] * vector.y + m[2][2] * vector.z,
    };
}

[[nodiscard]] constexpr auto multiply(const Matrix3& lhs, const Matrix3& rhs) -> Matrix3 {
    Matrix3 result {};
    for (std::size_t row = 0; row < 3; ++row) {
        for (std::size_t column = 0; column < 3; ++column) {
            double value = 0.0;
            for (std::size_t inner = 0; inner < 3; ++inner) {
                value += lhs.values[row][inner] * rhs.values[inner][column];
            }
            result.values[row][column] = value;
        }
    }
    return result;
}

[[nodiscard]] constexpr auto transpose(const Matrix3& matrix) -> Matrix3 {
    Matrix3 result {};
    for (std::size_t row = 0; row < 3; ++row) {
        for (std::size_t column = 0; column < 3; ++column) {
            result.values[row][column] = matrix.values[column][row];
        }
    }
    return result;
}

}  // namespace piep::math
