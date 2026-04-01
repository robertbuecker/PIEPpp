from __future__ import annotations

import math

import numpy as np
import piep
import piep_core


def main() -> None:
    assert math.isclose(piep_core.dot3([1.0, 2.0, 3.0], [4.0, -5.0, 6.0]), 12.0)
    assert piep_core.cross3([1.0, 0.0, 0.0], [0.0, 1.0, 0.0]) == [0.0, 0.0, 1.0]
    assert math.isclose(piep_core.cell_volume(2.0, 3.0, 4.0, 90.0, 90.0, 90.0), 24.0)

    reciprocal = np.array(piep_core.reciprocal_cell(10.0, 10.0, 10.0, 90.0, 90.0, 90.0))
    assert np.allclose(reciprocal[:3], np.array([0.1, 0.1, 0.1]))
    assert np.allclose(reciprocal[3:], np.array([90.0, 90.0, 90.0]))

    metric = np.array(piep_core.cell_metric(10.0, 12.0, 15.0, 90.0, 100.0, 110.0))
    assert np.allclose(metric[:3], np.array([10.0, 12.0, 15.0]))

    transformed = np.array(
        piep_core.apply_basis_change(
            3.8170,
            25.5670,
            17.3290,
            88.70,
            95.35,
            90.20,
            [0.0, 0.0, 1.0, 0.0, -1.0, 0.0, 1.0, 0.0, 0.0],
        )
    )
    assert np.allclose(transformed[:3], np.array([17.3290, 25.5670, 3.8170]), atol=0.03)

    reduced = np.array(piep_core.reduce_cell(17.6850, 25.9180, 3.8330, 90.0, 95.05, 90.0, "C"))
    assert np.allclose(reduced[:3], np.array([3.8330, 15.6880, 15.6880]), atol=0.25)

    reduced_zone = np.array(piep_core.reduce_zone_basis(12.0, 10.0, 90.0))
    assert np.allclose(reduced_zone[:3], np.array([10.0, 12.0, 90.0]))
    assert reduced_zone[4] == 2.0

    pattern_fields = [
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
    ]
    assert np.allclose(piep_core.pattern_fields_round_trip("1 CuPc pattern 19", pattern_fields), pattern_fields)

    restored = piep_core.restore_pattern_from_fields("1 CuPc pattern 19", pattern_fields, 200000.0, 5.0, 5.0)
    assert restored["rounded_high_voltage_kv"] == 300
    assert restored["has_laue_zone_information"] is False

    prepared = piep_core.prepare_pattern_from_fields("1 CuPc pattern 19", pattern_fields, 200000.0, 5.0, 5.0)
    assert prepared["angle_cosine"] < 0.0
    assert prepared["angle_cosine_lower_bound"] > 0.0

    inflated = piep_core.prepare_pattern_with_temporary_errors_from_fields(
        "1 CuPc pattern 19",
        pattern_fields,
        200000.0,
        5.0,
        5.0,
        0.1,
        2.5,
    )
    assert inflated["restored"]["camera_upper_squared"] > prepared["restored"]["camera_upper_squared"]

    cupc_patterns = [
        (
            1,
            "1 CuPc pattern 19",
            [
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
            ],
            False,
        ),
        (
            2,
            "2 CuPc pattern 20",
            [
                1100.0000,
                55.0000,
                144.8900,
                4.3467,
                310.2700,
                9.3081,
                305.4153,
                0.0000,
                74.5300,
                2.5000,
                0.00,
                0.00,
                0.00,
                0.00,
                5.00,
                0.00,
                5.00,
                300000.0,
            ],
            False,
        ),
        (
            3,
            "3 CuPc pattern 24",
            [
                1100.0000,
                55.0000,
                129.2900,
                3.8787,
                419.2200,
                12.5766,
                450.5573,
                0.0000,
                95.5800,
                2.5000,
                0.00,
                0.00,
                0.00,
                0.00,
                5.00,
                0.00,
                5.00,
                300000.0,
            ],
            False,
        ),
        (
            4,
            "4 CuPc pattern 29",
            [
                1100.0000,
                55.0000,
                86.2100,
                2.5863,
                370.6000,
                11.1180,
                379.5663,
                0.0000,
                89.3670,
                2.5000,
                0.00,
                0.00,
                0.00,
                0.00,
                5.00,
                0.00,
                5.00,
                300000.0,
            ],
            False,
        ),
        (
            5,
            "5 CuPc pattern 30",
            [
                1100.0000,
                55.0000,
                86.2600,
                2.5878,
                414.9200,
                12.4476,
                433.3040,
                0.0000,
                96.5400,
                2.5000,
                0.00,
                0.00,
                0.00,
                0.00,
                5.00,
                0.00,
                5.00,
                300000.0,
            ],
            False,
        ),
        (
            6,
            "6 CuPc pattern 31",
            [
                1100.0000,
                55.0000,
                86.2600,
                2.5878,
                511.5500,
                15.3465,
                512.6692,
                0.0000,
                85.9100,
                2.5000,
                0.00,
                0.00,
                0.00,
                0.00,
                5.00,
                0.00,
                5.00,
                300000.0,
            ],
            False,
        ),
        (
            7,
            "7 CuPc pattern 32",
            [
                1100.0000,
                55.0000,
                77.7300,
                2.3319,
                76.1300,
                2.2839,
                86.0699,
                0.0000,
                68.0200,
                2.5000,
                0.00,
                0.00,
                0.00,
                0.00,
                5.00,
                0.00,
                5.00,
                300000.0,
            ],
            False,
        ),
    ]
    selection = piep_core.select_reference_pattern_from_fields(cupc_patterns, 200000.0, 5.0, 5.0)
    assert selection["reference_slot"] == 7
    assert selection["search_mode"] == 0
    assert selection["active_sequence_slots"] == [4, 5, 1, 2, 6, 3]

    grid = piep_core.initialize_search_grid_from_fields(
        cupc_patterns,
        0.0,
        1000.0,
        "absolute",
        0.025,
        200000.0,
        5.0,
        5.0,
    )
    assert grid["status"] == 0
    assert grid["layer_count"] == 12
    assert grid["total_grid_points"] == 786
    assert grid["first_layer_plane"]["count"] == 56

    generated = piep_core.generate_search_candidates_from_fields(
        cupc_patterns,
        0.0,
        1000.0,
        "absolute",
        0.025,
        200000.0,
        5.0,
        5.0,
        reduction_cosine_limit=0.5,
        candidate_limit=3,
    )
    assert generated["status"] == 0
    assert generated["total_candidate_count"] == 786
    assert generated["truncated"] is True
    assert len(generated["candidates"]) == 3
    assert generated["layers"][0]["point_count"] == 56
    assert math.isclose(generated["candidates"][0]["x"], 0.0)
    assert math.isclose(generated["candidates"][0]["y"], 0.0)

    synthetic = piep_core.simulate_pattern_from_indices(
        "synthetic",
        8.1,
        10.3,
        12.7,
        91.2,
        103.4,
        109.8,
        [1, 1, 0],
        [0, 1, 1],
        500.0,
        2.0,
        0.2,
        200000.0,
    )
    assert synthetic["title"] == "synthetic"
    assert synthetic["fields"][2] > 0.0
    assert synthetic["fields"][8] > 0.0

    zones = piep_core.enumerate_zone_axes(1)
    assert [0, 0, 1] in zones

    simulated_zone = piep_core.simulate_zone_pattern(
        "cubic [001]",
        10.0,
        10.0,
        10.0,
        90.0,
        90.0,
        90.0,
        [0.0, 0.0, 1.0],
        1000.0,
        150.0,
    )
    assert simulated_zone["spot_count"] > 0
    assert simulated_zone["default_basis_pair"] is not None
    assert any(spot["hkl"] == [1, 0, 0] for spot in simulated_zone["spots"])

    simulated_ensemble = piep_core.simulate_zone_observation_ensemble(
        "cubic",
        10.0,
        10.0,
        10.0,
        90.0,
        90.0,
        90.0,
        [
            [0.0, 0.0, 1.0],
            [0.1, 1.0, 0.0, 0.0, 0.11],
        ],
        1000.0,
        180.0,
        realizations_per_zone=1,
        positional_sigma_mm=0.25,
        reported_radius_sigma_mm=0.25,
        reported_angle_sigma_deg=1.5,
        camera_constant_sigma=5.0,
        high_voltage_volts=200000.0,
        seed=1234,
    )
    assert len(simulated_ensemble["patterns"]) == 2
    assert len(simulated_ensemble["observations"]) == 2
    assert simulated_ensemble["skipped_zones"] == []
    assert simulated_ensemble["observations"][0]["observation"]["fields"][18 - 1] == 200000.0

    enumerated = piep_core.enumerate_reflections_from_fields(
        "1 CuPc pattern 19",
        pattern_fields,
        17.3289,
        25.5672,
        3.8175,
        89.80,
        95.35,
        91.30,
        "C",
        200000.0,
        5.0,
        5.0,
    )
    assert enumerated["overflow"] is False
    assert enumerated["first_pool_count"] > 0
    assert enumerated["second_pool_count"] > 0

    indexed = piep_core.index_pattern_from_fields(
        "1 CuPc pattern 19",
        pattern_fields,
        17.3289,
        25.5672,
        3.8175,
        89.80,
        95.35,
        91.30,
        "C",
        200000.0,
        5.0,
        5.0,
    )
    assert indexed["overflow"] is False
    assert indexed["centering"] == "C"
    top_match = indexed["matches"][0]
    assert top_match["first_hkl"] == [1, 3, 0]
    assert top_match["second_hkl"] == [1, -1, -1]
    assert top_match["zone_axis"] == [-3, 1, -4]
    assert math.isclose(top_match["predicted_camera_constant"], 1099.0, abs_tol=2.0)

    evaluated_candidate = piep_core.evaluate_candidate_cell_from_fields(
        cupc_patterns,
        17.3289,
        25.5672,
        3.8175,
        89.80,
        95.35,
        91.30,
        "C",
        200000.0,
        5.0,
        5.0,
    )
    assert evaluated_candidate["status"] == 0
    assert evaluated_candidate["aggregate_figure_of_merit"] < 3.0
    assert len(evaluated_candidate["pattern_matches"]) == len(cupc_patterns)

    searched = piep_core.search_unit_cells_from_fields(
        cupc_patterns,
        0.0,
        1000.0,
        "absolute",
        0.025,
        "C",
        200000.0,
        5.0,
        5.0,
    )
    assert searched["setup"]["status"] == 0
    assert searched["total_candidate_count"] == 786
    assert searched["evaluated_candidate_count"] == 786
    assert len(searched["candidates"]) >= 1
    top_cell = searched["candidates"][0]["evaluation"]["reduced_cell"]
    assert 3.0 < top_cell[0] < 4.5

    case = piep.cupc_case()
    api_search = piep.search_and_conventionalize(
        case.patterns,
        volume_min=case.volume_min,
        volume_max=case.volume_max,
        centering=case.centering,
        preferred_centering=case.preferred_centering,
        minimum_system=case.minimum_system,
        top_n=3,
    )
    assert api_search.preferred_candidate is not None
    assert api_search.preferred_candidate.preferred_candidate is not None
    assert api_search.preferred_candidate.preferred_candidate.centering == "C"

    print("Python bindings smoke test passed.")


if __name__ == "__main__":
    main()
