#include <iomanip>
#include <iostream>
#include <vector>

#include "piep/crystal/cell.hpp"
#include "piep/crystal/reflection.hpp"
#include "piep/indexing/indexing_engine.hpp"
#include "piep/math/matrix3.hpp"
#include "piep/math/vector3.hpp"
#include "piep/search/candidate_generator.hpp"
#include "piep/search/pattern_prep.hpp"
#include "piep/search/reference_selection.hpp"
#include "piep/search/search_grid.hpp"

int main() {
    using piep::crystal::CellParameters;
    using piep::crystal::apply_basis_change;
    using piep::crystal::direct_volume;
    using piep::crystal::reciprocal_cell;
    using piep::crystal::reduce_cell;
    using piep::crystal::reduce_zone_basis;
    using piep::indexing::index_prepared_pattern;
    using piep::math::Matrix3;
    using piep::math::Vector3;
    using piep::math::cross;
    using piep::math::determinant;
    using piep::math::dot;
    using piep::math::inverse;
    using piep::math::multiply;
    using piep::search::PatternObservation;
    using piep::search::PatternPreparationSettings;
    using piep::search::SearchPattern;
    using piep::search::generate_search_candidates;
    using piep::search::prepare_pattern;
    using piep::search::select_reference_pattern;
    using piep::search::initialize_search_grid;

    const Vector3 a {1.0, 2.0, 3.0};
    const Vector3 b {4.0, -5.0, 6.0};
    const auto c = cross(a, b);

    const Matrix3 matrix({{{2.0, 0.0, 0.0}, {0.0, 3.0, 0.0}, {0.0, 0.0, 4.0}}});
    const auto inv = inverse(matrix);
    const auto transformed = multiply(inv, Vector3 {8.0, 9.0, 16.0});

    const CellParameters cell {10.0, 12.0, 15.0, 90.0, 100.0, 110.0};
    const auto reciprocal = reciprocal_cell(cell);

    const CellParameters cupc_a_centered {3.8170, 25.5670, 17.3290, 88.70, 95.35, 90.20};
    const Matrix3 swap_a_c({{{0.0, 0.0, 1.0}, {0.0, -1.0, 0.0}, {1.0, 0.0, 0.0}}});
    const auto cupc_c_centered = apply_basis_change(cupc_a_centered, swap_a_c);
    const auto reduced_cupc = reduce_cell(CellParameters {17.6850, 25.9180, 3.8330, 90.0, 95.05, 90.0}, 'C');
    const auto reduced_zone = reduce_zone_basis({12.0, 10.0, 90.0});
    const auto prepared_pattern = prepare_pattern(
        PatternObservation {
            "1 CuPc pattern 19",
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
        },
        PatternPreparationSettings {
            200000.0,
            5.0,
            5.0,
        });
    const std::vector<SearchPattern> cupc_patterns {
        {
            1,
            prepared_pattern,
            false,
        },
        {
            2,
            prepare_pattern(
                PatternObservation {"2 CuPc pattern 20", 1100.0000, 55.0000, 144.8900, 4.3467, 310.2700, 9.3081, 305.4153,
                                    0.0000, 74.5300, 2.5000, 0.00, 0.00, 0.00, 0.00, 5.00, 0.00, 5.00, 300000.0},
                PatternPreparationSettings {200000.0, 5.0, 5.0}),
            false,
        },
        {
            3,
            prepare_pattern(
                PatternObservation {"3 CuPc pattern 24", 1100.0000, 55.0000, 129.2900, 3.8787, 419.2200, 12.5766, 450.5573,
                                    0.0000, 95.5800, 2.5000, 0.00, 0.00, 0.00, 0.00, 5.00, 0.00, 5.00, 300000.0},
                PatternPreparationSettings {200000.0, 5.0, 5.0}),
            false,
        },
        {
            4,
            prepare_pattern(
                PatternObservation {"4 CuPc pattern 29", 1100.0000, 55.0000, 86.2100, 2.5863, 370.6000, 11.1180, 379.5663,
                                    0.0000, 89.3670, 2.5000, 0.00, 0.00, 0.00, 0.00, 5.00, 0.00, 5.00, 300000.0},
                PatternPreparationSettings {200000.0, 5.0, 5.0}),
            false,
        },
        {
            5,
            prepare_pattern(
                PatternObservation {"5 CuPc pattern 30", 1100.0000, 55.0000, 86.2600, 2.5878, 414.9200, 12.4476, 433.3040,
                                    0.0000, 96.5400, 2.5000, 0.00, 0.00, 0.00, 0.00, 5.00, 0.00, 5.00, 300000.0},
                PatternPreparationSettings {200000.0, 5.0, 5.0}),
            false,
        },
        {
            6,
            prepare_pattern(
                PatternObservation {"6 CuPc pattern 31", 1100.0000, 55.0000, 86.2600, 2.5878, 511.5500, 15.3465, 512.6692,
                                    0.0000, 85.9100, 2.5000, 0.00, 0.00, 0.00, 0.00, 5.00, 0.00, 5.00, 300000.0},
                PatternPreparationSettings {200000.0, 5.0, 5.0}),
            false,
        },
        {
            7,
            prepare_pattern(
                PatternObservation {"7 CuPc pattern 32", 1100.0000, 55.0000, 77.7300, 2.3319, 76.1300, 2.2839, 86.0699,
                                    0.0000, 68.0200, 2.5000, 0.00, 0.00, 0.00, 0.00, 5.00, 0.00, 5.00, 300000.0},
                PatternPreparationSettings {200000.0, 5.0, 5.0}),
            false,
        },
    };
    const auto reference_selection = select_reference_pattern(cupc_patterns);
    const auto search_grid =
        initialize_search_grid(cupc_patterns, {0.0, 1000.0}, {piep::search::IncrementMode::absolute, 0.025});
    const auto candidate_preview = generate_search_candidates(search_grid, {0.5, 3});
    const auto indexed_pattern =
        index_prepared_pattern(prepared_pattern, CellParameters {17.3289, 25.5672, 3.8175, 89.80, 95.35, 91.30}, 'C');

    std::cout << std::fixed << std::setprecision(6);
    std::cout << "dot(a, b) = " << dot(a, b) << '\n';
    std::cout << "cross(a, b) = [" << c.x << ", " << c.y << ", " << c.z << "]\n";
    std::cout << "det(matrix) = " << determinant(matrix) << '\n';
    std::cout << "inv(matrix) * [8, 9, 16] = [" << transformed.x << ", " << transformed.y << ", "
              << transformed.z << "]\n";
    std::cout << "direct volume = " << direct_volume(cell) << '\n';
    std::cout << "reciprocal cell = [" << reciprocal.a << ", " << reciprocal.b << ", " << reciprocal.c
              << "; " << reciprocal.alpha_deg << ", " << reciprocal.beta_deg << ", " << reciprocal.gamma_deg
              << "]\n";
    std::cout << "CuPc transformed cell = [" << cupc_c_centered.a << ", " << cupc_c_centered.b << ", "
              << cupc_c_centered.c << "; " << cupc_c_centered.alpha_deg << ", " << cupc_c_centered.beta_deg
              << ", " << cupc_c_centered.gamma_deg << "]\n";
    std::cout << "CuPc reduced cell = [" << reduced_cupc.a << ", " << reduced_cupc.b << ", " << reduced_cupc.c
              << "; " << reduced_cupc.alpha_deg << ", " << reduced_cupc.beta_deg << ", "
              << reduced_cupc.gamma_deg << "]\n";
    std::cout << "Reduced zone basis = [" << reduced_zone.reduced_basis.first_length << ", "
              << reduced_zone.reduced_basis.second_length << ", " << reduced_zone.reduced_basis.angle_deg
              << "; r3=" << reduced_zone.closing_length
              << ", status=" << static_cast<int>(reduced_zone.status) << "]\n";
    std::cout << "Prepared CuPc pattern = [du1=" << prepared_pattern.normalized_radius_lower_bounds[0]
              << ", du2=" << prepared_pattern.normalized_radius_lower_bounds[1]
              << ", do1=" << prepared_pattern.normalized_radius_upper_bounds[0]
              << ", do2=" << prepared_pattern.normalized_radius_upper_bounds[1]
              << ", cw1=" << prepared_pattern.angle_cosine << ", wo=" << prepared_pattern.angle_cosine_upper_bound
              << ", wu=" << prepared_pattern.angle_cosine_lower_bound
              << ", d4=" << prepared_pattern.reflection_search_limit << "]\n";
    std::cout << "CuPc search setup = [ref=" << reference_selection.reference_slot
              << ", mode=" << static_cast<int>(reference_selection.search_mode)
              << ", layers=" << search_grid.layer_count << ", sets=" << search_grid.total_grid_points
              << ", p=" << search_grid.first_layer_p << "..." << search_grid.last_layer_p << "]\n";
    std::cout << "CuPc candidate preview = [stored=" << candidate_preview.candidates.size()
              << ", total=" << candidate_preview.total_candidate_count
              << ", first xyz=" << candidate_preview.candidates.front().x << ", "
              << candidate_preview.candidates.front().y << ", " << candidate_preview.candidates.front().z << "]\n";
    std::cout << "CuPc indexing preview = [matches=" << indexed_pattern.matches.size()
              << ", top hkl1=(" << indexed_pattern.matches.front().first_hkl.h << ", "
              << indexed_pattern.matches.front().first_hkl.k << ", "
              << indexed_pattern.matches.front().first_hkl.l << ")"
              << ", hkl2=(" << indexed_pattern.matches.front().second_hkl.h << ", "
              << indexed_pattern.matches.front().second_hkl.k << ", "
              << indexed_pattern.matches.front().second_hkl.l << ")"
              << ", zone=(" << indexed_pattern.matches.front().zone_axis.h << ", "
              << indexed_pattern.matches.front().zone_axis.k << ", "
              << indexed_pattern.matches.front().zone_axis.l << ")"
              << ", fom=" << indexed_pattern.matches.front().figure_of_merit << "]\n";

    return 0;
}
