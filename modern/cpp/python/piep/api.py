from __future__ import annotations

from dataclasses import dataclass, field
from typing import Any, Iterable, Mapping, Sequence

import piep_core

SYSTEM_NAMES = {
    1: "triclinic",
    2: "monoclinic",
    3: "orthorhombic",
    4: "tetragonal",
    5: "hexagonal",
    6: "cubic",
}


def _copy_raw(raw: Mapping[str, Any]) -> dict[str, Any]:
    return dict(raw)


@dataclass(frozen=True)
class Cell:
    a: float
    b: float
    c: float
    alpha_deg: float
    beta_deg: float
    gamma_deg: float

    def as_tuple(self) -> tuple[float, float, float, float, float, float]:
        return (self.a, self.b, self.c, self.alpha_deg, self.beta_deg, self.gamma_deg)

    @classmethod
    def from_sequence(cls, values: Sequence[float]) -> "Cell":
        if len(values) != 6:
            raise ValueError("cell values must contain exactly 6 numbers")
        return cls(*[float(value) for value in values])


@dataclass(frozen=True)
class PatternObservation:
    title: str
    camera_constant: float
    camera_constant_sigma: float
    first_radius: float
    first_radius_sigma: float
    second_radius: float
    second_radius_sigma: float
    third_radius: float
    third_radius_sigma: float
    angle_deg: float
    angle_sigma_deg: float
    goniometer_alpha_deg: float = 0.0
    goniometer_beta_deg: float = 0.0
    goniometer_mode: float = 0.0
    laue_zone_zero_input: float = 0.0
    laue_zone_zero_sigma: float = 0.0
    laue_zone_one_minus_zero_input: float = 0.0
    laue_zone_one_minus_zero_sigma: float = 0.0
    high_voltage_volts: float = 0.0
    wavelength_override_angstrom: float = 0.0

    def legacy_fields(self) -> list[float]:
        return [
            self.camera_constant,
            self.camera_constant_sigma,
            self.first_radius,
            self.first_radius_sigma,
            self.second_radius,
            self.second_radius_sigma,
            self.third_radius,
            self.third_radius_sigma,
            self.angle_deg,
            self.angle_sigma_deg,
            self.goniometer_alpha_deg,
            self.goniometer_beta_deg,
            self.goniometer_mode,
            self.laue_zone_zero_input,
            self.laue_zone_zero_sigma,
            self.laue_zone_one_minus_zero_input,
            self.laue_zone_one_minus_zero_sigma,
            self.high_voltage_volts,
        ]

    def as_binding_tuple(self) -> tuple[str, list[float]]:
        return (self.title, self.legacy_fields())

    @classmethod
    def from_legacy_fields(cls, title: str, fields: Sequence[float]) -> "PatternObservation":
        if len(fields) != 18:
            raise ValueError("legacy SAD field lists must contain exactly 18 numbers")
        numeric = [float(value) for value in fields]
        return cls(title, *numeric)

    @classmethod
    def from_binding_dict(
        cls, payload: Mapping[str, Any], wavelength_override_angstrom: float = 0.0
    ) -> "PatternObservation":
        return cls.from_legacy_fields(payload["title"], payload["fields"]).with_wavelength_override(
            wavelength_override_angstrom
        )

    @classmethod
    def from_reciprocal_vectors(
        cls,
        title: str,
        first_vector_inverse_angstrom: Sequence[float],
        second_vector_inverse_angstrom: Sequence[float],
        camera_constant: float,
        *,
        camera_constant_sigma: float = 0.0,
        first_length_sigma_inverse_angstrom: float = 0.0,
        second_length_sigma_inverse_angstrom: float = 0.0,
        angle_sigma_deg: float = 2.5,
        third_radius_sigma: float = 0.0,
        high_voltage_volts: float = 0.0,
        wavelength_angstrom: float = 0.0,
    ) -> "PatternObservation":
        raw = piep_core.observation_from_reciprocal_vectors(
            title,
            list(first_vector_inverse_angstrom),
            list(second_vector_inverse_angstrom),
            camera_constant,
            camera_constant_sigma,
            first_length_sigma_inverse_angstrom,
            second_length_sigma_inverse_angstrom,
            angle_sigma_deg,
            third_radius_sigma,
            high_voltage_volts,
            wavelength_angstrom,
        )
        return cls.from_binding_dict(raw, wavelength_override_angstrom=wavelength_angstrom)

    @classmethod
    def from_detector_geometry(
        cls,
        title: str,
        first_spot_pixels: Sequence[float],
        second_spot_pixels: Sequence[float],
        direct_beam_pixels: Sequence[float],
        detector_distance_mm: float,
        wavelength_angstrom: float,
        pixel_size_x_mm: float,
        *,
        pixel_size_y_mm: float | None = None,
        camera_constant_sigma: float = 0.0,
        radius_sigma_mm: float = 0.0,
        angle_sigma_deg: float = 2.5,
        third_radius_sigma: float = 0.0,
        high_voltage_volts: float = 0.0,
    ) -> "PatternObservation":
        raw = piep_core.observation_from_detector_geometry(
            title,
            list(first_spot_pixels),
            list(second_spot_pixels),
            list(direct_beam_pixels),
            detector_distance_mm,
            wavelength_angstrom,
            pixel_size_x_mm,
            pixel_size_x_mm if pixel_size_y_mm is None else pixel_size_y_mm,
            camera_constant_sigma,
            radius_sigma_mm,
            angle_sigma_deg,
            third_radius_sigma,
            high_voltage_volts,
        )
        return cls.from_binding_dict(raw, wavelength_override_angstrom=wavelength_angstrom)

    def with_wavelength_override(self, wavelength_override_angstrom: float) -> "PatternObservation":
        return PatternObservation(
            self.title,
            self.camera_constant,
            self.camera_constant_sigma,
            self.first_radius,
            self.first_radius_sigma,
            self.second_radius,
            self.second_radius_sigma,
            self.third_radius,
            self.third_radius_sigma,
            self.angle_deg,
            self.angle_sigma_deg,
            self.goniometer_alpha_deg,
            self.goniometer_beta_deg,
            self.goniometer_mode,
            self.laue_zone_zero_input,
            self.laue_zone_zero_sigma,
            self.laue_zone_one_minus_zero_input,
            self.laue_zone_one_minus_zero_sigma,
            self.high_voltage_volts,
            wavelength_override_angstrom,
        )


