#pragma once

#include <algorithm>
#include <array>
#include <cmath>
#include <cstddef>
#include <cstdint>
#include <limits>
#include <optional>
#include <stdexcept>
#include <utility>
#include <vector>

#include "piep/crystal/cell.hpp"
#include "piep/math/matrix3.hpp"

namespace piep::postprocessing {

enum class CrystalSystem {
    triclinic = 1,
    monoclinic = 2,
    orthorhombic = 3,
    tetragonal = 4,
    hexagonal = 5,
    cubic = 6,
};

struct SymmetryTolerances {
    double angle_deg {2.0};
    double axis_relative {0.05};
};

struct ReducedCellComparisonSettings {
    double angle_tolerance_deg {2.0};
    double axis_ratio_relative_tolerance {0.05};
};

struct DelaunayReductionResult {
    crystal::CellParameters primitive_input_cell {};
    crystal::CellParameters reduced_primitive_cell {};
};

struct ReducedCellComparison {
    crystal::CellParameters lhs_reduced {};
    crystal::CellParameters rhs_reduced {};
    double lhs_ab_ratio {};
    double rhs_ab_ratio {};
    double lhs_cb_ratio {};
    double rhs_cb_ratio {};
    double alpha_error_deg {};
    double beta_error_deg {};
    double gamma_error_deg {};
    bool equivalent {};
};

struct ConventionalCandidate {
    CrystalSystem strict_system {CrystalSystem::triclinic};
    CrystalSystem legacy_system {CrystalSystem::triclinic};
    char centering {'P'};
    crystal::CellParameters cell {};
    math::Matrix3 reduced_to_conventional {};
    math::Matrix3 conventional_to_reduced {};
    double strict_error {};
    double legacy_error {};
    int transform_complexity {};
    std::array<int, 9> rounded_transform {};
};

struct ConventionalizationSettings {
    char preferred_centering {' '};
    CrystalSystem minimum_system {CrystalSystem::triclinic};
    SymmetryTolerances strict_tolerances {};
    SymmetryTolerances legacy_tolerances {4.0, 0.10};
};

struct ConventionalizationResult {
    crystal::CellParameters input_cell {};
    char input_centering {'P'};
    crystal::CellParameters primitive_input_cell {};
    crystal::CellParameters reduced_primitive_cell {};
    std::vector<ConventionalCandidate> candidates {};
    std::optional<ConventionalCandidate> preferred_candidate {};
};

namespace detail {

[[nodiscard]] constexpr auto normalized_centering(char centering) -> char {
    if (centering >= 'a' && centering <= 'z') {
        return static_cast<char>(centering - ('a' - 'A'));
    }
    return centering == ' ' ? 'P' : centering;
}

[[nodiscard]] constexpr auto to_index(CrystalSystem system) -> int {
    return static_cast<int>(system);
}

[[nodiscard]] inline auto axis_ratio_ab(const crystal::CellParameters& cell) -> double {
    return cell.b > 0.0 ? cell.a / cell.b : 0.0;
}

[[nodiscard]] inline auto axis_ratio_cb(const crystal::CellParameters& cell) -> double {
    return cell.b > 0.0 ? cell.c / cell.b : 0.0;
}

[[nodiscard]] inline auto close_reduced_cells(const crystal::CellParameters& lhs,
                                              const crystal::CellParameters& rhs,
                                              const ReducedCellComparisonSettings& settings) -> bool {
    const double lhs_ab_ratio = axis_ratio_ab(lhs);
    const double rhs_ab_ratio = axis_ratio_ab(rhs);
    const double lhs_cb_ratio = axis_ratio_cb(lhs);
    const double rhs_cb_ratio = axis_ratio_cb(rhs);

    return rhs_ab_ratio > 0.0 && rhs_cb_ratio > 0.0 &&
           std::abs(lhs_ab_ratio / rhs_ab_ratio - 1.0) <= settings.axis_ratio_relative_tolerance &&
           std::abs(lhs_cb_ratio / rhs_cb_ratio - 1.0) <= settings.axis_ratio_relative_tolerance &&
           std::abs(lhs.alpha_deg - rhs.alpha_deg) <= settings.angle_tolerance_deg &&
           std::abs(lhs.beta_deg - rhs.beta_deg) <= settings.angle_tolerance_deg &&
           std::abs(lhs.gamma_deg - rhs.gamma_deg) <= settings.angle_tolerance_deg;
}

[[nodiscard]] inline auto relative_axis_difference(double lhs, double rhs) -> double {
    const double denominator = lhs + rhs;
    if (std::abs(denominator) < 1.0e-12) {
        return 0.0;
    }
    return 200.0 * std::abs(lhs - rhs) / denominator;
}

[[nodiscard]] constexpr auto system_allows_centering(CrystalSystem system, char centering) -> bool {
    const char normalized = normalized_centering(centering);
    switch (system) {
    case CrystalSystem::triclinic:
        return normalized == 'P';
    case CrystalSystem::monoclinic:
        return normalized == 'P' || normalized == 'A' || normalized == 'B' || normalized == 'C' ||
               normalized == 'I';
    case CrystalSystem::orthorhombic:
        return normalized == 'P' || normalized == 'A' || normalized == 'B' || normalized == 'C' ||
               normalized == 'F' || normalized == 'I';
    case CrystalSystem::tetragonal:
        return normalized == 'P' || normalized == 'I';
    case CrystalSystem::hexagonal:
        return normalized == 'P' || normalized == 'R';
    case CrystalSystem::cubic:
        return normalized == 'P' || normalized == 'F' || normalized == 'I';
    }
    return false;
}

[[nodiscard]] inline auto matches_system(const crystal::CellParameters& cell,
                                         CrystalSystem system,
                                         const SymmetryTolerances& tolerances) -> bool {
    if (!system_allows_centering(system, 'P')) {
        return false;
    }

    switch (system) {
    case CrystalSystem::triclinic:
        return true;
    case CrystalSystem::monoclinic:
        return std::abs(cell.alpha_deg - 90.0) <= tolerances.angle_deg &&
               std::abs(cell.gamma_deg - 90.0) <= tolerances.angle_deg;
    case CrystalSystem::orthorhombic:
        return std::abs(cell.alpha_deg - 90.0) <= tolerances.angle_deg &&
               std::abs(cell.beta_deg - 90.0) <= tolerances.angle_deg &&
               std::abs(cell.gamma_deg - 90.0) <= tolerances.angle_deg;
    case CrystalSystem::tetragonal:
        return std::abs(cell.alpha_deg - 90.0) <= tolerances.angle_deg &&
               std::abs(cell.beta_deg - 90.0) <= tolerances.angle_deg &&
               std::abs(cell.gamma_deg - 90.0) <= tolerances.angle_deg &&
               relative_axis_difference(cell.a, cell.b) <= 100.0 * tolerances.axis_relative;
    case CrystalSystem::hexagonal:
        return std::abs(cell.alpha_deg - 90.0) <= tolerances.angle_deg &&
               std::abs(cell.beta_deg - 90.0) <= tolerances.angle_deg &&
               std::abs(cell.gamma_deg - 120.0) <= tolerances.angle_deg &&
               relative_axis_difference(cell.a, cell.b) <= 100.0 * tolerances.axis_relative;
    case CrystalSystem::cubic:
        return std::abs(cell.alpha_deg - 90.0) <= tolerances.angle_deg &&
               std::abs(cell.beta_deg - 90.0) <= tolerances.angle_deg &&
               std::abs(cell.gamma_deg - 90.0) <= tolerances.angle_deg &&
               relative_axis_difference(cell.a, cell.b) <= 100.0 * tolerances.axis_relative &&
               relative_axis_difference(cell.a, cell.c) <= 100.0 * tolerances.axis_relative &&
               relative_axis_difference(cell.b, cell.c) <= 100.0 * tolerances.axis_relative;
    }
    return false;
}

[[nodiscard]] inline auto highest_matching_system(const crystal::CellParameters& cell,
                                                  char centering,
                                                  CrystalSystem minimum_system,
                                                  const SymmetryTolerances& tolerances) -> std::optional<CrystalSystem> {
    const char normalized = normalized_centering(centering);
    for (int system_index = to_index(CrystalSystem::cubic); system_index >= to_index(minimum_system); --system_index) {
        const auto system = static_cast<CrystalSystem>(system_index);
        if (!system_allows_centering(system, normalized)) {
            continue;
        }
        if (matches_system(cell, system, tolerances)) {
            return system;
        }
    }
    if (system_allows_centering(CrystalSystem::triclinic, normalized) &&
        to_index(CrystalSystem::triclinic) >= to_index(minimum_system)) {
        return CrystalSystem::triclinic;
    }
    return std::nullopt;
}

[[nodiscard]] inline auto symmetry_error(const crystal::CellParameters& cell, CrystalSystem system) -> double {
    switch (system) {
    case CrystalSystem::triclinic:
        return 0.0;
    case CrystalSystem::monoclinic:
        return std::abs(cell.alpha_deg - 90.0) + std::abs(cell.gamma_deg - 90.0);
    case CrystalSystem::orthorhombic:
        return std::abs(cell.alpha_deg - 90.0) + std::abs(cell.beta_deg - 90.0) +
               std::abs(cell.gamma_deg - 90.0);
    case CrystalSystem::tetragonal:
        return std::abs(cell.alpha_deg - 90.0) + std::abs(cell.beta_deg - 90.0) +
               std::abs(cell.gamma_deg - 90.0) + relative_axis_difference(cell.a, cell.b);
    case CrystalSystem::hexagonal:
        return std::abs(cell.alpha_deg - 90.0) + std::abs(cell.beta_deg - 90.0) +
               std::abs(cell.gamma_deg - 120.0) + relative_axis_difference(cell.a, cell.b);
    case CrystalSystem::cubic:
        return std::abs(cell.alpha_deg - 90.0) + std::abs(cell.beta_deg - 90.0) +
               std::abs(cell.gamma_deg - 90.0) + relative_axis_difference(cell.a, cell.b) +
               relative_axis_difference(cell.a, cell.c) + relative_axis_difference(cell.b, cell.c);
    }
    return std::numeric_limits<double>::infinity();
}

[[nodiscard]] inline auto rounded_transform_entry(double value) -> int {
    return static_cast<int>(std::lround(value));
}

[[nodiscard]] inline auto rounded_transform(const math::Matrix3& matrix) -> std::array<int, 9> {
    return {
        rounded_transform_entry(matrix.values[0][0]),
        rounded_transform_entry(matrix.values[1][0]),
        rounded_transform_entry(matrix.values[2][0]),
        rounded_transform_entry(matrix.values[0][1]),
        rounded_transform_entry(matrix.values[1][1]),
        rounded_transform_entry(matrix.values[2][1]),
        rounded_transform_entry(matrix.values[0][2]),
        rounded_transform_entry(matrix.values[1][2]),
        rounded_transform_entry(matrix.values[2][2]),
    };
}

[[nodiscard]] inline auto transform_complexity(const math::Matrix3& matrix) -> int {
    int complexity = 0;
    for (const int value : rounded_transform(matrix)) {
        complexity += std::abs(value);
    }
    return complexity;
}

[[nodiscard]] inline auto same_candidate_cell(const ConventionalCandidate& lhs,
                                              const ConventionalCandidate& rhs,
                                              double length_tolerance = 1.0e-3,
                                              double angle_tolerance = 5.0e-2) -> bool {
    return lhs.centering == rhs.centering &&
           std::abs(lhs.cell.a - rhs.cell.a) <= length_tolerance &&
           std::abs(lhs.cell.b - rhs.cell.b) <= length_tolerance &&
           std::abs(lhs.cell.c - rhs.cell.c) <= length_tolerance &&
           std::abs(lhs.cell.alpha_deg - rhs.cell.alpha_deg) <= angle_tolerance &&
           std::abs(lhs.cell.beta_deg - rhs.cell.beta_deg) <= angle_tolerance &&
           std::abs(lhs.cell.gamma_deg - rhs.cell.gamma_deg) <= angle_tolerance;
}

[[nodiscard]] inline auto candidate_is_better(const ConventionalCandidate& lhs,
                                              const ConventionalCandidate& rhs) -> bool {
    if (lhs.transform_complexity != rhs.transform_complexity) {
        return lhs.transform_complexity < rhs.transform_complexity;
    }
    if (std::abs(lhs.strict_error - rhs.strict_error) > 1.0e-9) {
        return lhs.strict_error < rhs.strict_error;
    }
    if (std::abs(lhs.legacy_error - rhs.legacy_error) > 1.0e-9) {
        return lhs.legacy_error < rhs.legacy_error;
    }
    return lhs.rounded_transform < rhs.rounded_transform;
}

[[nodiscard]] inline auto monoclinic_beta_penalty(const crystal::CellParameters& cell) -> int {
    return cell.beta_deg < 90.0 ? 1 : 0;
}

[[nodiscard]] inline auto monoclinic_alpha_penalty(const crystal::CellParameters& cell) -> int {
    return cell.alpha_deg > 90.0 ? 1 : 0;
}

[[nodiscard]] inline auto monoclinic_gamma_penalty(const crystal::CellParameters& cell) -> int {
    return cell.gamma_deg > 90.0 ? 1 : 0;
}

[[nodiscard]] inline auto preferred_candidate_less(const ConventionalCandidate& lhs,
                                                   const ConventionalCandidate& rhs) -> bool {
    if (lhs.transform_complexity != rhs.transform_complexity) {
        return lhs.transform_complexity < rhs.transform_complexity;
    }
    if (std::abs(lhs.strict_error - rhs.strict_error) > 1.0e-9) {
        return lhs.strict_error < rhs.strict_error;
    }
    if (lhs.strict_system == CrystalSystem::monoclinic && rhs.strict_system == CrystalSystem::monoclinic) {
        if (monoclinic_beta_penalty(lhs.cell) != monoclinic_beta_penalty(rhs.cell)) {
            return monoclinic_beta_penalty(lhs.cell) < monoclinic_beta_penalty(rhs.cell);
        }
        if (monoclinic_alpha_penalty(lhs.cell) != monoclinic_alpha_penalty(rhs.cell)) {
            return monoclinic_alpha_penalty(lhs.cell) < monoclinic_alpha_penalty(rhs.cell);
        }
        if (monoclinic_gamma_penalty(lhs.cell) != monoclinic_gamma_penalty(rhs.cell)) {
            return monoclinic_gamma_penalty(lhs.cell) < monoclinic_gamma_penalty(rhs.cell);
        }
    }
    if (std::abs(lhs.legacy_error - rhs.legacy_error) > 1.0e-9) {
        return lhs.legacy_error < rhs.legacy_error;
    }
    return lhs.rounded_transform < rhs.rounded_transform;
}

[[nodiscard]] inline auto unimodular_basis_changes() -> const std::vector<math::Matrix3>& {
    static const std::vector<math::Matrix3> matrices = [] {
        std::vector<math::Matrix3> result;
        result.reserve(7000);
        for (int m00 = -1; m00 <= 1; ++m00) {
            for (int m01 = -1; m01 <= 1; ++m01) {
                for (int m02 = -1; m02 <= 1; ++m02) {
                    for (int m10 = -1; m10 <= 1; ++m10) {
                        for (int m11 = -1; m11 <= 1; ++m11) {
                            for (int m12 = -1; m12 <= 1; ++m12) {
                                for (int m20 = -1; m20 <= 1; ++m20) {
                                    for (int m21 = -1; m21 <= 1; ++m21) {
                                        for (int m22 = -1; m22 <= 1; ++m22) {
                                            const math::Matrix3 matrix({{
                                                {static_cast<double>(m00), static_cast<double>(m01), static_cast<double>(m02)},
                                                {static_cast<double>(m10), static_cast<double>(m11), static_cast<double>(m12)},
                                                {static_cast<double>(m20), static_cast<double>(m21), static_cast<double>(m22)},
                                            }});
                                            const double determinant = math::determinant(matrix);
                                            const double rounded = std::round(determinant);
                                            if (std::abs(determinant - rounded) > 1.0e-9 || std::abs(rounded) != 1.0) {
                                                continue;
                                            }
                                            result.push_back(matrix);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        std::stable_sort(result.begin(),
                         result.end(),
                         [](const math::Matrix3& lhs, const math::Matrix3& rhs) {
                             const int lhs_complexity = transform_complexity(lhs);
                             const int rhs_complexity = transform_complexity(rhs);
                             if (lhs_complexity != rhs_complexity) {
                                 return lhs_complexity < rhs_complexity;
                             }
                             return rounded_transform(lhs) < rounded_transform(rhs);
                         });
        return result;
    }();
    return matrices;
}

inline void insert_candidate(std::vector<ConventionalCandidate>& candidates, ConventionalCandidate candidate) {
    for (ConventionalCandidate& existing : candidates) {
        if (!same_candidate_cell(existing, candidate)) {
            continue;
        }
        if (candidate_is_better(candidate, existing)) {
            existing = std::move(candidate);
        }
        return;
    }
    candidates.push_back(std::move(candidate));
}

}  // namespace detail

// The legacy `del1` reduction is already ported in the geometry layer. This
// wrapper keeps the post-processing API explicit: the first step is always to
// reduce to the unique primitive cell before any conventional setting is tried.
[[nodiscard]] inline auto delaunay_reduce_cell(const crystal::CellParameters& input_cell, char input_centering = 'P')
    -> DelaunayReductionResult {
    const crystal::CellParameters primitive_input = crystal::to_primitive_cell(input_cell, input_centering);
    return {
        primitive_input,
        crystal::reduce_cell(input_cell, input_centering),
    };
}

// Reduced-cell equivalence is the robust lattice-level comparison used by the
// search store and by the post-processing regression tests. It intentionally
// compares ratios plus angles, because axis permutations are absorbed by the
// reduced-cell normalization itself.
[[nodiscard]] inline auto compare_reduced_cells(const crystal::CellParameters& lhs,
                                                char lhs_centering,
                                                const crystal::CellParameters& rhs,
                                                char rhs_centering,
                                                const ReducedCellComparisonSettings& settings = {})
    -> ReducedCellComparison {
    ReducedCellComparison comparison;
    comparison.lhs_reduced = crystal::reduce_cell(lhs, lhs_centering);
    comparison.rhs_reduced = crystal::reduce_cell(rhs, rhs_centering);
    comparison.lhs_ab_ratio = detail::axis_ratio_ab(comparison.lhs_reduced);
    comparison.rhs_ab_ratio = detail::axis_ratio_ab(comparison.rhs_reduced);
    comparison.lhs_cb_ratio = detail::axis_ratio_cb(comparison.lhs_reduced);
    comparison.rhs_cb_ratio = detail::axis_ratio_cb(comparison.rhs_reduced);
    comparison.alpha_error_deg = std::abs(comparison.lhs_reduced.alpha_deg - comparison.rhs_reduced.alpha_deg);
    comparison.beta_error_deg = std::abs(comparison.lhs_reduced.beta_deg - comparison.rhs_reduced.beta_deg);
    comparison.gamma_error_deg = std::abs(comparison.lhs_reduced.gamma_deg - comparison.rhs_reduced.gamma_deg);

    comparison.equivalent = detail::close_reduced_cells(comparison.lhs_reduced, comparison.rhs_reduced, settings);
    if (comparison.equivalent) {
        return comparison;
    }

    for (const math::Matrix3& primitive_change : detail::unimodular_basis_changes()) {
        const crystal::CellParameters transformed_rhs =
            crystal::apply_basis_change(comparison.rhs_reduced, primitive_change);
        if (detail::close_reduced_cells(comparison.lhs_reduced, transformed_rhs, settings)) {
            comparison.equivalent = true;
            return comparison;
        }
    }
    return comparison;
}

// Conventional settings are enumerated from the reduced primitive cell by a
// bounded set of small unimodular basis changes. This keeps the implementation
// easy to audit while still reproducing the transcript cells in the current
// corpus, including the centered monoclinic settings for CuPc and GRGDS.
[[nodiscard]] inline auto conventionalize_cell(const crystal::CellParameters& input_cell,
                                               char input_centering = 'P',
                                               const ConventionalizationSettings& settings = {})
    -> ConventionalizationResult {
    ConventionalizationResult result;
    result.input_cell = input_cell;
    result.input_centering = detail::normalized_centering(input_centering);

    const DelaunayReductionResult reduction = delaunay_reduce_cell(input_cell, result.input_centering);
    result.primitive_input_cell = reduction.primitive_input_cell;
    result.reduced_primitive_cell = reduction.reduced_primitive_cell;

    constexpr std::array<char, 7> centering_order {'P', 'A', 'B', 'C', 'I', 'F', 'R'};
    for (const math::Matrix3& primitive_change : detail::unimodular_basis_changes()) {
        for (const char output_centering : centering_order) {
            const math::Matrix3 reduced_to_conventional =
                math::multiply(primitive_change, math::inverse(crystal::primitive_basis_change(output_centering)));
            const crystal::CellParameters candidate_cell =
                crystal::apply_basis_change(result.reduced_primitive_cell, reduced_to_conventional);

            const auto strict_system = detail::highest_matching_system(candidate_cell,
                                                                       output_centering,
                                                                       settings.minimum_system,
                                                                       settings.strict_tolerances);
            const auto legacy_system = detail::highest_matching_system(candidate_cell,
                                                                       output_centering,
                                                                       settings.minimum_system,
                                                                       settings.legacy_tolerances);
            if (!legacy_system.has_value()) {
                continue;
            }

            ConventionalCandidate candidate;
            candidate.strict_system = strict_system.value_or(CrystalSystem::triclinic);
            candidate.legacy_system = *legacy_system;
            candidate.centering = output_centering;
            candidate.cell = candidate_cell;
            candidate.reduced_to_conventional = reduced_to_conventional;
            candidate.conventional_to_reduced = math::inverse(reduced_to_conventional);
            candidate.strict_error = detail::symmetry_error(candidate_cell, candidate.strict_system);
            candidate.legacy_error = detail::symmetry_error(candidate_cell, candidate.legacy_system);
            candidate.transform_complexity = detail::transform_complexity(reduced_to_conventional);
            candidate.rounded_transform = detail::rounded_transform(reduced_to_conventional);
            detail::insert_candidate(result.candidates, std::move(candidate));
        }
    }

    std::stable_sort(result.candidates.begin(),
                     result.candidates.end(),
                     [](const ConventionalCandidate& lhs, const ConventionalCandidate& rhs) {
                         if (detail::to_index(lhs.legacy_system) != detail::to_index(rhs.legacy_system)) {
                             return detail::to_index(lhs.legacy_system) > detail::to_index(rhs.legacy_system);
                         }
                         if (lhs.centering != rhs.centering) {
                             return lhs.centering < rhs.centering;
                         }
                         return detail::preferred_candidate_less(lhs, rhs);
                     });

    const std::optional<char> preferred_centering =
        settings.preferred_centering == ' ' ? std::nullopt
                                            : std::optional<char>(detail::normalized_centering(settings.preferred_centering));
    for (int system_index = detail::to_index(CrystalSystem::cubic);
         system_index >= detail::to_index(settings.minimum_system);
         --system_index) {
        const auto system = static_cast<CrystalSystem>(system_index);

        const auto choose_from_candidates = [&](bool require_centering) -> std::optional<ConventionalCandidate> {
            const ConventionalCandidate* best = nullptr;
            for (const ConventionalCandidate& candidate : result.candidates) {
                if (candidate.strict_system != system) {
                    continue;
                }
                if (require_centering && preferred_centering.has_value() && candidate.centering != *preferred_centering) {
                    continue;
                }
                if (best == nullptr || detail::preferred_candidate_less(candidate, *best)) {
                    best = &candidate;
                }
            }
            if (best == nullptr) {
                return std::nullopt;
            }
            return *best;
        };

        if (preferred_centering.has_value()) {
            if (const auto preferred = choose_from_candidates(true); preferred.has_value()) {
                result.preferred_candidate = preferred;
                return result;
            }
        }
        if (const auto fallback = choose_from_candidates(false); fallback.has_value()) {
            result.preferred_candidate = fallback;
            return result;
        }
    }

    for (const ConventionalCandidate& candidate : result.candidates) {
        if (preferred_centering.has_value() && candidate.centering != *preferred_centering) {
            continue;
        }
        result.preferred_candidate = candidate;
        return result;
    }
    if (!result.candidates.empty()) {
        result.preferred_candidate = result.candidates.front();
    }
    return result;
}

}  // namespace piep::postprocessing
