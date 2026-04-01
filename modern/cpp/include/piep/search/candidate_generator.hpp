#pragma once

#include <algorithm>
#include <cmath>
#include <cstddef>
#include <vector>

#include "piep/crystal/cell.hpp"
#include "piep/search/search_grid.hpp"

namespace piep::search {

enum class CandidateGenerationStatus {
    ok,
    invalid_search_grid,
};

struct PlaneScanRequest {
    double layer_height {};
    double half_width_x {};
    double half_width_y {};
    double absolute_increment {};
    SearchMode mode {SearchMode::general};
    PatternSymmetryIndicator reference_symmetry {PatternSymmetryIndicator::oblique};
    int requested_wall_cycles {1};
};

struct PlaneScanGeometry {
    double layer_height {};
    double delta {};
    double half_width_x {};
    double half_width_y {};
    int nx {};
    int ny {};
    double dx {};
    double dy {};
    int requested_wall_cycles {1};
    int effective_wall_cycles {1};
};

struct PlanePoint {
    std::size_t point_index {};
    double x {};
    double y {};
    int wall_cycle {1};
};

struct PlaneScanResult {
    PlaneScanGeometry geometry {};
    std::vector<PlanePoint> points {};
};

struct SearchLayer {
    int layer_index {};
    double previous_height {};
    double height {};
    double delta_height {};
    double p {};
    double direct_volume {};
    PlaneScanGeometry geometry {};
    std::size_t point_count {};
};

struct SearchCandidate {
    std::size_t global_index {};
    int layer_index {};
    std::size_t index_in_layer {};
    int wall_cycle {1};
    double x {};
    double y {};
    double z {};
    piep::crystal::CellMetric raw_reciprocal_metric {};
    piep::crystal::CellMetric reciprocal_metric {};
    piep::crystal::CellParameters direct_cell {};
    double reciprocal_volume {};
    double direct_volume {};
    bool minimized {};
};

struct CandidateGenerationOptions {
    double reduction_cosine_limit {0.5};
    std::size_t candidate_limit {};
};

struct CandidateGenerationResult {
    CandidateGenerationStatus status {CandidateGenerationStatus::invalid_search_grid};
    SearchGridSetup setup {};
    std::vector<SearchLayer> layers {};
    std::vector<SearchCandidate> candidates {};
    std::size_t total_candidate_count {};
    bool truncated {};
};

namespace detail {

// rlg uses integer assignment from positive reals after adding 0.5. The same
// truncation is reused here so the generated coordinates keep the original
// point counts and ordering.
[[nodiscard]] inline auto grid_subdivisions(double half_width, double delta) -> int {
    return legacy_rounded_positive(half_width / delta + 0.5);
}

[[nodiscard]] inline auto effective_wall_cycles(const PlaneScanRequest& request,
                                                const PlaneScanGeometry& geometry) -> int {
    if (legacy_code(request.mode) >= 6) {
        return 1;
    }

    int cycles = std::max(request.requested_wall_cycles, 1);
    if (request.mode == SearchMode::centered) {
        cycles = std::min(cycles, 1 + geometry.nx / 2);
    }
    else if (request.mode != SearchMode::general) {
        cycles = std::min(cycles, 1 + std::min(geometry.nx, geometry.ny) / 2);
    }
    return std::max(cycles, 1);
}

[[nodiscard]] inline auto candidate_basis(const SearchGridSetup& setup, double x, double y, double z)
    -> piep::math::Matrix3 {
    const double cosine_gamma = std::cos(piep::crystal::deg_to_rad(setup.reduced_reference_angle_deg));
    const double sine_gamma = std::sqrt(std::max(0.0, 1.0 - cosine_gamma * cosine_gamma));

    return piep::math::Matrix3({{
        {setup.reduced_reference_first, setup.reduced_reference_second * cosine_gamma, x},
        {0.0, setup.reduced_reference_second * sine_gamma, y},
        {0.0, 0.0, z},
    }});
}

// rlgen performs xtodg first and only runs one minni pass if alpha* or beta*
// is too far from 90 degrees. The raw metric is kept for low-level tests and
// for later search-store work that still reasons in the original coordinates.
[[nodiscard]] inline auto finalize_candidate_metric(const piep::math::Matrix3& basis,
                                                    double reduction_cosine_limit)
    -> std::pair<piep::crystal::CellMetric, piep::crystal::CellMetric> {
    const piep::crystal::CellMetric raw_metric = piep::crystal::xtodg(basis);
    if (std::abs(raw_metric.cos_alpha) < reduction_cosine_limit &&
        std::abs(raw_metric.cos_beta) < reduction_cosine_limit) {
        return {raw_metric, raw_metric};
    }

    piep::math::Matrix3 reduced_basis = basis;
    piep::crystal::detail::minni(reduced_basis, 1);
    return {raw_metric, piep::crystal::xtodg(reduced_basis)};
}

}  // namespace detail

// This is a typed port of the low-level rlg plane scan. The result keeps the
// original per-layer ordering so later indexing and duplicate suppression can
// consume the exact same search stream as the FORTRAN code.
[[nodiscard]] inline auto enumerate_plane_points(const PlaneScanRequest& request) -> PlaneScanResult {
    PlaneScanResult result;
    result.geometry.layer_height = request.layer_height;
    result.geometry.delta = request.absolute_increment * request.layer_height;
    result.geometry.half_width_x = request.half_width_x;
    result.geometry.half_width_y = request.half_width_y;
    result.geometry.requested_wall_cycles = std::max(request.requested_wall_cycles, 1);

    if (result.geometry.delta <= 0.0) {
        return result;
    }

    result.geometry.nx = detail::grid_subdivisions(request.half_width_x, result.geometry.delta);
    result.geometry.ny = detail::grid_subdivisions(request.half_width_y, result.geometry.delta);
    result.geometry.dx = request.half_width_x / static_cast<double>(std::max(result.geometry.nx, 1));
    result.geometry.dy = request.half_width_y / static_cast<double>(std::max(result.geometry.ny, 1));
    result.geometry.effective_wall_cycles = detail::effective_wall_cycles(request, result.geometry);

    auto emit = [&result](double x, double y, int wall_cycle) {
        result.points.push_back({result.points.size(), x, y, wall_cycle});
    };

    if (detail::legacy_code(request.mode) >= 6) {
        emit(0.0, 0.0, 1);
        emit(request.half_width_x,
             request.mode == SearchMode::hexagonal ? 2.0 * request.half_width_y / 3.0 : request.half_width_y,
             1);
        return result;
    }

    if (request.mode == SearchMode::general) {
        const int xb = request.reference_symmetry == PatternSymmetryIndicator::oblique ? -result.geometry.nx : -1;
        for (int x_index = 0; x_index <= result.geometry.nx; ++x_index) {
            emit(static_cast<double>(x_index) * result.geometry.dx, 0.0, 1);
        }
        for (int y_index = 1; y_index <= result.geometry.ny; ++y_index) {
            for (int x_index = xb + 1; x_index <= result.geometry.nx; ++x_index) {
                emit(static_cast<double>(x_index) * result.geometry.dx,
                     static_cast<double>(y_index) * result.geometry.dy,
                     1);
            }
        }
        return result;
    }

    for (int cycle = 1; cycle <= result.geometry.effective_wall_cycles; ++cycle) {
        const int xb = cycle - 1;
        const int xe = result.geometry.nx + 1 - cycle;
        const int yb = cycle - 1;
        const int ye = request.mode == SearchMode::centered ? result.geometry.ny : result.geometry.ny + 1 - cycle;

        for (int y_index = yb; y_index <= ye; ++y_index) {
            const double y = static_cast<double>(y_index) * result.geometry.dy;
            emit(static_cast<double>(xb) * result.geometry.dx, y, cycle);
            if (xe > xb) {
                emit(static_cast<double>(xe) * result.geometry.dx, y, cycle);
            }
        }

        for (int x_index = xb + 1; x_index < xe; ++x_index) {
            const double x = static_cast<double>(x_index) * result.geometry.dx;
            emit(x, static_cast<double>(yb) * result.geometry.dy, cycle);
            if (request.mode == SearchMode::rectangular && ye > yb) {
                emit(x, static_cast<double>(ye) * result.geometry.dy, cycle);
            }
        }
    }

    return result;
}

// rlgen combines the layer schedule from ldini with the rlg point stream and
// then converts each reciprocal basis to cell metrics. The modern port keeps
// the stream fully materialized for inspection, but still records whether the
// one-pass minni fallback was applied.
[[nodiscard]] inline auto generate_search_candidates(const SearchGridSetup& setup,
                                                     const CandidateGenerationOptions& options = {})
    -> CandidateGenerationResult {
    CandidateGenerationResult result;
    result.setup = setup;
    if (setup.status != SearchGridStatus::ok) {
        return result;
    }

    result.status = CandidateGenerationStatus::ok;
    result.layers.reserve(static_cast<std::size_t>(std::max(setup.layer_count, 0)));
    if (options.candidate_limit > 0) {
        result.candidates.reserve(options.candidate_limit);
    }
    else {
        result.candidates.reserve(setup.total_grid_points);
    }

    const bool single_layer = setup.layer_count <= 1 || std::abs(setup.layer_scale - 1.0) < 1.0e-12;
    double previous_height = single_layer ? setup.first_layer_height : setup.first_layer_height / setup.layer_scale;
    std::size_t global_index = 0;

    for (int layer_index = 0; layer_index < setup.layer_count; ++layer_index) {
        const double layer_height = previous_height * setup.layer_scale;
        const double delta_height = previous_height - layer_height;
        const double delta = setup.absolute_increment * layer_height;
        int requested_wall_cycles = 1;
        if (setup.reference.wall_thickness > 0.0 && delta > 0.0) {
            requested_wall_cycles = static_cast<int>(setup.reference.wall_thickness / delta + 1.5);
        }

        const PlaneScanResult plane = enumerate_plane_points({
            layer_height,
            setup.half_width_x,
            setup.half_width_y,
            setup.absolute_increment,
            setup.reference.search_mode,
            setup.reference.reference_symmetry,
            requested_wall_cycles,
        });

        result.layers.push_back({
            layer_index,
            previous_height,
            layer_height,
            delta_height,
            setup.h0 / layer_height,
            1.0 / (setup.flc * layer_height),
            plane.geometry,
            plane.points.size(),
        });

        result.total_candidate_count += plane.points.size();
        for (const PlanePoint& point : plane.points) {
            if (options.candidate_limit > 0 && result.candidates.size() >= options.candidate_limit) {
                result.truncated = true;
                ++global_index;
                continue;
            }

            const piep::math::Matrix3 basis = detail::candidate_basis(setup, point.x, point.y, layer_height);
            const auto [raw_metric, final_metric] =
                detail::finalize_candidate_metric(basis, options.reduction_cosine_limit);
            const auto direct_result = piep::crystal::reciprocal_from_metric(final_metric);
            const double reciprocal_volume = piep::crystal::direct_volume(final_metric);
            const bool minimized = std::abs(raw_metric.cos_alpha - final_metric.cos_alpha) > 1.0e-12 ||
                                   std::abs(raw_metric.cos_beta - final_metric.cos_beta) > 1.0e-12 ||
                                   std::abs(raw_metric.cos_gamma - final_metric.cos_gamma) > 1.0e-12 ||
                                   std::abs(raw_metric.a - final_metric.a) > 1.0e-12 ||
                                   std::abs(raw_metric.b - final_metric.b) > 1.0e-12 ||
                                   std::abs(raw_metric.c - final_metric.c) > 1.0e-12;

            result.candidates.push_back({
                global_index,
                layer_index,
                point.point_index,
                point.wall_cycle,
                point.x,
                point.y,
                layer_height,
                raw_metric,
                final_metric,
                direct_result.parameters,
                reciprocal_volume,
                reciprocal_volume > 0.0 ? 1.0 / reciprocal_volume : 0.0,
                minimized,
            });
            ++global_index;
        }

        previous_height = layer_height;
    }

    return result;
}

}  // namespace piep::search