@dataclass(frozen=True)
class SearchPattern:
    slot: int
    observation: PatternObservation
    excluded: bool = False

    def as_binding_record(self) -> tuple[int, str, list[float], bool]:
        return (self.slot, self.observation.title, self.observation.legacy_fields(), self.excluded)


@dataclass(frozen=True)
class SearchDefaults:
    default_high_voltage_volts: float = 200000.0
    default_laue_zone_zero_sigma: float = 5.0
    default_laue_zone_one_sigma: float = 5.0


@dataclass(frozen=True)
class DelaunayReduction:
    primitive_input_cell: Cell
    reduced_primitive_cell: Cell
    raw: dict[str, Any] = field(repr=False)

    @classmethod
    def from_raw(cls, raw: Mapping[str, Any]) -> "DelaunayReduction":
        return cls(
            primitive_input_cell=Cell.from_sequence(raw["primitive_input_cell"]),
            reduced_primitive_cell=Cell.from_sequence(raw["reduced_primitive_cell"]),
            raw=_copy_raw(raw),
        )


@dataclass(frozen=True)
class ReducedCellComparison:
    lhs_reduced: Cell
    rhs_reduced: Cell
    alpha_error_deg: float
    beta_error_deg: float
    gamma_error_deg: float
    equivalent: bool
    raw: dict[str, Any] = field(repr=False)

    @classmethod
    def from_raw(cls, raw: Mapping[str, Any]) -> "ReducedCellComparison":
        return cls(
            lhs_reduced=Cell.from_sequence(raw["lhs_reduced"]),
            rhs_reduced=Cell.from_sequence(raw["rhs_reduced"]),
            alpha_error_deg=float(raw["alpha_error_deg"]),
            beta_error_deg=float(raw["beta_error_deg"]),
            gamma_error_deg=float(raw["gamma_error_deg"]),
            equivalent=bool(raw["equivalent"]),
            raw=_copy_raw(raw),
        )


