from __future__ import annotations

from dataclasses import replace
import math

import piep
import piep.examples as examples


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def require_cell_close(
    actual: piep.Cell,
    expected: piep.Cell,
    length_tolerance: float,
    angle_tolerance: float,
    message: str,
) -> None:
    close = (
        abs(actual.a - expected.a) <= length_tolerance
        and abs(actual.b - expected.b) <= length_tolerance
        and abs(actual.c - expected.c) <= length_tolerance
        and abs(actual.alpha_deg - expected.alpha_deg) <= angle_tolerance
        and abs(actual.beta_deg - expected.beta_deg) <= angle_tolerance
        and abs(actual.gamma_deg - expected.gamma_deg) <= angle_tolerance
    )
    require(close, message)


def test_observation_input_factories() -> None:
    reciprocal = piep.PatternObservation.from_reciprocal_vectors(
        "reciprocal",
        [0.10, 0.00],
        [0.00, 0.20],
        1000.0,
        first_length_sigma_inverse_angstrom=0.002,
        second_length_sigma_inverse_angstrom=0.003,
        angle_sigma_deg=1.5,
        high_voltage_volts=200000.0,
        wavelength_angstrom=0.02508,
    )
    require(math.isclose(reciprocal.first_radius, 100.0, abs_tol=1.0e-9), "reciprocal first radius mismatch")
    require(math.isclose(reciprocal.second_radius, 200.0, abs_tol=1.0e-9), "reciprocal second radius mismatch")
    require(math.isclose(reciprocal.angle_deg, 90.0, abs_tol=1.0e-9), "reciprocal angle mismatch")

    restored = piep.restore_pattern(reciprocal)
    require(restored["wavelength_angstrom"] > 0.02, "restored wavelength override was not applied")

    detector = piep.PatternObservation.from_detector_geometry(
        "detector",
        [100.0, 0.0],
        [0.0, 100.0],
        [0.0, 0.0],
        detector_distance_mm=800.0,
        wavelength_angstrom=0.02508,
        pixel_size_x_mm=0.05,
        radius_sigma_mm=0.2,
        high_voltage_volts=200000.0,
    )
    require(math.isclose(detector.camera_constant, 20.064, abs_tol=1.0e-3), "detector camera constant mismatch")
    require(math.isclose(detector.first_radius, 5.0, abs_tol=1.0e-9), "detector first radius mismatch")
    require(math.isclose(detector.angle_deg, 90.0, abs_tol=1.0e-9), "detector angle mismatch")


def test_archived_search_and_conventionalization() -> None:
    tolerances = {
        "CuPc": (0.05, 0.2),
        "GRGDS": (0.05, 0.2),
        "Lysozyme": (0.10, 0.10),
    }
    for case in examples.archived_cases():
        result = piep.search_and_conventionalize(
            case.patterns,
            volume_min=case.volume_min,
            volume_max=case.volume_max,
            centering=case.centering,
            increment_value=0.025,
            preferred_centering=case.preferred_centering,
            minimum_system=case.minimum_system,
            top_n=3,
        )
        require(
            result.search.total_candidate_count == case.expected_candidate_count,
            f"{case.name} candidate count mismatch",
        )
        require(result.preferred_candidate is not None, f"{case.name} produced no search candidate")
        preferred = result.preferred_candidate.preferred_candidate
        require(preferred is not None, f"{case.name} produced no preferred conventional setting")
        require(preferred.centering == case.preferred_centering, f"{case.name} preferred centering mismatch")
        length_tolerance, angle_tolerance = tolerances[case.name]
        require_cell_close(preferred.cell, case.cell, length_tolerance, angle_tolerance, f"{case.name} cell mismatch")


