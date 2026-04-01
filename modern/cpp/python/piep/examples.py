from __future__ import annotations

from dataclasses import dataclass
import math

from .api import Cell, SearchPattern, PatternObservation


@dataclass(frozen=True)
class CaseStudy:
    name: str
    cell: Cell
    centering: str
    preferred_centering: str
    minimum_system: str
    volume_min: float
    volume_max: float
    expected_candidate_count: int
    patterns: list[SearchPattern]

    @property
    def exact_volume(self) -> float:
        return (
            self.cell.a
            * self.cell.b
            * self.cell.c
            * (
                1.0
                - (
                    math.cos(math.radians(self.cell.alpha_deg)) ** 2
                    + math.cos(math.radians(self.cell.beta_deg)) ** 2
                    + math.cos(math.radians(self.cell.gamma_deg)) ** 2
                )
                + 2.0
                * math.cos(math.radians(self.cell.alpha_deg))
                * math.cos(math.radians(self.cell.beta_deg))
                * math.cos(math.radians(self.cell.gamma_deg))
            )
            ** 0.5
        )


def _pattern(slot: int, title: str, fields: list[float], excluded: bool = False) -> SearchPattern:
    return SearchPattern(slot=slot, observation=PatternObservation.from_legacy_fields(title, fields), excluded=excluded)


def cupc_case() -> CaseStudy:
    return CaseStudy(
        name="CuPc",
        cell=Cell(17.3289, 25.5672, 3.8175, 89.80, 95.35, 91.30),
        centering="C",
        preferred_centering="C",
        minimum_system="monoclinic",
        volume_min=0.0,
        volume_max=1000.0,
        expected_candidate_count=786,
        patterns=[
            _pattern(1, "1 CuPc pattern 19", [1100.0000, 55.0000, 145.0000, 4.3500, 293.2600, 8.7978, 334.5031, 0.0000, 93.2800, 2.5000, 0.0, 0.0, 0.0, 0.0, 5.0, 0.0, 5.0, 300000.0]),
            _pattern(2, "2 CuPc pattern 20", [1100.0000, 55.0000, 144.8900, 4.3467, 310.2700, 9.3081, 305.4153, 0.0000, 74.5300, 2.5000, 0.0, 0.0, 0.0, 0.0, 5.0, 0.0, 5.0, 300000.0]),
            _pattern(3, "3 CuPc pattern 24", [1100.0000, 55.0000, 129.2900, 3.8787, 419.2200, 12.5766, 450.5573, 0.0000, 95.5800, 2.5000, 0.0, 0.0, 0.0, 0.0, 5.0, 0.0, 5.0, 300000.0]),
            _pattern(4, "4 CuPc pattern 29", [1100.0000, 55.0000, 86.2100, 2.5863, 370.6000, 11.1180, 379.5663, 0.0000, 89.3670, 2.5000, 0.0, 0.0, 0.0, 0.0, 5.0, 0.0, 5.0, 300000.0]),
            _pattern(5, "5 CuPc pattern 30", [1100.0000, 55.0000, 86.2600, 2.5878, 414.9200, 12.4476, 433.3040, 0.0000, 96.5400, 2.5000, 0.0, 0.0, 0.0, 0.0, 5.0, 0.0, 5.0, 300000.0]),
            _pattern(6, "6 CuPc pattern 31", [1100.0000, 55.0000, 86.2600, 2.5878, 511.5500, 15.3465, 512.6692, 0.0000, 85.9100, 2.5000, 0.0, 0.0, 0.0, 0.0, 5.0, 0.0, 5.0, 300000.0]),
            _pattern(7, "7 CuPc pattern 32", [1100.0000, 55.0000, 77.7300, 2.3319, 76.1300, 2.2839, 86.0699, 0.0000, 68.0200, 2.5000, 0.0, 0.0, 0.0, 0.0, 5.0, 0.0, 5.0, 300000.0]),
        ],
    )