@dataclass(frozen=True)
class ConventionalCandidate:
    system: str
    legacy_system: str
    centering: str
    cell: Cell
    strict_error: float
    legacy_error: float
    transform_complexity: int
    raw: dict[str, Any] = field(repr=False)

    @classmethod
    def from_raw(cls, raw: Mapping[str, Any]) -> "ConventionalCandidate":
        return cls(
            system=str(raw.get("strict_system_name", SYSTEM_NAMES[int(raw["strict_system"])])),
            legacy_system=str(raw.get("legacy_system_name", SYSTEM_NAMES[int(raw["legacy_system"])])),
            centering=str(raw["centering"]),
            cell=Cell.from_sequence(raw["cell"]),
            strict_error=float(raw["strict_error"]),
            legacy_error=float(raw["legacy_error"]),
            transform_complexity=int(raw["transform_complexity"]),
            raw=_copy_raw(raw),
        )


@dataclass(frozen=True)
class Conventionalization:
    primitive_input_cell: Cell
    reduced_primitive_cell: Cell
    candidates: list[ConventionalCandidate]
    preferred_candidate: ConventionalCandidate | None
    raw: dict[str, Any] = field(repr=False)

    @classmethod
    def from_raw(cls, raw: Mapping[str, Any]) -> "Conventionalization":
        candidates = [ConventionalCandidate.from_raw(candidate) for candidate in raw["candidates"]]
        preferred_raw = raw.get("preferred_candidate")
        return cls(
            primitive_input_cell=Cell.from_sequence(raw["primitive_input_cell"]),
            reduced_primitive_cell=Cell.from_sequence(raw["reduced_primitive_cell"]),
            candidates=candidates,
            preferred_candidate=None if preferred_raw is None else ConventionalCandidate.from_raw(preferred_raw),
            raw=_copy_raw(raw),
        )


@dataclass(frozen=True)
class CandidateSummary:
    direct_cell: Cell
    reduced_cell: Cell
    figure_of_merit: float
    accumulated_support: float
    normalized_support: float
    raw: dict[str, Any] = field(repr=False)

    @classmethod
    def from_raw(cls, raw: Mapping[str, Any]) -> "CandidateSummary":
        evaluation = raw["evaluation"]
        return cls(
            direct_cell=Cell.from_sequence(evaluation["candidate"]["direct_cell"]),
            reduced_cell=Cell.from_sequence(evaluation["reduced_cell"]),
            figure_of_merit=float(evaluation["aggregate_figure_of_merit"]),
            accumulated_support=float(raw["accumulated_support"]),
            normalized_support=float(raw["normalized_support"]),
            raw=_copy_raw(raw),
        )


@dataclass(frozen=True)
class SearchResult:
    total_candidate_count: int
    evaluated_candidate_count: int
    duplicate_rejection_count: int
    candidates: list[CandidateSummary]
    raw: dict[str, Any] = field(repr=False)

    @classmethod
    def from_raw(cls, raw: Mapping[str, Any]) -> "SearchResult":
        return cls(
            total_candidate_count=int(raw["total_candidate_count"]),
            evaluated_candidate_count=int(raw["evaluated_candidate_count"]),
            duplicate_rejection_count=int(raw["duplicate_rejection_count"]),
            candidates=[CandidateSummary.from_raw(candidate) for candidate in raw["candidates"]],
            raw=_copy_raw(raw),
        )


@dataclass(frozen=True)
class SearchCandidateEvaluation:
    reduced_cell: Cell
    figure_of_merit: float
    pattern_match_count: int
    raw: dict[str, Any] = field(repr=False)

    @classmethod
    def from_raw(cls, raw: Mapping[str, Any]) -> "SearchCandidateEvaluation":
        return cls(
            reduced_cell=Cell.from_sequence(raw["reduced_cell"]),
            figure_of_merit=float(raw["aggregate_figure_of_merit"]),
            pattern_match_count=len(raw["pattern_matches"]),
            raw=_copy_raw(raw),
        )


@dataclass(frozen=True)
class IndexingMatch:
    first_hkl: tuple[int, int, int]
    second_hkl: tuple[int, int, int]
    zone_axis: tuple[int, int, int]
    figure_of_merit: float
    predicted_camera_constant: float
    raw: dict[str, Any] = field(repr=False)

    @classmethod
    def from_raw(cls, raw: Mapping[str, Any]) -> "IndexingMatch":
        return cls(
            first_hkl=tuple(int(value) for value in raw["first_hkl"]),
            second_hkl=tuple(int(value) for value in raw["second_hkl"]),
            zone_axis=tuple(int(value) for value in raw["zone_axis"]),
            figure_of_merit=float(raw["figure_of_merit"]),
            predicted_camera_constant=float(raw["predicted_camera_constant"]),
            raw=_copy_raw(raw),
        )


