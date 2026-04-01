#include <cmath>
#include <cstdlib>
#include <iostream>
#include <stdexcept>
#include <string_view>
#include <vector>

#include "piep/postprocessing/cell_postprocessing.hpp"
#include "piep/search/gm_search.hpp"
#include "search_fixtures.hpp"

namespace {

auto approx(double lhs, double rhs, double tolerance = 1.0e-9) -> bool {
    return std::abs(lhs - rhs) <= tolerance;
}

void require(bool condition, std::string_view message) {
    if (!condition) {
        throw std::runtime_error(std::string(message));
    }
}

void require_cell_close(const piep::crystal::CellParameters& actual,
                        const piep::crystal::CellParameters& expected,
                        double length_tolerance,
                        double angle_tolerance,
                        std::string_view message) {
    require(approx(actual.a, expected.a, length_tolerance) && approx(actual.b, expected.b, length_tolerance) &&
                approx(actual.c, expected.c, length_tolerance) &&
                approx(actual.alpha_deg, expected.alpha_deg, angle_tolerance) &&
                approx(actual.beta_deg, expected.beta_deg, angle_tolerance) &&
                approx(actual.gamma_deg, expected.gamma_deg, angle_tolerance),
            message);
}

void require_candidate_present(const piep::postprocessing::ConventionalizationResult& result,
                               piep::postprocessing::CrystalSystem system,
                               char centering,
                               const piep::crystal::CellParameters& expected,
                               double length_tolerance,
                               double angle_tolerance,
                               std::string_view message) {
    for (const auto& candidate : result.candidates) {
        if (candidate.legacy_system != system || candidate.centering != centering) {
            continue;
        }
        if (approx(candidate.cell.a, expected.a, length_tolerance) &&
            approx(candidate.cell.b, expected.b, length_tolerance) &&
            approx(candidate.cell.c, expected.c, length_tolerance) &&
            approx(candidate.cell.alpha_deg, expected.alpha_deg, angle_tolerance) &&
            approx(candidate.cell.beta_deg, expected.beta_deg, angle_tolerance) &&
            approx(candidate.cell.gamma_deg, expected.gamma_deg, angle_tolerance)) {
            return;
        }
    }
    throw std::runtime_error(std::string(message));
}

auto wide_volume_result(const std::vector<piep::search::SearchPattern>& patterns,
                        const piep::tests::CellFixture& fixture,
                        double absolute_increment,
                        double maximum_volume = 1000.0) -> piep::search::SearchEngineResult {
    return piep::search::search_unit_cells(
        patterns,
        {
            0.0,
            maximum_volume,
        },
        fixture.centering,
        {
            piep::search::IncrementMode::absolute,
            absolute_increment,
        });
}

auto exact_volume_result(const std::vector<piep::search::SearchPattern>& patterns,
                         const piep::tests::CellFixture& fixture,
                         double absolute_increment) -> piep::search::SearchEngineResult {
    const double volume = piep::crystal::direct_volume(fixture.cell);
    return piep::search::search_unit_cells(
        patterns,
        {
            volume,
            volume,
        },
        fixture.centering,
        {
            piep::search::IncrementMode::absolute,
            absolute_increment,
        });
}

void test_delaunay_reduction_matches_existing_reduced_cell() {
    const auto fixture = piep::tests::cupc_cell_fixture();
    const auto reduced = piep::postprocessing::delaunay_reduce_cell(fixture.cell, fixture.centering);

    require_cell_close(reduced.primitive_input_cell,
                       piep::crystal::to_primitive_cell(fixture.cell, fixture.centering),
                       1.0e-9,
                       1.0e-9,
                       "primitive input cell mismatch");
    require_cell_close(
        reduced.reduced_primitive_cell, piep::crystal::reduce_cell(fixture.cell, fixture.centering), 1.0e-9, 1.0e-9,
        "reduced primitive cell mismatch");
}

void test_cupc_conventionalization_matches_transcript() {
    const auto fixture = piep::tests::cupc_cell_fixture();
    const auto reduced = piep::crystal::reduce_cell(fixture.cell, fixture.centering);

    const auto transcript = piep::postprocessing::conventionalize_cell(
        reduced,
        'P',
        {
            'A',
            piep::postprocessing::CrystalSystem::monoclinic,
        });
    require_candidate_present(transcript,
                              piep::postprocessing::CrystalSystem::monoclinic,
                              'A',
                              {
                                  3.8175,
                                  25.5672,
                                  17.3289,
                                  88.70,
                                  95.35,
                                  90.20,
                              },
                              0.05,
                              0.2,
                              "CuPc transcript A setting missing");
    require(transcript.preferred_candidate.has_value(), "CuPc transcript preferred candidate missing");
    require(transcript.preferred_candidate->centering == 'A', "CuPc transcript preferred centering mismatch");

    const auto preferred = piep::postprocessing::conventionalize_cell(
        reduced,
        'P',
        {
            'C',
            piep::postprocessing::CrystalSystem::monoclinic,
        });
    require(preferred.preferred_candidate.has_value(), "CuPc preferred candidate missing");
    require(preferred.preferred_candidate->strict_system == piep::postprocessing::CrystalSystem::monoclinic,
            "CuPc preferred system mismatch");
    require_cell_close(
        preferred.preferred_candidate->cell, fixture.cell, 0.05, 0.2, "CuPc preferred conventional cell mismatch");
}

void test_grgds_conventionalization_matches_transcript() {
    const auto fixture = piep::tests::grgds_cell_fixture();
    const auto reduced = piep::crystal::reduce_cell(fixture.cell, fixture.centering);

    const auto transcript = piep::postprocessing::conventionalize_cell(
        reduced,
        'P',
        {
            'A',
            piep::postprocessing::CrystalSystem::monoclinic,
        });
    require_candidate_present(transcript,
                              piep::postprocessing::CrystalSystem::monoclinic,
                              'A',
                              {
                                  19.4660,
                                  4.4446,
                                  28.6756,
                                  90.02,
                                  105.47,
                                  90.00,
                              },
                              0.05,
                              0.1,
                              "GRGDS transcript A setting missing");

    const auto preferred = piep::postprocessing::conventionalize_cell(
        reduced,
        'P',
        {
            'C',
            piep::postprocessing::CrystalSystem::monoclinic,
        });
    require(preferred.preferred_candidate.has_value(), "GRGDS preferred candidate missing");
    require(preferred.preferred_candidate->strict_system == piep::postprocessing::CrystalSystem::monoclinic,
            "GRGDS preferred system mismatch");
    require_cell_close(
        preferred.preferred_candidate->cell, fixture.cell, 0.05, 0.1, "GRGDS preferred conventional cell mismatch");
}

void test_lysozyme_conventionalization_matches_transcript() {
    const auto fixture = piep::tests::lysozyme_cell_fixture();
    const auto reduced = piep::crystal::reduce_cell(fixture.cell, fixture.centering);

    const auto result = piep::postprocessing::conventionalize_cell(
        reduced,
        'P',
        {
            'P',
            piep::postprocessing::CrystalSystem::orthorhombic,
        });

    require_candidate_present(result,
                              piep::postprocessing::CrystalSystem::tetragonal,
                              'P',
                              {
                                  79.0641,
                                  79.0641,
                                  38.2168,
                                  90.00,
                                  90.00,
                                  90.00,
                              },
                              0.05,
                              0.05,
                              "Lysozyme tetragonal setting missing");
    require(result.preferred_candidate.has_value(), "Lysozyme preferred candidate missing");
    require(result.preferred_candidate->strict_system == piep::postprocessing::CrystalSystem::tetragonal,
            "Lysozyme preferred system mismatch");
    require_cell_close(
        result.preferred_candidate->cell, fixture.cell, 0.05, 0.05, "Lysozyme preferred conventional cell mismatch");
}

void test_reduced_cell_comparison_recognizes_equivalent_conventional_cells() {
    const auto cupc = piep::tests::cupc_cell_fixture();
    const auto comparison = piep::postprocessing::compare_reduced_cells(
        cupc.cell,
        cupc.centering,
        {
            3.8175,
            25.5672,
            17.3289,
            88.70,
            95.35,
            90.20,
        },
        'A');

    require(comparison.equivalent, "CuPc reduced-cell comparison failed");
    require(comparison.alpha_error_deg < 1.0, "CuPc reduced alpha error too large");
    require(comparison.beta_error_deg < 1.0, "CuPc reduced beta error too large");
    require(comparison.gamma_error_deg < 1.0, "CuPc reduced gamma error too large");
}

void test_postprocessing_survives_small_cell_perturbations() {
    const std::vector<piep::tests::CellFixture> fixtures {
        piep::tests::cupc_cell_fixture(),
        piep::tests::grgds_cell_fixture(),
        piep::tests::lysozyme_cell_fixture(),
    };
    const std::vector<piep::crystal::CellParameters> perturbations {
        {0.02, -0.01, 0.01, 0.15, -0.10, 0.12},
        {-0.03, 0.02, -0.01, -0.18, 0.14, -0.11},
        {0.01, 0.01, -0.02, 0.08, 0.06, -0.09},
    };

    for (std::size_t fixture_index = 0; fixture_index < fixtures.size(); ++fixture_index) {
        const auto& fixture = fixtures[fixture_index];
        const auto& delta = perturbations[fixture_index];
        const piep::crystal::CellParameters perturbed {
            fixture.cell.a + delta.a,
            fixture.cell.b + delta.b,
            fixture.cell.c + delta.c,
            fixture.cell.alpha_deg + delta.alpha_deg,
            fixture.cell.beta_deg + delta.beta_deg,
            fixture.cell.gamma_deg + delta.gamma_deg,
        };

        const auto result = piep::postprocessing::conventionalize_cell(
            perturbed,
            fixture.centering,
            {
                fixture.centering,
                fixture.centering == 'P' ? piep::postprocessing::CrystalSystem::orthorhombic
                                         : piep::postprocessing::CrystalSystem::monoclinic,
            });
        require(result.preferred_candidate.has_value(), "perturbed preferred candidate missing");

        const auto comparison = piep::postprocessing::compare_reduced_cells(
            result.preferred_candidate->cell, result.preferred_candidate->centering, fixture.cell, fixture.centering);
        require(comparison.equivalent, "perturbed post-processing lost lattice equivalence");
    }
}

void test_search_to_conventional_pipeline_matches_transcript() {
    const auto cupc_fixture = piep::tests::cupc_cell_fixture();
    const auto grgds_fixture = piep::tests::grgds_cell_fixture();
    const auto lyso_fixture = piep::tests::lysozyme_cell_fixture();

    const auto cupc_search = wide_volume_result(piep::tests::make_cupc_patterns(), cupc_fixture, 0.025);
    require(!cupc_search.candidates.empty(), "CuPc search produced no candidates");
    const auto cupc_post = piep::postprocessing::conventionalize_cell(
        cupc_search.candidates.front().evaluation.reduced_cell,
        'P',
        {
            'C',
            piep::postprocessing::CrystalSystem::monoclinic,
        });
    require(cupc_post.preferred_candidate.has_value(), "CuPc search post-processing missing");
    require_cell_close(
        cupc_post.preferred_candidate->cell, cupc_fixture.cell, 0.05, 0.2, "CuPc search post-processing mismatch");

    const auto grgds_search = wide_volume_result(piep::tests::make_grgds_patterns(), grgds_fixture, 0.025, 1500.0);
    require(!grgds_search.candidates.empty(), "GRGDS search produced no candidates");
    const auto grgds_post = piep::postprocessing::conventionalize_cell(
        grgds_search.candidates.front().evaluation.reduced_cell,
        'P',
        {
            'C',
            piep::postprocessing::CrystalSystem::monoclinic,
        });
    require(grgds_post.preferred_candidate.has_value(), "GRGDS search post-processing missing");
    require_cell_close(grgds_post.preferred_candidate->cell,
                       grgds_fixture.cell,
                       0.05,
                       0.1,
                       "GRGDS search post-processing mismatch");

    const auto lyso_search = exact_volume_result(piep::tests::make_lysozyme_square_patterns(), lyso_fixture, 0.025);
    require(!lyso_search.candidates.empty(), "Lysozyme search produced no candidates");
    const auto lyso_post = piep::postprocessing::conventionalize_cell(
        lyso_search.candidates.front().evaluation.reduced_cell,
        'P',
        {
            'P',
            piep::postprocessing::CrystalSystem::orthorhombic,
        });
    require(lyso_post.preferred_candidate.has_value(), "Lysozyme search post-processing missing");
    require_cell_close(
        lyso_post.preferred_candidate->cell, lyso_fixture.cell, 0.05, 0.05, "Lysozyme search post-processing mismatch");
}

}  // namespace

int main() {
    try {
        test_delaunay_reduction_matches_existing_reduced_cell();
        test_cupc_conventionalization_matches_transcript();
        test_grgds_conventionalization_matches_transcript();
        test_lysozyme_conventionalization_matches_transcript();
        test_reduced_cell_comparison_recognizes_equivalent_conventional_cells();
        test_postprocessing_survives_small_cell_perturbations();
        test_search_to_conventional_pipeline_matches_transcript();

        std::cout << "All post-processing checks passed.\n";
        return EXIT_SUCCESS;
    }
    catch (const std::exception& error) {
        std::cerr << error.what() << '\n';
        return EXIT_FAILURE;
    }
}
