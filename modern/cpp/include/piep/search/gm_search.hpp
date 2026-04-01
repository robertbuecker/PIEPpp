#pragma once

#include <algorithm>
#include <cstddef>
#include <limits>
#include <stdexcept>
#include <vector>

#include "piep/crystal/cell.hpp"
#include "piep/indexing/indexing_engine.hpp"
#include "piep/search/candidate_generator.hpp"
#include "piep/search/candidate_store.hpp"
#include "piep/search/pattern_prep.hpp"
#include "piep/search/search_grid.hpp"

namespace piep::search {

struct SearchEngineSettings {
    indexing::IndexingSettings indexing_settings {};
    CandidateStoreSettings candidate_store_settings {};
};

struct SearchEngineResult {
    SearchGridSetup setup {};
    CandidateGenerationStatus generation_status {CandidateGenerationStatus::invalid_search_grid};
    bool generation_truncated {};
    std::size_t total_candidate_count {};
    std::size_t evaluated_candidate_count {};
    std::size_t no_match_rejection_count {};
    std::size_t overflow_rejection_count {};
    std::size_t duplicate_rejection_count {};
    std::size_t capacity_rejection_count {};
    std::size_t replacement_count {};
    std::vector<StoredCandidate> candidates {};
};

namespace detail {

[[nodiscard]] inline auto weight_sum(const indexing::IndexingSettings& settings) -> double {
    return settings.weight_angle_deg + settings.weight_ratio_percent + settings.weight_camera_percent;
}

[[nodiscard]] inline auto coordinate_tolerances_for_layer(const SearchLayer& layer) -> CandidateCoordinateTolerances {
    return {
        1.5 * layer.geometry.dx,
        1.5 * layer.geometry.dy,
        1.5 * std::abs(layer.delta_height),
    };
}

// The legacy DC search resets `ila=1` in `such` before the GM loop starts, so
// candidate evaluation always happens in the primitive setting. The requested
// centering is still relevant later for transformation and conventionalization,
// but not for the raw GM ranking reproduced here.
[[nodiscard]] inline auto gm_search_evaluation_centering(char requested_centering) -> char {
    (void) requested_centering;
    return 'P';
}

}  // namespace detail

// The search engine evaluates one GM candidate exactly the way the legacy DC
// loop uses `indi`/`eva`: each active pattern contributes its best indexing
// match, and the candidate score is the mean of those best-match FOM values.
[[nodiscard]] inline auto evaluate_search_candidate(const std::vector<SearchPattern>& patterns,
                                                    const std::vector<std::size_t>& active_slots,
                                                    const SearchCandidate& candidate,
                                                    char centering,
                                                    const indexing::IndexingSettings& indexing_settings = {})
    -> SearchCandidateEvaluation {
    SearchCandidateEvaluation evaluation;
    evaluation.candidate = candidate;
    const crystal::CellMetric candidate_metric = crystal::to_metric(candidate.direct_cell);
    evaluation.reduced_cell = crystal::to_parameters(
        crystal::del1(candidate_metric, crystal::direct_volume(candidate_metric)));
    evaluation.aggregate_figure_of_merit = 0.0;
    evaluation.weight_sum = detail::weight_sum(indexing_settings);

    for (std::size_t slot : active_slots) {
        const SearchPattern& pattern = detail::find_pattern(patterns, slot);
        const auto indexed =
            indexing::index_prepared_pattern(pattern.prepared, candidate.direct_cell, centering, indexing_settings);
        if (indexed.overflow) {
            evaluation.status = CandidateEvaluationStatus::indexing_overflow;
            evaluation.failed_slot = slot;
            evaluation.failed_title = pattern.prepared.restored.observation.title;
            evaluation.pattern_matches.clear();
            evaluation.aggregate_figure_of_merit = std::numeric_limits<double>::infinity();
            return evaluation;
        }
        if (indexed.matches.empty()) {
            evaluation.status = CandidateEvaluationStatus::no_indexing_match;
            evaluation.failed_slot = slot;
            evaluation.failed_title = pattern.prepared.restored.observation.title;
            evaluation.pattern_matches.clear();
            evaluation.aggregate_figure_of_merit = std::numeric_limits<double>::infinity();
            return evaluation;
        }

        evaluation.aggregate_figure_of_merit += indexed.matches.front().figure_of_merit;
        evaluation.pattern_matches.push_back({
            slot,
            pattern.prepared.restored.observation.title,
            indexed.matches.front(),
            indexed.matches.size(),
        });
    }

    if (evaluation.pattern_matches.empty()) {
        evaluation.status = CandidateEvaluationStatus::no_indexing_match;
        evaluation.aggregate_figure_of_merit = std::numeric_limits<double>::infinity();
        return evaluation;
    }

    evaluation.aggregate_figure_of_merit /= static_cast<double>(evaluation.pattern_matches.size());
    evaluation.status = CandidateEvaluationStatus::ok;
    return evaluation;
}

[[nodiscard]] inline auto search_generated_candidates(const std::vector<SearchPattern>& patterns,
                                                      const CandidateGenerationResult& generated,
                                                      char centering,
                                                      const SearchEngineSettings& settings = {}) -> SearchEngineResult {
    SearchEngineResult result;
    result.setup = generated.setup;
    result.generation_status = generated.status;
    result.generation_truncated = generated.truncated;
    result.total_candidate_count = generated.total_candidate_count;
    if (generated.status != CandidateGenerationStatus::ok || generated.setup.status != SearchGridStatus::ok) {
        return result;
    }

    const char evaluation_centering = detail::gm_search_evaluation_centering(centering);
    CandidateStoreState store;
    for (const SearchCandidate& candidate : generated.candidates) {
        ++result.evaluated_candidate_count;
        const SearchCandidateEvaluation evaluation = evaluate_search_candidate(
            patterns,
            generated.setup.reference.active_sequence_slots,
            candidate,
            evaluation_centering,
            settings.indexing_settings);

        if (evaluation.status == CandidateEvaluationStatus::indexing_overflow) {
            ++result.overflow_rejection_count;
            continue;
        }
        if (evaluation.status == CandidateEvaluationStatus::no_indexing_match) {
            ++result.no_match_rejection_count;
            continue;
        }

        if (candidate.layer_index < 0 ||
            static_cast<std::size_t>(candidate.layer_index) >= generated.layers.size()) {
            throw std::runtime_error("Candidate layer index is out of range");
        }

        const CandidateStoreUpdate update = insert_candidate(
            store,
            evaluation,
            detail::coordinate_tolerances_for_layer(generated.layers[static_cast<std::size_t>(candidate.layer_index)]),
            settings.candidate_store_settings);
        if (update.decision == CandidateStoreDecision::duplicate_rejected) {
            ++result.duplicate_rejection_count;
        }
        else if (update.decision == CandidateStoreDecision::capacity_rejected) {
            ++result.capacity_rejection_count;
        }
        else if (update.decision == CandidateStoreDecision::replaced_duplicates) {
            ++result.replacement_count;
        }
    }

    result.candidates = std::move(store.candidates);
    return result;
}

[[nodiscard]] inline auto search_unit_cells(
    const std::vector<SearchPattern>& patterns,
    const VolumeRangeRequest& requested_range,
    char centering = 'P',
    const IncrementSpecification& increment = {},
    const ReferenceSelectionSettings& selection_settings = {},
    const SearchGridDefaults& grid_defaults = {},
    const CandidateGenerationOptions& generation_options = {},
    const SearchEngineSettings& engine_settings = {}) -> SearchEngineResult {
    const SearchGridSetup setup =
        initialize_search_grid(patterns, requested_range, increment, selection_settings, grid_defaults);
    if (setup.status != SearchGridStatus::ok) {
        SearchEngineResult result;
        result.setup = setup;
        return result;
    }

    return search_generated_candidates(
        patterns,
        generate_search_candidates(setup, generation_options),
        centering,
        engine_settings);
}

}  // namespace piep::search