@dataclass(frozen=True)
class PatternIndexing:
    centering: str
    matches: list[IndexingMatch]
    raw: dict[str, Any] = field(repr=False)

    @property
    def top_match(self) -> IndexingMatch | None:
        return None if not self.matches else self.matches[0]

    @classmethod
    def from_raw(cls, raw: Mapping[str, Any]) -> "PatternIndexing":
        return cls(
            centering=str(raw["centering"]),
            matches=[IndexingMatch.from_raw(match) for match in raw["matches"]],
            raw=_copy_raw(raw),
        )


@dataclass(frozen=True)
class SearchPipelineCandidate:
    search_candidate: CandidateSummary
    conventionalization: Conventionalization

    @property
    def preferred_candidate(self) -> ConventionalCandidate | None:
        return self.conventionalization.preferred_candidate


@dataclass(frozen=True)
class SearchPipelineResult:
    search: SearchResult
    candidates: list[SearchPipelineCandidate]

    @property
    def preferred_candidate(self) -> SearchPipelineCandidate | None:
        return None if not self.candidates else self.candidates[0]


@dataclass(frozen=True)
class ZoneDirection:
    u: float
    v: float
    w: float
    target: float = 0.0
    tolerance: float = 0.0

    def as_binding_value(self) -> list[float]:
        if self.target == 0.0 and self.tolerance == 0.0:
            return [self.u, self.v, self.w]
        return [self.u, self.v, self.w, self.target, self.tolerance]


@dataclass(frozen=True)
class SimulatedObservation:
    title: str
    observation: PatternObservation
    raw: dict[str, Any] = field(repr=False)

    @classmethod
    def from_raw(cls, raw: Mapping[str, Any]) -> "SimulatedObservation":
        return cls(
            title=str(raw["title"]),
            observation=PatternObservation.from_binding_dict(raw["observation"]),
            raw=_copy_raw(raw),
        )


@dataclass(frozen=True)
class SimulatedEnsemble:
    observations: list[SimulatedObservation]
    raw: dict[str, Any] = field(repr=False)

    @classmethod
    def from_raw(cls, raw: Mapping[str, Any]) -> "SimulatedEnsemble":
        return cls(
            observations=[SimulatedObservation.from_raw(item) for item in raw["observations"]],
            raw=_copy_raw(raw),
        )


def simulate_observation_from_zone_pair(
    cell: Cell,
    zone: ZoneDirection,
    first_hkl: Sequence[int],
    second_hkl: Sequence[int],
    *,
    title: str,
    camera_constant: float,
    maximum_radius_mm: float,
    centering: str = "P",
    minimum_radius_mm: float = 0.0,
    include_friedel_mates: bool = True,
    include_origin: bool = False,
    reciprocal_length_padding_fraction: float = 0.02,
    maximum_spot_count: int = 0,
    positional_sigma_mm: float = 0.0,
    reported_radius_sigma_mm: float = 0.0,
    reported_angle_sigma_deg: float = 2.5,
    camera_constant_sigma: float = 0.0,
    high_voltage_volts: float = 0.0,
    seed: int = 0,
) -> SimulatedObservation:
    raw = piep_core.simulate_observation_from_zone_pair(
        title,
        *cell.as_tuple(),
        zone.as_binding_value(),
        list(first_hkl),
        list(second_hkl),
        camera_constant,
        maximum_radius_mm,
        centering,
        minimum_radius_mm,
        include_friedel_mates,
        include_origin,
        reciprocal_length_padding_fraction,
        maximum_spot_count,
        positional_sigma_mm,
        reported_radius_sigma_mm,
        reported_angle_sigma_deg,
        camera_constant_sigma,
        high_voltage_volts,
        seed,
    )
    return SimulatedObservation.from_raw(raw)


def _binding_defaults(defaults: SearchDefaults) -> tuple[float, float, float]:
    return (
        defaults.default_high_voltage_volts,
        defaults.default_laue_zone_zero_sigma,
        defaults.default_laue_zone_one_sigma,
    )