def grgds_case() -> CaseStudy:
    return CaseStudy(
        name="GRGDS",
        cell=Cell(28.6756, 4.4446, 19.4660, 90.00, 105.47, 89.98),
        centering="C",
        preferred_centering="C",
        minimum_system="monoclinic",
        volume_min=0.0,
        volume_max=1500.0,
        expected_candidate_count=8642,
        patterns=[
            _pattern(1, "1 2.32", [358.9000, 17.5930, 25.9724, 0.7792, 81.7823, 2.4535, 81.7925, 0.0000, 80.8861, 2.5000, 0.0, 0.0, 0.0, 0.0, 5.0, 0.0, 5.0, 200000.0]),
            _pattern(2, "2 2.71", [358.9000, 17.5930, 27.7292, 0.8319, 91.8230, 2.7547, 93.8435, 0.0000, 85.5651, 2.5000, 0.0, 0.0, 0.0, 0.0, 5.0, 0.0, 5.0, 200000.0]),
            _pattern(3, "3 3.21", [358.9000, 17.5930, 50.5200, 1.5156, 81.2344, 2.4370, 88.5512, 0.0000, 80.8163, 2.5000, 0.0, 0.0, 0.0, 0.0, 5.0, 0.0, 5.0, 200000.0]),
            _pattern(4, "4 4.39", [358.9000, 17.5930, 75.3997, 2.2620, 81.6313, 2.4489, 101.5291, 0.0000, 80.4580, 2.5000, 0.0, 0.0, 0.0, 0.0, 5.0, 0.0, 5.0, 200000.0]),
            _pattern(5, "5 3.3", [358.9000, 17.5930, 27.6289, 0.8289, 244.3731, 7.3312, 245.4994, 0.0000, 89.1019, 2.5000, 0.0, 0.0, 0.0, 0.0, 5.0, 0.0, 5.0, 200000.0]),
        ],
    )


def lysozyme_case() -> CaseStudy:
    cell = Cell(79.0641, 79.0641, 38.2168, 90.00, 90.00, 90.00)
    return CaseStudy(
        name="Lysozyme",
        cell=cell,
        centering="P",
        preferred_centering="P",
        minimum_system="orthorhombic",
        volume_min=0.0,
        volume_max=300000.0,
        expected_candidate_count=102,
        patterns=[
            _pattern(1, "1 P.2.0434 [001]", [719.420, 35.971, 9.0992, 0.2730, 9.0992, 0.2730, 12.8682, 0.0000, 90.0000, 2.5000, 0.0, 0.0, 0.0, 0.0, 5.0, 0.0, 5.0, 200000.0]),
            _pattern(2, "2 P.2.0038", [719.420, 35.971, 9.2851, 0.2786, 111.3000, 3.3390, 111.6866, 0.0000, 90.0000, 2.5000, 0.0, 0.0, 0.0, 0.0, 5.0, 0.0, 5.0, 200000.0]),
            _pattern(3, "3 P.2.0063", [719.420, 35.971, 9.1075, 0.2732, 49.0000, 1.4700, 49.8392, 0.0000, 90.0000, 2.5000, 0.0, 0.0, 0.0, 0.0, 5.0, 0.0, 5.0, 200000.0]),
            _pattern(4, "4 P.2.1152", [719.420, 35.971, 9.3286, 0.2799, 75.5000, 2.2650, 76.0741, 0.0000, 90.0000, 2.5000, 0.0, 0.0, 0.0, 0.0, 5.0, 0.0, 5.0, 200000.0]),
            _pattern(5, "5 P.2.0836", [719.420, 35.971, 9.1996, 0.2760, 84.4000, 2.5320, 84.8999, 0.0000, 90.0000, 2.5000, 0.0, 0.0, 0.0, 0.0, 5.0, 0.0, 5.0, 200000.0]),
            _pattern(6, "6 P.2.0974", [719.420, 35.971, 9.0334, 0.2710, 59.5000, 1.7850, 60.1818, 0.0000, 90.0000, 2.5000, 0.0, 0.0, 0.0, 0.0, 5.0, 0.0, 5.0, 200000.0]),
        ],
    )


def archived_cases() -> list[CaseStudy]:
    return [cupc_case(), grgds_case(), lysozyme_case()]
