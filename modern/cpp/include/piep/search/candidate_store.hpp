#pragma once

#include <algorithm>
#include <cmath>
#include <cstddef>
#include <limits>
#include <string>
#include <vector>

#include "piep/crystal/cell.hpp"
#include "piep/indexing/indexing_engine.hpp"
#include "piep/search/candidate_generator.hpp"

namespace piep::search {

enum class CandidateEvaluationStatus {
    ok,
    no_indexing_match,
    indexing_overflow,
};

struct PatternBestMatch {
    std::size_t slot {};
    std::string title {};
    indexing::IndexingMatch best_match {};
    std::size_t match_count {};
};

struct SearchCandidateEvaluation {
    CandidateEvaluationStatus status {CandidateEvaluationStatus::no_indexing_match};
    std::size_t failed_slot {};
    std::string failed_title {};
    SearchCandidate candidate {};
    crystal::CellParameters reduced_cell {};
    double aggregate_figure_of_merit {std::numeric_limits<double>::infinity()};
    double weight_sum {};
    std::vector<PatternBestMatch> pattern_matches {};
};

struct CandidateCoordinateTolerances {
    double x {};
    double y {};
    double z {};
};

struct CandidateStoreSettings {
    std::size_t maximum_candidates {100};
    double angle_tolerance_deg {2.0};
    double axis_ratio_relative_tolerance {0.05};
    double support_scale {5.0};
};

struct StoredCandidate {
    SearchCandidateEvaluation evaluation {};
    double accumulated_support {};
    double normalized_support {};
};

enum class CandidateStoreDecision {
    inserted,
    replaced_duplicates,
    duplicate_rejected,
    capacity_rejected,
};

struct CandidateStoreUpdate {
    CandidateStoreDecision decision {CandidateStoreDecision::inserted};
    std::size_t affected_rank {};
    std::size_t removed_duplicate_count {};
};

struct CandidateStoreState {
    std::vector<StoredCandidate> candidates {};
    double maximum_support {};
};

namespace detail {

[[nodiscard]] inline auto normalized_support_value(double figure_of_merit,
                                                   double weight_sum,
                                                   double support_scale) -> double {
    const double clamped_weight_sum = std::max(weight_sum, 1.0e-10);
    const double clamped_fom = std::max(figure_of_merit, 1.0e-10);
    return 1.0 / (1.0 + support_scale * clamped_fom / clamped_weight_sum);
}

[[nodiscard]] inline auto axis_ratio_ab(const crystal::CellParameters& cell) -> double {
    return cell.b > 0.0 ? cell.a / cell.b : 0.0;
}

[[nodiscard]] inline auto axis_ratio_cb(const crystal::CellParameters& cell) -> double {
    return cell.b > 0.0 ? cell.c / cell.b : 0.0;
}

[[nodiscard]] inline auto close_in_search_space(const SearchCandidate& lhs,
                                                const SearchCandidate& rhs,
                                                const CandidateCoordinateTolerances& tolerances) -> bool {
    return std::abs(lhs.x - rhs.x) < tolerances.x && std::abs(lhs.y - rhs.y) < tolerances.y &&
           std::abs(lhs.z - rhs.z) < tolerances.z;
}

[[nodiscard]] inline auto close_in_reduced_cell(const crystal::CellParameters& lhs,
                                                const crystal::CellParameters& rhs,
                                                const CandidateStoreSettings& settings) -> bool {
    const double lhs_ab = axis_ratio_ab(lhs);
    const double rhs_ab = axis_ratio_ab(rhs);
    const double lhs_cb = axis_ratio_cb(lhs);
    const double rhs_cb = axis_ratio_cb(rhs);

    if (rhs_ab <= 0.0 || rhs_cb <= 0.0) {
        return false;
    }
    if (std::abs(lhs_ab / rhs_ab - 1.0) > settings.axis_ratio_relative_tolerance) {
        return false;
    }
    if (std::abs(lhs_cb / rhs_cb - 1.0) > settings.axis_ratio_relative_tolerance) {
        return false;
    }
    return std::abs(lhs.alpha_deg - rhs.alpha_deg) <= settings.angle_tolerance_deg &&
           std::abs(lhs.beta_deg - rhs.beta_deg) <= settings.angle_tolerance_deg &&
           std::abs(lhs.gamma_deg - rhs.gamma_deg) <= settings.angle_tolerance_deg;
}

inline void refresh_support_scaling(CandidateStoreState& state) {
    state.maximum_support = 0.0;
    for (const StoredCandidate& candidate : state.candidates) {
        state.maximum_support = std::max(state.maximum_support, candidate.accumulated_support);
    }

    const double denominator = std::max(state.maximum_support, 1.0e-12);
    for (StoredCandidate& candidate : state.candidates) {
        candidate.normalized_support = candidate.accumulated_support / denominator;
    }
}

}  // namespace detail

// This is the typed `ck` store policy. Candidates remain ordered by aggregate
// FOM, near-duplicates are rejected or replaced using the same ratio/angle
// criteria, and repeated worse hits accumulate an auxiliary support score.
[[nodiscard]] inline auto insert_candidate(CandidateStoreState& state,
                                           const SearchCandidateEvaluation& evaluation,
                                           const CandidateCoordinateTolerances& coordinate_tolerances,
                                           const CandidateStoreSettings& settings = {}) -> CandidateStoreUpdate {
    CandidateStoreUpdate update;
    const double support =
        detail::normalized_support_value(evaluation.aggregate_figure_of_merit, evaluation.weight_sum, settings.support_scale);

    std::vector<std::size_t> duplicate_indices;
    for (std::size_t index = 0; index < state.candidates.size(); ++index) {
        StoredCandidate& existing = state.candidates[index];
        if (detail::close_in_search_space(evaluation.candidate, existing.evaluation.candidate, coordinate_tolerances) &&
            evaluation.aggregate_figure_of_merit > existing.evaluation.aggregate_figure_of_merit) {
            existing.accumulated_support += support;
            detail::refresh_support_scaling(state);
            update.decision = CandidateStoreDecision::duplicate_rejected;
            update.affected_rank = index;
            return update;
        }

        if (!detail::close_in_reduced_cell(evaluation.reduced_cell, existing.evaluation.reduced_cell, settings)) {
            continue;
        }
        if (evaluation.aggregate_figure_of_merit >= existing.evaluation.aggregate_figure_of_merit) {
            existing.accumulated_support += support;
            detail::refresh_support_scaling(state);
            update.decision = CandidateStoreDecision::duplicate_rejected;
            update.affected_rank = index;
            return update;
        }
        duplicate_indices.push_back(index);
    }

    update.removed_duplicate_count = duplicate_indices.size();
    for (auto iterator = duplicate_indices.rbegin(); iterator != duplicate_indices.rend(); ++iterator) {
        state.candidates.erase(state.candidates.begin() + static_cast<std::ptrdiff_t>(*iterator));
    }

    if (state.candidates.size() >= settings.maximum_candidates &&
        evaluation.aggregate_figure_of_merit >= state.candidates.back().evaluation.aggregate_figure_of_merit) {
        detail::refresh_support_scaling(state);
        update.decision = CandidateStoreDecision::capacity_rejected;
        update.affected_rank = settings.maximum_candidates - 1;
        return update;
    }

    if (state.candidates.size() >= settings.maximum_candidates) {
        state.candidates.pop_back();
    }

    StoredCandidate stored;
    stored.evaluation = evaluation;
    stored.accumulated_support = support;

    const auto insertion_point = std::upper_bound(
        state.candidates.begin(),
        state.candidates.end(),
        evaluation.aggregate_figure_of_merit,
        [](double figure_of_merit, const StoredCandidate& existing) {
            return figure_of_merit < existing.evaluation.aggregate_figure_of_merit;
        });
    update.affected_rank = static_cast<std::size_t>(std::distance(state.candidates.begin(), insertion_point));
    state.candidates.insert(insertion_point, std::move(stored));
    detail::refresh_support_scaling(state);

    update.decision = duplicate_indices.empty() ? CandidateStoreDecision::inserted
                                                : CandidateStoreDecision::replaced_duplicates;
    return update;
}

}  // namespace piep::search