def _binding_patterns(patterns: Iterable[SearchPattern]) -> list[tuple[int, str, list[float], bool]]:
    return [pattern.as_binding_record() for pattern in patterns]


def restore_pattern(observation: PatternObservation, defaults: SearchDefaults = SearchDefaults()) -> dict[str, Any]:
    high_voltage, zero_sigma, one_sigma = _binding_defaults(defaults)
    return piep_core.restore_pattern_from_fields(
        observation.title,
        observation.legacy_fields(),
        high_voltage,
        zero_sigma,
        one_sigma,
    )


def prepare_pattern(observation: PatternObservation, defaults: SearchDefaults = SearchDefaults()) -> dict[str, Any]:
    high_voltage, zero_sigma, one_sigma = _binding_defaults(defaults)
    return piep_core.prepare_pattern_from_fields(
        observation.title,
        observation.legacy_fields(),
        high_voltage,
        zero_sigma,
        one_sigma,
    )


def delaunay_reduce_cell(cell: Cell, centering: str = "P") -> DelaunayReduction:
    raw = piep_core.delaunay_reduce_cell(*cell.as_tuple(), centering=centering)
    return DelaunayReduction.from_raw(raw)


def compare_reduced_cells(
    lhs: Cell,
    rhs: Cell,
    *,
    lhs_centering: str = "P",
    rhs_centering: str = "P",
    angle_tolerance_deg: float = 2.0,
    axis_ratio_relative_tolerance: float = 0.05,
) -> ReducedCellComparison:
    raw = piep_core.compare_reduced_cells(
        *lhs.as_tuple(),
        lhs_centering,
        *rhs.as_tuple(),
        rhs_centering,
        angle_tolerance_deg,
        axis_ratio_relative_tolerance,
    )
    return ReducedCellComparison.from_raw(raw)


def conventionalize_cell(
    cell: Cell,
    *,
    centering: str = "P",
    preferred_centering: str = "",
    minimum_system: str = "triclinic",
    strict_angle_deg: float = 2.0,
    strict_axis_relative: float = 0.05,
    legacy_angle_deg: float = 4.0,
    legacy_axis_relative: float = 0.10,
) -> Conventionalization:
    raw = piep_core.conventionalize_cell(
        *cell.as_tuple(),
        centering,
        preferred_centering,
        minimum_system,
        strict_angle_deg,
        strict_axis_relative,
        legacy_angle_deg,
        legacy_axis_relative,
    )
    return Conventionalization.from_raw(raw)


def evaluate_candidate(
    patterns: Sequence[SearchPattern],
    cell: Cell,
    *,
    centering: str = "P",
    defaults: SearchDefaults = SearchDefaults(),
    max_reflections_per_pool: int = 1999,
    max_stored_matches: int = 199,
) -> SearchCandidateEvaluation:
    high_voltage, zero_sigma, one_sigma = _binding_defaults(defaults)
    raw = piep_core.evaluate_candidate_cell_from_fields(
        _binding_patterns(patterns),
        *cell.as_tuple(),
        centering,
        high_voltage,
        zero_sigma,
        one_sigma,
        max_reflections_per_pool,
        max_stored_matches,
    )
    return SearchCandidateEvaluation.from_raw(raw)


def index_pattern(
    observation: PatternObservation,
    cell: Cell,
    *,
    centering: str = "P",
    defaults: SearchDefaults = SearchDefaults(),
    max_reflections_per_pool: int = 1999,
    max_stored_matches: int = 199,
) -> PatternIndexing:
    high_voltage, zero_sigma, one_sigma = _binding_defaults(defaults)
    raw = piep_core.index_pattern_from_fields(
        observation.title,
        observation.legacy_fields(),
        *cell.as_tuple(),
        centering,
        high_voltage,
        zero_sigma,
        one_sigma,
        max_reflections_per_pool,
        max_stored_matches,
    )
    return PatternIndexing.from_raw(raw)


