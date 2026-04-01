#include <cmath>
#include <cstdlib>
#include <iostream>
#include <stdexcept>
#include <string>
#include <string_view>

#include "piep/crystal/cell.hpp"
#include "piep/crystal/reflection.hpp"
#include "piep/math/matrix3.hpp"
#include "piep/math/vector3.hpp"

namespace {

auto approx(double lhs, double rhs, double tolerance = 1.0e-9) -> bool {
    return std::abs(lhs - rhs) <= tolerance;
}

void require(bool condition, std::string_view message) {
    if (!condition) {
        throw std::runtime_error(std::string(message));
    }
}

void require_vector(const piep::math::Vector3& actual,
                    const piep::math::Vector3& expected,
                    double tolerance,
                    std::string_view message) {
    require(approx(actual.x, expected.x, tolerance) && approx(actual.y, expected.y, tolerance) &&
                approx(actual.z, expected.z, tolerance),
            message);
}

void require_cell(const piep::crystal::CellParameters& actual,
                  const piep::crystal::CellParameters& expected,
                  double length_tolerance,
                  double angle_tolerance,
                  std::string_view message) {
    require(
        approx(actual.a, expected.a, length_tolerance) && approx(actual.b, expected.b, length_tolerance) &&
            approx(actual.c, expected.c, length_tolerance) &&
            approx(actual.alpha_deg, expected.alpha_deg, angle_tolerance) &&
            approx(actual.beta_deg, expected.beta_deg, angle_tolerance) &&
            approx(actual.gamma_deg, expected.gamma_deg, angle_tolerance),
        message);
}

void require_metric(const piep::crystal::CellMetric& actual,
                    const piep::crystal::CellMetric& expected,
                    double tolerance,
                    std::string_view message) {
    require(approx(actual.a, expected.a, tolerance) && approx(actual.b, expected.b, tolerance) &&
                approx(actual.c, expected.c, tolerance) &&
                approx(actual.cos_alpha, expected.cos_alpha, tolerance) &&
                approx(actual.cos_beta, expected.cos_beta, tolerance) &&
                approx(actual.cos_gamma, expected.cos_gamma, tolerance),
            message);
}

void test_vector_and_matrix_primitives() {
    using piep::math::Matrix3;
    using piep::math::Vector3;
    using piep::math::cross;
    using piep::math::determinant;
    using piep::math::dot;
    using piep::math::inverse;
    using piep::math::multiply;
    using piep::math::transpose;

    require(approx(dot(Vector3 {1.0, 2.0, 3.0}, Vector3 {4.0, -5.0, 6.0}), 12.0), "dot product failed");

    require_vector(
        cross(Vector3 {1.0, 0.0, 0.0}, Vector3 {0.0, 1.0, 0.0}),
        Vector3 {0.0, 0.0, 1.0},
        1.0e-12,
        "cross product failed");

    const Matrix3 matrix({{{2.0, 1.0, 0.0}, {0.0, 3.0, 0.0}, {0.0, 0.0, 4.0}}});
    require(approx(determinant(matrix), 24.0), "determinant failed");

    const Matrix3 inverse_matrix = inverse(matrix);
    const Vector3 transformed = multiply(inverse_matrix, Vector3 {5.0, 9.0, 16.0});
    require_vector(transformed, Vector3 {1.0, 3.0, 4.0}, 1.0e-12, "inverse multiply failed");

    const Matrix3 product = multiply(matrix, inverse_matrix);
    require_vector(product.column(0), Vector3 {1.0, 0.0, 0.0}, 1.0e-10, "matrix multiply column 0 failed");
    require_vector(product.column(1), Vector3 {0.0, 1.0, 0.0}, 1.0e-10, "matrix multiply column 1 failed");
    require_vector(product.column(2), Vector3 {0.0, 0.0, 1.0}, 1.0e-10, "matrix multiply column 2 failed");

    const Matrix3 transposed = transpose(matrix);
    require_vector(transposed.column(0), Vector3 {2.0, 1.0, 0.0}, 1.0e-12, "transpose failed");
}

void test_metric_conversion_and_legacy_orthogonalization() {
    using piep::crystal::CellParameters;
    using piep::crystal::direct_cell_from_reciprocal;
    using piep::crystal::orth;
    using piep::crystal::orth1;
    using piep::crystal::reciprocal_from_metric;
    using piep::crystal::to_metric;
    using piep::crystal::tr;
    using piep::crystal::trd;
    using piep::crystal::xtodg;

    const CellParameters triclinic {10.0, 12.0, 15.0, 90.0, 100.0, 110.0};
    const piep::crystal::CellMetric direct_metric = to_metric(triclinic);
    const auto reciprocal = reciprocal_from_metric(direct_metric);
    const CellParameters round_trip = direct_cell_from_reciprocal(reciprocal.parameters);
    require_cell(round_trip, triclinic, 1.0e-9, 1.0e-8, "direct/reciprocal round-trip failed");

    const auto direct_coeffs = orth1(direct_metric, reciprocal.direct_volume);
    const auto direct_basis = tr(piep::math::Matrix3::identity(), direct_coeffs);
    require_metric(xtodg(direct_basis), direct_metric, 1.0e-9, "orth1 + tr + xtodg failed");

    const auto orth_pair = orth(reciprocal.metric, direct_metric, reciprocal.direct_volume);
    const auto reciprocal_basis = tr(piep::math::Matrix3::identity(), orth_pair.reciprocal);
    require_metric(xtodg(reciprocal_basis), reciprocal.metric, 1.0e-9, "orth + tr on reciprocal basis failed");

    const auto recovered_direct_basis = trd(piep::math::Matrix3::identity(), orth_pair.direct);
    require_metric(xtodg(recovered_direct_basis), direct_metric, 1.0e-9, "orth + trd on direct basis failed");
}

void test_basis_change_matches_publication_examples() {
    using piep::crystal::CellParameters;
    using piep::crystal::apply_basis_change;
    using piep::math::Matrix3;

    require_cell(
        apply_basis_change(CellParameters {10.0, 12.0, 15.0, 90.0, 100.0, 110.0}, Matrix3::identity()),
        CellParameters {10.0, 12.0, 15.0, 90.0, 100.0, 110.0},
        1.0e-9,
        1.0e-8,
        "identity basis change failed");

    const Matrix3 swap_a_c({{{0.0, 0.0, 1.0}, {0.0, -1.0, 0.0}, {1.0, 0.0, 0.0}}});

    const CellParameters cupc_a_centered {3.8170, 25.5670, 17.3290, 88.70, 95.35, 90.20};
    const CellParameters cupc_c_centered = apply_basis_change(cupc_a_centered, swap_a_c);
    require_cell(
        cupc_c_centered,
        CellParameters {17.3290, 25.5670, 3.8170, 89.80, 95.35, 91.30},
        0.03,
        0.35,
        "CuPc basis change failed");

    const CellParameters grgds_a_centered {19.4660, 4.4446, 28.6756, 90.02, 105.47, 90.00};
    const CellParameters grgds_c_centered = apply_basis_change(grgds_a_centered, swap_a_c);
    require_cell(
        grgds_c_centered,
        CellParameters {28.6756, 4.4446, 19.4660, 90.00, 105.47, 90.02},
        0.03,
        0.15,
        "GRGDS basis change failed");
}

void test_reduction_matches_publication_examples() {
    using piep::crystal::CellParameters;
    using piep::crystal::reduce_cell;

    const CellParameters cupc_conventional {17.6850, 25.9180, 3.8330, 90.0, 95.05, 90.0};
    const CellParameters reduced_cupc = reduce_cell(cupc_conventional, 'C');
    require_cell(
        reduced_cupc,
        CellParameters {3.8330, 15.6880, 15.6880, 111.39, 92.84, 92.84},
        0.25,
        0.8,
        "CuPc reduction failed");

    const CellParameters grgds_conventional {28.6756, 4.4446, 19.4660, 90.00, 105.47, 90.02};
    const CellParameters reduced_grgds = reduce_cell(grgds_conventional, 'C');
    require_cell(
        reduced_grgds,
        CellParameters {4.4446, 14.5100, 19.4660, 105.3, 90.0, 98.8},
        0.2,
        1.0,
        "GRGDS reduction failed");
}

void test_zone_basis_reduction() {
    using piep::crystal::ZoneBasisObservation;
    using piep::crystal::ZoneBasisReductionStatus;
    using piep::crystal::reduce_zone_basis;

    const auto square = reduce_zone_basis({10.0, 10.0, 90.0});
    require(approx(square.reduced_basis.first_length, 10.0, 1.0e-9), "square first length failed");
    require(approx(square.reduced_basis.second_length, 10.0, 1.0e-9), "square second length failed");
    require(approx(square.reduced_basis.angle_deg, 90.0, 1.0e-9), "square angle failed");
    require(approx(square.closing_length, std::sqrt(200.0), 1.0e-9), "square closing length failed");
    require(square.status == ZoneBasisReductionStatus::unchanged, "square status failed");

    const auto swapped = reduce_zone_basis({12.0, 10.0, 90.0});
    require(approx(swapped.reduced_basis.first_length, 10.0, 1.0e-9), "swapped first length failed");
    require(approx(swapped.reduced_basis.second_length, 12.0, 1.0e-9), "swapped second length failed");
    require(approx(swapped.reduced_basis.angle_deg, 90.0, 1.0e-9), "swapped angle failed");
    require(swapped.status == ZoneBasisReductionStatus::vectors_swapped, "swapped status failed");

    const auto obtuse = reduce_zone_basis({8.0, 8.0, 120.0});
    require(approx(obtuse.reduced_basis.angle_deg, 60.0, 1.0e-9), "obtuse angle reduction failed");
    require(obtuse.status == ZoneBasisReductionStatus::angle_changed, "obtuse status failed");
}

}  // namespace

int main() {
    try {
        test_vector_and_matrix_primitives();
        test_metric_conversion_and_legacy_orthogonalization();
        test_basis_change_matches_publication_examples();
        test_reduction_matches_publication_examples();
        test_zone_basis_reduction();

        std::cout << "All geometry checks passed.\n";
        return EXIT_SUCCESS;
    }
    catch (const std::exception& error) {
        std::cerr << error.what() << '\n';
        return EXIT_FAILURE;
    }
}