def test_postprocessing_robustness() -> None:
    equivalent = piep.compare_reduced_cells(
        examples.cupc_case().cell,
        piep.Cell(3.8175, 25.5672, 17.3289, 88.70, 95.35, 90.20),
        lhs_centering="C",
        rhs_centering="A",
    )
    require(equivalent.equivalent, "CuPc conventional settings were not recognized as equivalent")

    perturbations = {
        "CuPc": piep.Cell(0.02, -0.01, 0.01, 0.15, -0.10, 0.12),
        "GRGDS": piep.Cell(-0.03, 0.02, -0.01, -0.18, 0.14, -0.11),
        "Lysozyme": piep.Cell(0.01, 0.01, -0.02, 0.08, 0.06, -0.09),
    }
    for case in examples.archived_cases():
        delta = perturbations[case.name]
        perturbed = piep.Cell(
            case.cell.a + delta.a,
            case.cell.b + delta.b,
            case.cell.c + delta.c,
            case.cell.alpha_deg + delta.alpha_deg,
            case.cell.beta_deg + delta.beta_deg,
            case.cell.gamma_deg + delta.gamma_deg,
        )
        reduced = piep.delaunay_reduce_cell(perturbed, centering=case.centering)
        conventional = piep.conventionalize_cell(
            reduced.reduced_primitive_cell,
            centering="P",
            preferred_centering=case.preferred_centering,
            minimum_system=case.minimum_system,
        )
        require(conventional.preferred_candidate is not None, f"{case.name} perturbed conventionalization failed")
        preferred = conventional.preferred_candidate
        require(preferred.centering == case.preferred_centering, f"{case.name} perturbed centering mismatch")
        require_cell_close(
            preferred.cell,
            case.cell,
            0.35 if case.name == "Lysozyme" else 0.10,
            0.80,
            f"{case.name} perturbed conventional cell drifted too far",
        )


def build_simulated_patterns(
    case: examples.CaseStudy,
    zones: list[piep.ZoneDirection],
    *,
    camera_constant: float,
    maximum_radius_mm: float,
    positional_sigma_mm: float,
    reported_radius_sigma_mm: float,
    angle_biases_deg: list[float],
    seed: int,
) -> list[piep.SearchPattern]:
    patterns: list[piep.SearchPattern] = []
    for index, zone in enumerate(zones, start=1):
        ensemble = piep.simulate_zone_observation_ensemble(
            case.cell,
            [zone],
            title_prefix=f"{case.name} synthetic",
            camera_constant=camera_constant,
            maximum_radius_mm=maximum_radius_mm,
            centering=case.centering,
            positional_sigma_mm=positional_sigma_mm,
            reported_radius_sigma_mm=reported_radius_sigma_mm,
            reported_angle_sigma_deg=2.5,
            camera_constant_sigma=case.patterns[0].observation.camera_constant_sigma,
            high_voltage_volts=case.patterns[0].observation.high_voltage_volts,
            seed=seed + index - 1,
        )
        require(len(ensemble.observations) == 1, f"{case.name} synthetic zone generation failed")
        observation = ensemble.observations[0].observation
        observation = replace(observation, angle_deg=observation.angle_deg + angle_biases_deg[index - 1])
        patterns.append(piep.SearchPattern(index, observation))
    return patterns


def build_archived_match_synthetic_patterns(
    case: examples.CaseStudy,
    *,
    pattern_count: int,
    positional_sigma_mm: float,
    angle_biases_deg: list[float],
    seed: int,
) -> list[piep.SearchPattern]:
    patterns: list[piep.SearchPattern] = []
    for index, archived in enumerate(case.patterns[:pattern_count], start=1):
        top_match = piep.index_pattern(archived.observation, case.cell, centering=case.centering).top_match
        require(top_match is not None, f"{case.name} archived synthetic source pattern did not index")
        maximum_radius_mm = 1.35 * max(
            archived.observation.first_radius,
            archived.observation.second_radius,
            archived.observation.third_radius,
        )
        simulated = piep.simulate_observation_from_zone_pair(
            case.cell,
            piep.ZoneDirection(*top_match.zone_axis),
            top_match.first_hkl,
            top_match.second_hkl,
            title=f"{case.name} archived synthetic {index}",
            camera_constant=archived.observation.camera_constant,
            maximum_radius_mm=maximum_radius_mm,
            centering=case.centering,
            positional_sigma_mm=positional_sigma_mm,
            reported_radius_sigma_mm=max(
                archived.observation.first_radius_sigma,
                archived.observation.second_radius_sigma,
            ),
            reported_angle_sigma_deg=archived.observation.angle_sigma_deg,
            camera_constant_sigma=archived.observation.camera_constant_sigma,
            high_voltage_volts=archived.observation.high_voltage_volts,
            seed=seed + index - 1,
        )
        observation = replace(
            simulated.observation,
            angle_deg=simulated.observation.angle_deg + angle_biases_deg[index - 1],
        )
        patterns.append(piep.SearchPattern(index, observation))
    return patterns