def search_unit_cells(
    patterns: Sequence[SearchPattern],
    *,
    volume_min: float,
    volume_max: float,
    centering: str = "P",
    increment_mode: str = "absolute",
    increment_value: float = 0.025,
    defaults: SearchDefaults = SearchDefaults(),
    wall_sigma_multiplier: float = 0.0,
    force_full_grid: bool = False,
    reduction_cosine_limit: float = 0.5,
    candidate_limit: int = 0,
    max_reflections_per_pool: int = 1999,
    max_stored_matches: int = 199,
    max_candidates: int = 100,
    duplicate_angle_tolerance_deg: float = 2.0,
    duplicate_axis_ratio_tolerance: float = 0.05,
    duplicate_support_scale: float = 5.0,
) -> SearchResult:
    high_voltage, zero_sigma, one_sigma = _binding_defaults(defaults)
    raw = piep_core.search_unit_cells_from_fields(
        _binding_patterns(patterns),
        volume_min,
        volume_max,
        increment_mode,
        increment_value,
        centering,
        high_voltage,
        zero_sigma,
        one_sigma,
        wall_sigma_multiplier,
        force_full_grid,
        reduction_cosine_limit,
        candidate_limit,
        max_reflections_per_pool,
        max_stored_matches,
        max_candidates,
        duplicate_angle_tolerance_deg,
        duplicate_axis_ratio_tolerance,
        duplicate_support_scale,
    )
    return SearchResult.from_raw(raw)


def search_and_conventionalize(
    patterns: Sequence[SearchPattern],
    *,
    volume_min: float,
    volume_max: float,
    centering: str = "P",
    increment_mode: str = "absolute",
    increment_value: float = 0.025,
    defaults: SearchDefaults = SearchDefaults(),
    preferred_centering: str = "",
    minimum_system: str = "triclinic",
    top_n: int = 10,
    search_kwargs: Mapping[str, Any] | None = None,
    conventionalization_kwargs: Mapping[str, Any] | None = None,
) -> SearchPipelineResult:
    search_kwargs = {} if search_kwargs is None else dict(search_kwargs)
    conventionalization_kwargs = {} if conventionalization_kwargs is None else dict(conventionalization_kwargs)
    search_result = search_unit_cells(
        patterns,
        volume_min=volume_min,
        volume_max=volume_max,
        centering=centering,
        increment_mode=increment_mode,
        increment_value=increment_value,
        defaults=defaults,
        **search_kwargs,
    )
    pipeline_candidates: list[SearchPipelineCandidate] = []
    for candidate in search_result.candidates[:top_n]:
        pipeline_candidates.append(
            SearchPipelineCandidate(
                search_candidate=candidate,
                conventionalization=conventionalize_cell(
                    candidate.reduced_cell,
                    centering="P",
                    preferred_centering=preferred_centering,
                    minimum_system=minimum_system,
                    **conventionalization_kwargs,
                ),
            )
        )
    return SearchPipelineResult(search=search_result, candidates=pipeline_candidates)


def simulate_zone_observation_ensemble(
    cell: Cell,
    zones: Sequence[ZoneDirection],
    *,
    title_prefix: str,
    camera_constant: float,
    maximum_radius_mm: float,
    realizations_per_zone: int = 1,
    centering: str = "P",
    minimum_radius_mm: float = 0.0,
    include_friedel_mates: bool = True,
    include_origin: bool = False,
    reciprocal_length_padding_fraction: float = 0.02,
    maximum_spot_count: int = 0,
    minimum_basis_angle_deg: float = 5.0,
    maximum_basis_angle_deg: float = 175.0,
    maximum_zone_multiplicity: int = 1,
    positional_sigma_mm: float = 0.0,
    reported_radius_sigma_mm: float = 0.0,
    reported_angle_sigma_deg: float = 2.5,
    camera_constant_sigma: float = 0.0,
    high_voltage_volts: float = 0.0,
    seed: int = 0,
) -> SimulatedEnsemble:
    raw = piep_core.simulate_zone_observation_ensemble(
        title_prefix,
        *cell.as_tuple(),
        [zone.as_binding_value() for zone in zones],
        camera_constant,
        maximum_radius_mm,
        realizations_per_zone,
        centering,
        minimum_radius_mm,
        include_friedel_mates,
        include_origin,
        reciprocal_length_padding_fraction,
        maximum_spot_count,
        minimum_basis_angle_deg,
        maximum_basis_angle_deg,
        maximum_zone_multiplicity,
        positional_sigma_mm,
        reported_radius_sigma_mm,
        reported_angle_sigma_deg,
        camera_constant_sigma,
        high_voltage_volts,
        seed,
    )
    return SimulatedEnsemble.from_raw(raw)