def test_synthetic_candidate_evaluation() -> None:
    synthetic_cases = [
        (
            examples.cupc_case(),
            [piep.ZoneDirection(0.0, 0.0, 1.0), piep.ZoneDirection(1.0, 1.0, 0.0), piep.ZoneDirection(1.0, 0.0, 1.0)],
            1100.0,
            500.0,
            0.0,
            0.05,
            [0.0, 0.0, 0.0],
            2.0,
        ),
        (
            examples.grgds_case(),
            [piep.ZoneDirection(0.0, 1.0, -1.0), piep.ZoneDirection(0.0, 0.0, 1.0)],
            360.0,
            450.0,
            0.05,
            0.05,
            [0.20, -0.15],
            2.0,
        ),
    ]
    for case, zones, camera_constant, maximum_radius_mm, positional_sigma_mm, radius_sigma_mm, angle_biases, fom_limit in synthetic_cases:
        patterns = build_simulated_patterns(
            case,
            zones,
            camera_constant=camera_constant,
            maximum_radius_mm=maximum_radius_mm,
            positional_sigma_mm=positional_sigma_mm,
            reported_radius_sigma_mm=radius_sigma_mm,
            angle_biases_deg=angle_biases,
            seed=1234,
        )
        evaluation = piep.evaluate_candidate(patterns, case.cell, centering=case.centering)
        require(evaluation.pattern_match_count == len(patterns), f"{case.name} synthetic pattern count mismatch")
        require(evaluation.figure_of_merit < fom_limit, f"{case.name} synthetic FOM too large")


def test_synthetic_full_pipeline_lysozyme() -> None:
    case = examples.lysozyme_case()
    patterns = build_archived_match_synthetic_patterns(
        case,
        pattern_count=6,
        positional_sigma_mm=0.01,
        angle_biases_deg=[0.08, -0.06, 0.04, -0.03, 0.02, -0.01],
        seed=2234,
    )
    result = piep.search_and_conventionalize(
        patterns,
        volume_min=case.exact_volume,
        volume_max=case.exact_volume,
        centering=case.centering,
        increment_value=0.01,
        preferred_centering=case.preferred_centering,
        minimum_system="triclinic",
        top_n=20,
    )
    require(result.search.candidates, "Lysozyme synthetic search returned no stored candidates")
    found_tetragonal = False
    for candidate in result.candidates:
        preferred = candidate.preferred_candidate
        if preferred is None or preferred.system != "tetragonal":
            continue
        found_tetragonal = True
        close = (
            abs(preferred.cell.a - case.cell.a) <= 1.5
            and abs(preferred.cell.b - case.cell.b) <= 1.5
            and abs(preferred.cell.c - case.cell.c) <= 1.5
            and abs(preferred.cell.alpha_deg - case.cell.alpha_deg) <= 1.3
            and abs(preferred.cell.beta_deg - case.cell.beta_deg) <= 1.3
            and abs(preferred.cell.gamma_deg - case.cell.gamma_deg) <= 1.3
        )
        if close:
            return
    require(found_tetragonal, "Lysozyme synthetic search produced no tetragonal candidates")
    raise AssertionError("Lysozyme synthetic search did not yield a close tetragonal candidate")


def main() -> None:
    test_observation_input_factories()
    test_archived_search_and_conventionalization()
    test_postprocessing_robustness()
    test_synthetic_candidate_evaluation()
    test_synthetic_full_pipeline_lysozyme()
    print("Notebook-friendly Python API tests passed.")


if __name__ == "__main__":
    main()
