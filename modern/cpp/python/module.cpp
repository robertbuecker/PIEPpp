#include <array>
#include <stdexcept>
#include <string>
#include <vector>

#include <pybind11/pybind11.h>
#include <pybind11/stl.h>

#include "piep/crystal/cell.hpp"
#include "piep/crystal/reflection.hpp"
#include "piep/indexing/indexing_engine.hpp"
#include "piep/math/matrix3.hpp"
#include "piep/math/vector3.hpp"
#include "piep/postprocessing/cell_postprocessing.hpp"
#include "piep/search/candidate_generator.hpp"
#include "piep/search/gm_search.hpp"
#include "piep/search/pattern_prep.hpp"
#include "piep/search/reference_selection.hpp"
#include "piep/search/search_grid.hpp"
#include "piep/simulation/sad_simulator.hpp"

namespace py = pybind11;

namespace {

auto from_array(const std::array<double, 3>& value) -> piep::math::Vector3 {
    return {value[0], value[1], value[2]};
}

auto miller_index_from_array(const std::array<int, 3>& value) -> piep::crystal::MillerIndex {
    return {value[0], value[1], value[2]};
}

// PIEP reads matrices column-by-column in MV/MA. This helper keeps the Python
// debug surface aligned with the legacy input convention.
auto from_legacy_column_major(const std::array<double, 9>& values) -> piep::math::Matrix3 {
    return piep::math::Matrix3({{
        {values[0], values[3], values[6]},
        {values[1], values[4], values[7]},
        {values[2], values[5], values[8]},
    }});
}

auto make_cell(double a, double b, double c, double alpha_deg, double beta_deg, double gamma_deg)
    -> piep::crystal::CellParameters {
    return {a, b, c, alpha_deg, beta_deg, gamma_deg};
}

auto centering_from_string(const std::string& centering) -> char {
    return centering.empty() ? 'P' : centering.front();
}

auto crystal_system_name(piep::postprocessing::CrystalSystem system) -> const char* {
    switch (system) {
    case piep::postprocessing::CrystalSystem::triclinic:
        return "triclinic";
    case piep::postprocessing::CrystalSystem::monoclinic:
        return "monoclinic";
    case piep::postprocessing::CrystalSystem::orthorhombic:
        return "orthorhombic";
    case piep::postprocessing::CrystalSystem::tetragonal:
        return "tetragonal";
    case piep::postprocessing::CrystalSystem::hexagonal:
        return "hexagonal";
    case piep::postprocessing::CrystalSystem::cubic:
        return "cubic";
    }
    throw std::runtime_error("Unknown crystal system");
}

auto crystal_system_from_string(const std::string& system) -> piep::postprocessing::CrystalSystem {
    if (system == "triclinic") {
        return piep::postprocessing::CrystalSystem::triclinic;
    }
    if (system == "monoclinic") {
        return piep::postprocessing::CrystalSystem::monoclinic;
    }
    if (system == "orthorhombic") {
        return piep::postprocessing::CrystalSystem::orthorhombic;
    }
    if (system == "tetragonal") {
        return piep::postprocessing::CrystalSystem::tetragonal;
    }
    if (system == "hexagonal") {
        return piep::postprocessing::CrystalSystem::hexagonal;
    }
    if (system == "cubic") {
        return piep::postprocessing::CrystalSystem::cubic;
    }
    throw std::runtime_error("crystal system must be one of triclinic, monoclinic, orthorhombic, tetragonal, hexagonal, cubic");
}

auto make_pattern_settings(double default_high_voltage_volts,
                           double default_laue_zone_zero_sigma,
                           double default_laue_zone_one_sigma) -> piep::search::PatternPreparationSettings {
    return {
        default_high_voltage_volts,
        default_laue_zone_zero_sigma,
        default_laue_zone_one_sigma,
    };
}

auto pattern_from_fields(std::string title, const std::array<double, 18>& fields) -> piep::search::PatternObservation {
    return piep::search::PatternObservation::from_legacy_numeric_fields(std::move(title), fields);
}

auto zone_direction_from_iterable_item(const py::handle& item) -> piep::simulation::ZoneDirection {
    const py::sequence sequence = py::cast<py::sequence>(item);
    if (sequence.size() == 3) {
        return {
            sequence[0].cast<double>(),
            sequence[1].cast<double>(),
            sequence[2].cast<double>(),
            0.0,
            0.0,
        };
    }
    if (sequence.size() == 5) {
        return {
            sequence[0].cast<double>(),
            sequence[1].cast<double>(),
            sequence[2].cast<double>(),
            sequence[3].cast<double>(),
            sequence[4].cast<double>(),
        };
    }
    throw std::runtime_error("zone definitions must contain either 3 or 5 numeric values");
}

auto zone_directions_from_iterable(const py::iterable& items) -> std::vector<piep::simulation::ZoneDirection> {
    std::vector<piep::simulation::ZoneDirection> zones;
    for (const py::handle item : items) {
        zones.push_back(zone_direction_from_iterable_item(item));
    }
    return zones;
}

auto observation_to_dict(const piep::search::PatternObservation& observation) -> py::dict {
    py::dict result;
    result["title"] = observation.title;
    result["fields"] = observation.as_legacy_numeric_fields();
    return result;
}

auto restored_pattern_to_dict(const piep::search::RestoredPattern& restored) -> py::dict {
    py::dict result;
    result["title"] = restored.observation.title;
    result["fields"] = restored.observation.as_legacy_numeric_fields();
    result["rounded_high_voltage_kv"] = restored.rounded_high_voltage_kv;
    result["wavelength_angstrom"] = restored.wavelength_angstrom;
    result["primitive_volume_estimate"] = restored.primitive_volume_estimate;
    result["camera_upper_squared"] = restored.camera_upper_squared;
    result["camera_lower_squared"] = restored.camera_lower_squared;
    result["laue_zone_one_lower_bound"] = restored.laue_zone_one_lower_bound;
    result["laue_zone_one_upper_bound"] = restored.laue_zone_one_upper_bound;
    result["has_laue_zone_information"] = restored.has_laue_zone_information;
    result["laue_zone_one_is_lower_limit"] = restored.laue_zone_one_is_lower_limit;
    return result;
}

auto prepared_pattern_to_dict(const piep::search::PreparedPattern& prepared) -> py::dict {
    py::dict result;
    result["restored"] = restored_pattern_to_dict(prepared.restored);
    result["normalized_radius_lower_bounds"] = prepared.normalized_radius_lower_bounds;
    result["normalized_radius_upper_bounds"] = prepared.normalized_radius_upper_bounds;
    result["angle_cosine"] = prepared.angle_cosine;
    result["angle_cosine_upper_bound"] = prepared.angle_cosine_upper_bound;
    result["angle_cosine_lower_bound"] = prepared.angle_cosine_lower_bound;
    result["reflection_search_limit"] = prepared.reflection_search_limit;
    return result;
}

auto search_pattern_from_tuple(const py::handle& item,
                               const piep::search::PatternPreparationSettings& settings)
    -> piep::search::SearchPattern {
    const py::tuple tuple = py::cast<py::tuple>(item);
    const bool excluded = tuple.size() >= 4 ? tuple[3].cast<bool>() : false;
    return {
        tuple[0].cast<std::size_t>(),
        piep::search::prepare_pattern(pattern_from_fields(tuple[1].cast<std::string>(),
                                                          tuple[2].cast<std::array<double, 18>>()),
                                      settings),
        excluded,
    };
}

auto search_patterns_from_iterable(const py::iterable& items,
                                   const piep::search::PatternPreparationSettings& settings)
    -> std::vector<piep::search::SearchPattern> {
    std::vector<piep::search::SearchPattern> patterns;
    for (const py::handle item : items) {
        patterns.push_back(search_pattern_from_tuple(item, settings));
    }
    return patterns;
}

auto classification_to_dict(const piep::search::PatternClassification& classification) -> py::dict {
    py::dict result;
    result["slot"] = classification.slot;
    result["symmetry"] = static_cast<int>(classification.symmetry);
    result["ordering_scalar"] = classification.ordering_scalar;
    result["primitive_volume_estimate"] = classification.primitive_volume_estimate;
    result["excluded"] = classification.excluded;
    return result;
}

auto reference_selection_to_dict(const piep::search::ReferenceSelection& selection) -> py::dict {
    py::dict result;
    py::list classifications;
    for (const auto& classification : selection.classifications) {
        classifications.append(classification_to_dict(classification));
    }

    result["status"] = static_cast<int>(selection.status);
    result["classifications"] = classifications;
    result["sorted_active_slots"] = selection.sorted_active_slots;
    result["active_sequence_slots"] = selection.active_sequence_slots;
    result["close_pattern_slots"] = selection.close_pattern_slots;
    result["active_pattern_count"] = selection.active_pattern_count;
    result["excluded_pattern_count"] = selection.excluded_pattern_count;
    result["reference_slot"] = selection.reference_slot;
    result["reference_symmetry"] = static_cast<int>(selection.reference_symmetry);
    result["search_mode"] = static_cast<int>(selection.search_mode);
    result["minimum_estimated_volume"] = selection.minimum_estimated_volume;
    result["maximum_estimated_volume"] = selection.maximum_estimated_volume;
    result["mean_estimated_volume"] = selection.mean_estimated_volume;
    result["average_reference_sigma"] = selection.average_reference_sigma;
    result["relative_reference_sigma"] = selection.relative_reference_sigma;
    result["wall_thickness"] = selection.wall_thickness;
    result["underdetermined"] = selection.underdetermined;
    return result;
}

auto increment_specification_from_string(const std::string& mode, double value) -> piep::search::IncrementSpecification {
    return {
        mode == "absolute" ? piep::search::IncrementMode::absolute
                           : piep::search::IncrementMode::factor_of_default,
        value,
    };
}

auto search_grid_to_dict(const piep::search::SearchGridSetup& setup) -> py::dict {
    py::dict result;
    py::dict first_layer_plane;
    first_layer_plane["count"] = setup.first_layer_plane.count;
    first_layer_plane["nx1"] = setup.first_layer_plane.nx1;
    first_layer_plane["ny1"] = setup.first_layer_plane.ny1;
    first_layer_plane["wall_cycles"] = setup.first_layer_plane.wall_cycles;
    first_layer_plane["exceeds_limit"] = setup.first_layer_plane.exceeds_limit;

    result["status"] = static_cast<int>(setup.status);
    result["reference"] = reference_selection_to_dict(setup.reference);
    result["suggested_range"] = std::array<double, 2> {setup.suggested_range.minimum, setup.suggested_range.maximum};
    result["chosen_range"] = std::array<double, 2> {setup.chosen_range.minimum, setup.chosen_range.maximum};
    result["reduced_reference_first"] = setup.reduced_reference_first;
    result["reduced_reference_second"] = setup.reduced_reference_second;
    result["reduced_reference_angle_deg"] = setup.reduced_reference_angle_deg;
    result["flc"] = setup.flc;
    result["h0"] = setup.h0;
    result["minimum_volume_floor"] = setup.minimum_volume_floor;
    result["first_layer_height"] = setup.first_layer_height;
    result["last_layer_height"] = setup.last_layer_height;
    result["first_layer_p"] = setup.first_layer_p;
    result["last_layer_p"] = setup.last_layer_p;
    result["half_width_x"] = setup.half_width_x;
    result["half_width_y"] = setup.half_width_y;
    result["absolute_increment"] = setup.absolute_increment;
    result["layer_scale"] = setup.layer_scale;
    result["relative_sigma_floor"] = setup.relative_sigma_floor;
    result["angular_sigma_floor_radians"] = setup.angular_sigma_floor_radians;
    result["layer_count"] = setup.layer_count;
    result["total_grid_points"] = setup.total_grid_points;
    result["first_layer_plane"] = first_layer_plane;
    result["minimum_wall_cycles"] = setup.minimum_wall_cycles;
    result["maximum_wall_cycles"] = setup.maximum_wall_cycles;
    return result;
}

auto plane_scan_geometry_to_dict(const piep::search::PlaneScanGeometry& geometry) -> py::dict {
    py::dict result;
    result["layer_height"] = geometry.layer_height;
    result["delta"] = geometry.delta;
    result["half_width_x"] = geometry.half_width_x;
    result["half_width_y"] = geometry.half_width_y;
    result["nx"] = geometry.nx;
    result["ny"] = geometry.ny;
    result["dx"] = geometry.dx;
    result["dy"] = geometry.dy;
    result["requested_wall_cycles"] = geometry.requested_wall_cycles;
    result["effective_wall_cycles"] = geometry.effective_wall_cycles;
    return result;
}

auto search_layer_to_dict(const piep::search::SearchLayer& layer) -> py::dict {
    py::dict result;
    result["layer_index"] = layer.layer_index;
    result["previous_height"] = layer.previous_height;
    result["height"] = layer.height;
    result["delta_height"] = layer.delta_height;
    result["p"] = layer.p;
    result["direct_volume"] = layer.direct_volume;
    result["geometry"] = plane_scan_geometry_to_dict(layer.geometry);
    result["point_count"] = layer.point_count;
    return result;
}

auto search_candidate_to_dict(const piep::search::SearchCandidate& candidate) -> py::dict {
    py::dict result;
    result["global_index"] = candidate.global_index;
    result["layer_index"] = candidate.layer_index;
    result["index_in_layer"] = candidate.index_in_layer;
    result["wall_cycle"] = candidate.wall_cycle;
    result["x"] = candidate.x;
    result["y"] = candidate.y;
    result["z"] = candidate.z;
    result["raw_reciprocal_metric"] = candidate.raw_reciprocal_metric.as_array();
    result["reciprocal_metric"] = candidate.reciprocal_metric.as_array();
    result["direct_cell"] = candidate.direct_cell.as_array();
    result["reciprocal_volume"] = candidate.reciprocal_volume;
    result["direct_volume"] = candidate.direct_volume;
    result["minimized"] = candidate.minimized;
    return result;
}

auto candidate_generation_to_dict(const piep::search::CandidateGenerationResult& generated) -> py::dict {
    py::dict result;
    py::list layers;
    for (const auto& layer : generated.layers) {
        layers.append(search_layer_to_dict(layer));
    }

    py::list candidates;
    for (const auto& candidate : generated.candidates) {
        candidates.append(search_candidate_to_dict(candidate));
    }

    result["status"] = static_cast<int>(generated.status);
    result["setup"] = search_grid_to_dict(generated.setup);
    result["layers"] = layers;
    result["candidates"] = candidates;
    result["total_candidate_count"] = generated.total_candidate_count;
    result["truncated"] = generated.truncated;
    return result;
}

auto indexing_match_to_dict(const piep::indexing::IndexingMatch& match) -> py::dict;

auto pattern_best_match_to_dict(const piep::search::PatternBestMatch& match) -> py::dict {
    py::dict result;
    result["slot"] = match.slot;
    result["title"] = match.title;
    result["best_match"] = indexing_match_to_dict(match.best_match);
    result["match_count"] = match.match_count;
    return result;
}

auto search_candidate_evaluation_to_dict(const piep::search::SearchCandidateEvaluation& evaluation) -> py::dict {
    py::dict result;
    py::list pattern_matches;
    for (const auto& match : evaluation.pattern_matches) {
        pattern_matches.append(pattern_best_match_to_dict(match));
    }

    result["status"] = static_cast<int>(evaluation.status);
    result["failed_slot"] = evaluation.failed_slot;
    result["failed_title"] = evaluation.failed_title;
    result["candidate"] = search_candidate_to_dict(evaluation.candidate);
    result["reduced_cell"] = evaluation.reduced_cell.as_array();
    result["aggregate_figure_of_merit"] = evaluation.aggregate_figure_of_merit;
    result["weight_sum"] = evaluation.weight_sum;
    result["pattern_matches"] = pattern_matches;
    return result;
}

auto stored_candidate_to_dict(const piep::search::StoredCandidate& candidate) -> py::dict {
    py::dict result;
    result["evaluation"] = search_candidate_evaluation_to_dict(candidate.evaluation);
    result["accumulated_support"] = candidate.accumulated_support;
    result["normalized_support"] = candidate.normalized_support;
    return result;
}

auto search_engine_to_dict(const piep::search::SearchEngineResult& searched) -> py::dict {
    py::dict result;
    py::list candidates;
    for (const auto& candidate : searched.candidates) {
        candidates.append(stored_candidate_to_dict(candidate));
    }

    result["setup"] = search_grid_to_dict(searched.setup);
    result["generation_status"] = static_cast<int>(searched.generation_status);
    result["generation_truncated"] = searched.generation_truncated;
    result["total_candidate_count"] = searched.total_candidate_count;
    result["evaluated_candidate_count"] = searched.evaluated_candidate_count;
    result["no_match_rejection_count"] = searched.no_match_rejection_count;
    result["overflow_rejection_count"] = searched.overflow_rejection_count;
    result["duplicate_rejection_count"] = searched.duplicate_rejection_count;
    result["capacity_rejection_count"] = searched.capacity_rejection_count;
    result["replacement_count"] = searched.replacement_count;
    result["candidates"] = candidates;
    return result;
}

auto reflection_candidate_to_dict(const piep::indexing::ReflectionCandidate& candidate) -> py::dict {
    py::dict result;
    result["hkl"] = candidate.hkl.as_array();
    result["orthogonal_vector"] = candidate.orthogonal_vector.as_array();
    result["squared_length"] = candidate.squared_length;
    return result;
}

auto reflection_enumeration_to_dict(const piep::indexing::ReflectionEnumerationResult& enumeration) -> py::dict {
    py::dict result;
    py::list first_pool;
    for (const auto& candidate : enumeration.first_pool) {
        first_pool.append(reflection_candidate_to_dict(candidate));
    }

    py::list second_pool;
    for (const auto& candidate : enumeration.second_pool) {
        second_pool.append(reflection_candidate_to_dict(candidate));
    }

    result["first_pool"] = first_pool;
    result["second_pool"] = second_pool;
    result["first_pool_count"] = enumeration.first_pool.size();
    result["second_pool_count"] = enumeration.second_pool.size();
    result["overflow"] = enumeration.overflow;
    return result;
}

auto indexing_match_to_dict(const piep::indexing::IndexingMatch& match) -> py::dict {
    py::dict result;
    result["first_hkl"] = match.first_hkl.as_array();
    result["second_hkl"] = match.second_hkl.as_array();
    result["zone_axis"] = match.zone_axis.as_array();
    result["zone_multiplicity"] = match.zone_multiplicity;
    result["predicted_first_radius"] = match.predicted_first_radius;
    result["predicted_second_radius"] = match.predicted_second_radius;
    result["predicted_angle_deg"] = match.predicted_angle_deg;
    result["predicted_camera_constant"] = match.predicted_camera_constant;
    result["predicted_laue_zone_one_minus_zero"] = match.predicted_laue_zone_one_minus_zero;
    result["angle_error_deg"] = match.angle_error_deg;
    result["ratio_error_percent"] = match.ratio_error_percent;
    result["camera_error_percent"] = match.camera_error_percent;
    result["figure_of_merit"] = match.figure_of_merit;
    return result;
}

auto indexing_result_to_dict(const piep::indexing::PatternIndexingResult& indexed) -> py::dict {
    py::dict result;
    py::list matches;
    for (const auto& match : indexed.matches) {
        matches.append(indexing_match_to_dict(match));
    }

    result["system"] = static_cast<int>(indexed.system);
    result["centering"] = std::string(1, indexed.centering);
    result["enumeration"] = reflection_enumeration_to_dict(indexed.enumeration);
    result["matches"] = matches;
    result["overflow"] = indexed.overflow;
    return result;
}

auto zone_direction_to_dict(const piep::simulation::ZoneDirection& zone) -> py::dict {
    py::dict result;
    result["uvw"] = std::array<double, 3> {zone.u, zone.v, zone.w};
    result["zone_condition_target"] = zone.target;
    result["zone_condition_tolerance"] = zone.tolerance;
    return result;
}

auto basis_pair_selection_to_dict(const piep::simulation::BasisPairSelection& selection) -> py::dict {
    py::dict result;
    result["first_spot_index"] = selection.first_spot_index;
    result["second_spot_index"] = selection.second_spot_index;
    result["first_hkl"] = selection.first_hkl.as_array();
    result["second_hkl"] = selection.second_hkl.as_array();
    result["zone_axis"] = selection.zone_axis.as_array();
    result["zone_multiplicity"] = selection.zone_multiplicity;
    result["ideal_basis"] = selection.ideal_basis.as_array();
    return result;
}

auto simulated_spot_to_dict(const piep::simulation::SimulatedSpot& spot) -> py::dict {
    py::dict result;
    result["hkl"] = spot.hkl.as_array();
    result["reciprocal_vector_crystal"] = spot.reciprocal_vector_crystal.as_array();
    result["detector_vector_crystal"] = spot.detector_vector_crystal.as_array();
    result["detector_coordinates_mm"] = spot.detector_coordinates_mm;
    result["reciprocal_length"] = spot.reciprocal_length;
    result["radius_mm"] = spot.radius_mm;
    result["zone_condition_value"] = spot.zone_condition_value;
    result["zone_condition_residual"] = spot.zone_condition_residual;
    return result;
}

auto simulated_pattern_to_dict(const piep::simulation::SimulatedPattern& pattern, char centering) -> py::dict {
    py::dict result;
    py::list spots;
    for (const auto& spot : pattern.spots) {
        spots.append(simulated_spot_to_dict(spot));
    }

    result["title"] = pattern.title;
    result["zone"] = zone_direction_to_dict(pattern.zone);
    result["spots"] = spots;
    result["spot_count"] = pattern.spots.size();
    try {
        result["default_basis_pair"] = basis_pair_selection_to_dict(
            piep::simulation::select_default_basis_pair(pattern, centering));
    }
    catch (const std::runtime_error&) {
        result["default_basis_pair"] = py::none();
    }
    return result;
}

auto simulated_observation_to_dict(const piep::simulation::SimulatedObservation& simulated) -> py::dict {
    py::dict result;
    result["title"] = simulated.title;
    result["observation"] = observation_to_dict(simulated.observation);
    result["pair_selection"] = basis_pair_selection_to_dict(simulated.pair_selection);
    result["first_detector_coordinates_mm"] = simulated.first_detector_coordinates_mm;
    result["second_detector_coordinates_mm"] = simulated.second_detector_coordinates_mm;
    return result;
}

auto observation_ensemble_to_dict(const piep::simulation::ObservationEnsembleResult& ensemble, char centering)
    -> py::dict {
    py::dict result;
    py::list patterns;
    for (const auto& pattern : ensemble.patterns) {
        patterns.append(simulated_pattern_to_dict(pattern, centering));
    }

    py::list observations;
    for (const auto& observation : ensemble.observations) {
        observations.append(simulated_observation_to_dict(observation));
    }

    py::list skipped_zones;
    for (const auto& zone : ensemble.skipped_zones) {
        skipped_zones.append(zone_direction_to_dict(zone));
    }

    result["patterns"] = patterns;
    result["observations"] = observations;
    result["skipped_zones"] = skipped_zones;
    return result;
}

auto find_spot_index(const piep::simulation::SimulatedPattern& pattern, const piep::crystal::MillerIndex& hkl)
    -> std::size_t {
    for (std::size_t index = 0; index < pattern.spots.size(); ++index) {
        const auto& spot = pattern.spots[index];
        if (spot.hkl.h == hkl.h && spot.hkl.k == hkl.k && spot.hkl.l == hkl.l) {
            return index;
        }
    }
    throw std::runtime_error("requested simulated spot was not found");
}

auto delaunay_reduction_to_dict(const piep::postprocessing::DelaunayReductionResult& result_value) -> py::dict {
    py::dict result;
    result["primitive_input_cell"] = result_value.primitive_input_cell.as_array();
    result["reduced_primitive_cell"] = result_value.reduced_primitive_cell.as_array();
    return result;
}

auto matrix_to_legacy_column_major(const piep::math::Matrix3& matrix) -> std::array<double, 9> {
    return {
        matrix.values[0][0],
        matrix.values[1][0],
        matrix.values[2][0],
        matrix.values[0][1],
        matrix.values[1][1],
        matrix.values[2][1],
        matrix.values[0][2],
        matrix.values[1][2],
        matrix.values[2][2],
    };
}

auto conventional_candidate_to_dict(const piep::postprocessing::ConventionalCandidate& candidate) -> py::dict {
    py::dict result;
    result["strict_system"] = static_cast<int>(candidate.strict_system);
    result["legacy_system"] = static_cast<int>(candidate.legacy_system);
    result["strict_system_name"] = crystal_system_name(candidate.strict_system);
    result["legacy_system_name"] = crystal_system_name(candidate.legacy_system);
    result["centering"] = std::string(1, candidate.centering);
    result["cell"] = candidate.cell.as_array();
    result["reduced_to_conventional"] = matrix_to_legacy_column_major(candidate.reduced_to_conventional);
    result["conventional_to_reduced"] = matrix_to_legacy_column_major(candidate.conventional_to_reduced);
    result["strict_error"] = candidate.strict_error;
    result["legacy_error"] = candidate.legacy_error;
    result["transform_complexity"] = candidate.transform_complexity;
    result["rounded_transform"] = candidate.rounded_transform;
    return result;
}

auto conventionalization_to_dict(const piep::postprocessing::ConventionalizationResult& result_value) -> py::dict {
    py::dict result;
    py::list candidates;
    for (const auto& candidate : result_value.candidates) {
        candidates.append(conventional_candidate_to_dict(candidate));
    }

    result["input_cell"] = result_value.input_cell.as_array();
    result["input_centering"] = std::string(1, result_value.input_centering);
    result["primitive_input_cell"] = result_value.primitive_input_cell.as_array();
    result["reduced_primitive_cell"] = result_value.reduced_primitive_cell.as_array();
    result["candidates"] = candidates;
    result["preferred_candidate"] = result_value.preferred_candidate.has_value()
                                        ? py::object(conventional_candidate_to_dict(*result_value.preferred_candidate))
                                        : py::none();
    return result;
}

auto reduced_cell_comparison_to_dict(const piep::postprocessing::ReducedCellComparison& comparison) -> py::dict {
    py::dict result;
    result["lhs_reduced"] = comparison.lhs_reduced.as_array();
    result["rhs_reduced"] = comparison.rhs_reduced.as_array();
    result["lhs_ab_ratio"] = comparison.lhs_ab_ratio;
    result["rhs_ab_ratio"] = comparison.rhs_ab_ratio;
    result["lhs_cb_ratio"] = comparison.lhs_cb_ratio;
    result["rhs_cb_ratio"] = comparison.rhs_cb_ratio;
    result["alpha_error_deg"] = comparison.alpha_error_deg;
    result["beta_error_deg"] = comparison.beta_error_deg;
    result["gamma_error_deg"] = comparison.gamma_error_deg;
    result["equivalent"] = comparison.equivalent;
    return result;
}

}  // namespace

PYBIND11_MODULE(piep_core, module) {
    module.doc() = "PIEP modernization geometry/debug bindings";

    using namespace pybind11::literals;

    module.def("dot3", [](const std::array<double, 3>& lhs, const std::array<double, 3>& rhs) {
        return piep::math::dot(from_array(lhs), from_array(rhs));
    });

    module.def("cross3", [](const std::array<double, 3>& lhs, const std::array<double, 3>& rhs) {
        return piep::math::cross(from_array(lhs), from_array(rhs)).as_array();
    });

    module.def("cell_volume", [](double a, double b, double c, double alpha_deg, double beta_deg, double gamma_deg) {
        return piep::crystal::direct_volume(make_cell(a, b, c, alpha_deg, beta_deg, gamma_deg));
    });

    module.def("cell_metric", [](double a, double b, double c, double alpha_deg, double beta_deg, double gamma_deg) {
        return piep::crystal::to_metric(make_cell(a, b, c, alpha_deg, beta_deg, gamma_deg)).as_array();
    });

    module.def("reciprocal_cell",
               [](double a, double b, double c, double alpha_deg, double beta_deg, double gamma_deg) {
                   return piep::crystal::reciprocal_cell(make_cell(a, b, c, alpha_deg, beta_deg, gamma_deg))
                       .as_array();
               });

    module.def("orth1_coefficients",
               [](double a, double b, double c, double alpha_deg, double beta_deg, double gamma_deg) {
                   const auto cell = make_cell(a, b, c, alpha_deg, beta_deg, gamma_deg);
                   const auto metric = piep::crystal::to_metric(cell);
                   return piep::crystal::orth1(metric, piep::crystal::direct_volume(metric)).as_array();
               });

    module.def("orth_direct_coefficients",
               [](double a, double b, double c, double alpha_deg, double beta_deg, double gamma_deg) {
                   const auto cell = make_cell(a, b, c, alpha_deg, beta_deg, gamma_deg);
                   const auto metric = piep::crystal::to_metric(cell);
                   const double volume = piep::crystal::direct_volume(metric);
                   return piep::crystal::orth(piep::crystal::reciprocal_metric(metric), metric, volume)
                       .direct.as_array();
               });

    module.def(
        "apply_basis_change",
        [](double a,
           double b,
           double c,
           double alpha_deg,
           double beta_deg,
           double gamma_deg,
           const std::array<double, 9>& transform_column_major) {
            return piep::crystal::apply_basis_change(
                       make_cell(a, b, c, alpha_deg, beta_deg, gamma_deg),
                       from_legacy_column_major(transform_column_major))
                .as_array();
        },
        py::arg("a"),
        py::arg("b"),
        py::arg("c"),
        py::arg("alpha_deg"),
        py::arg("beta_deg"),
        py::arg("gamma_deg"),
        py::arg("transform_column_major"));

    module.def(
        "reduce_cell",
        [](double a,
           double b,
           double c,
           double alpha_deg,
           double beta_deg,
           double gamma_deg,
           const std::string& centering) {
            return piep::crystal::reduce_cell(
                       make_cell(a, b, c, alpha_deg, beta_deg, gamma_deg),
                       centering_from_string(centering))
                .as_array();
        },
        py::arg("a"),
        py::arg("b"),
        py::arg("c"),
        py::arg("alpha_deg"),
        py::arg("beta_deg"),
        py::arg("gamma_deg"),
        py::arg("centering") = "P");

    module.def("reduce_zone_basis", [](double first_length, double second_length, double angle_deg) {
        return piep::crystal::reduce_zone_basis({first_length, second_length, angle_deg}).as_array();
    });

    module.def(
        "delaunay_reduce_cell",
        [](double a,
           double b,
           double c,
           double alpha_deg,
           double beta_deg,
           double gamma_deg,
           const std::string& centering) {
            return delaunay_reduction_to_dict(piep::postprocessing::delaunay_reduce_cell(
                make_cell(a, b, c, alpha_deg, beta_deg, gamma_deg), centering_from_string(centering)));
        },
        py::arg("a"),
        py::arg("b"),
        py::arg("c"),
        py::arg("alpha_deg"),
        py::arg("beta_deg"),
        py::arg("gamma_deg"),
        py::arg("centering") = "P");

    module.def(
        "compare_reduced_cells",
        [](double lhs_a,
           double lhs_b,
           double lhs_c,
           double lhs_alpha_deg,
           double lhs_beta_deg,
           double lhs_gamma_deg,
           const std::string& lhs_centering,
           double rhs_a,
           double rhs_b,
           double rhs_c,
           double rhs_alpha_deg,
           double rhs_beta_deg,
           double rhs_gamma_deg,
           const std::string& rhs_centering,
           double angle_tolerance_deg,
           double axis_ratio_relative_tolerance) {
            return reduced_cell_comparison_to_dict(piep::postprocessing::compare_reduced_cells(
                make_cell(lhs_a, lhs_b, lhs_c, lhs_alpha_deg, lhs_beta_deg, lhs_gamma_deg),
                centering_from_string(lhs_centering),
                make_cell(rhs_a, rhs_b, rhs_c, rhs_alpha_deg, rhs_beta_deg, rhs_gamma_deg),
                centering_from_string(rhs_centering),
                {
                    angle_tolerance_deg,
                    axis_ratio_relative_tolerance,
                }));
        },
        py::arg("lhs_a"),
        py::arg("lhs_b"),
        py::arg("lhs_c"),
        py::arg("lhs_alpha_deg"),
        py::arg("lhs_beta_deg"),
        py::arg("lhs_gamma_deg"),
        py::arg("lhs_centering") = "P",
        py::arg("rhs_a"),
        py::arg("rhs_b"),
        py::arg("rhs_c"),
        py::arg("rhs_alpha_deg"),
        py::arg("rhs_beta_deg"),
        py::arg("rhs_gamma_deg"),
        py::arg("rhs_centering") = "P",
        py::arg("angle_tolerance_deg") = 2.0,
        py::arg("axis_ratio_relative_tolerance") = 0.05);

    module.def(
        "conventionalize_cell",
        [](double a,
           double b,
           double c,
           double alpha_deg,
           double beta_deg,
           double gamma_deg,
           const std::string& centering,
           const std::string& preferred_centering,
           const std::string& minimum_system,
           double strict_angle_deg,
           double strict_axis_relative,
           double legacy_angle_deg,
           double legacy_axis_relative) {
            return conventionalization_to_dict(piep::postprocessing::conventionalize_cell(
                make_cell(a, b, c, alpha_deg, beta_deg, gamma_deg),
                centering_from_string(centering),
                {
                    centering_from_string(preferred_centering.empty() ? " " : preferred_centering),
                    crystal_system_from_string(minimum_system),
                    {
                        strict_angle_deg,
                        strict_axis_relative,
                    },
                    {
                        legacy_angle_deg,
                        legacy_axis_relative,
                    },
                }));
        },
        py::arg("a"),
        py::arg("b"),
        py::arg("c"),
        py::arg("alpha_deg"),
        py::arg("beta_deg"),
        py::arg("gamma_deg"),
        py::arg("centering") = "P",
        py::arg("preferred_centering") = "",
        py::arg("minimum_system") = "triclinic",
        py::arg("strict_angle_deg") = 2.0,
        py::arg("strict_axis_relative") = 0.05,
        py::arg("legacy_angle_deg") = 4.0,
        py::arg("legacy_axis_relative") = 0.10);

    module.def("pattern_fields_round_trip",
               [](std::string title, const std::array<double, 18>& fields) {
                   return pattern_from_fields(std::move(title), fields).as_legacy_numeric_fields();
               });

    module.def(
        "observation_from_reciprocal_vectors",
        [](std::string title,
           const std::array<double, 2>& first_vector_inverse_angstrom,
           const std::array<double, 2>& second_vector_inverse_angstrom,
           double camera_constant,
           double camera_constant_sigma,
           double first_length_sigma_inverse_angstrom,
           double second_length_sigma_inverse_angstrom,
           double angle_sigma_deg,
           double third_radius_sigma,
           double high_voltage_volts,
           double wavelength_angstrom) {
            return observation_to_dict(piep::search::observation_from_reciprocal_vectors({
                std::move(title),
                first_vector_inverse_angstrom,
                second_vector_inverse_angstrom,
                camera_constant,
                camera_constant_sigma,
                first_length_sigma_inverse_angstrom,
                second_length_sigma_inverse_angstrom,
                angle_sigma_deg,
                third_radius_sigma,
                high_voltage_volts,
                wavelength_angstrom,
            }));
        },
        py::arg("title"),
        py::arg("first_vector_inverse_angstrom"),
        py::arg("second_vector_inverse_angstrom"),
        py::arg("camera_constant"),
        py::arg("camera_constant_sigma") = 0.0,
        py::arg("first_length_sigma_inverse_angstrom") = 0.0,
        py::arg("second_length_sigma_inverse_angstrom") = 0.0,
        py::arg("angle_sigma_deg") = 2.5,
        py::arg("third_radius_sigma") = 0.0,
        py::arg("high_voltage_volts") = 0.0,
        py::arg("wavelength_angstrom") = 0.0);

    module.def(
        "observation_from_detector_geometry",
        [](std::string title,
           const std::array<double, 2>& first_spot_pixels,
           const std::array<double, 2>& second_spot_pixels,
           const std::array<double, 2>& direct_beam_pixels,
           double detector_distance_mm,
           double wavelength_angstrom,
           double pixel_size_x_mm,
           double pixel_size_y_mm,
           double camera_constant_sigma,
           double radius_sigma_mm,
           double angle_sigma_deg,
           double third_radius_sigma,
           double high_voltage_volts) {
            return observation_to_dict(piep::search::observation_from_detector_geometry({
                std::move(title),
                first_spot_pixels,
                second_spot_pixels,
                direct_beam_pixels,
                detector_distance_mm,
                wavelength_angstrom,
                pixel_size_x_mm,
                pixel_size_y_mm,
                camera_constant_sigma,
                radius_sigma_mm,
                angle_sigma_deg,
                third_radius_sigma,
                high_voltage_volts,
            }));
        },
        py::arg("title"),
        py::arg("first_spot_pixels"),
        py::arg("second_spot_pixels"),
        py::arg("direct_beam_pixels"),
        py::arg("detector_distance_mm"),
        py::arg("wavelength_angstrom"),
        py::arg("pixel_size_x_mm"),
        py::arg("pixel_size_y_mm") = 0.0,
        py::arg("camera_constant_sigma") = 0.0,
        py::arg("radius_sigma_mm") = 0.0,
        py::arg("angle_sigma_deg") = 2.5,
        py::arg("third_radius_sigma") = 0.0,
        py::arg("high_voltage_volts") = 0.0);

    module.def(
        "restore_pattern_from_fields",
        [](std::string title,
           const std::array<double, 18>& fields,
           double default_high_voltage_volts,
           double default_laue_zone_zero_sigma,
           double default_laue_zone_one_sigma) {
            return restored_pattern_to_dict(
                piep::search::restore_pattern(
                    pattern_from_fields(std::move(title), fields),
                    make_pattern_settings(
                        default_high_voltage_volts,
                        default_laue_zone_zero_sigma,
                        default_laue_zone_one_sigma)));
        },
        py::arg("title"),
        py::arg("fields"),
        py::arg("default_high_voltage_volts"),
        py::arg("default_laue_zone_zero_sigma"),
        py::arg("default_laue_zone_one_sigma"));

    module.def(
        "prepare_pattern_from_fields",
        [](std::string title,
           const std::array<double, 18>& fields,
           double default_high_voltage_volts,
           double default_laue_zone_zero_sigma,
           double default_laue_zone_one_sigma) {
            return prepared_pattern_to_dict(
                piep::search::prepare_pattern(
                    pattern_from_fields(std::move(title), fields),
                    make_pattern_settings(
                        default_high_voltage_volts,
                        default_laue_zone_zero_sigma,
                        default_laue_zone_one_sigma)));
        },
        py::arg("title"),
        py::arg("fields"),
        py::arg("default_high_voltage_volts"),
        py::arg("default_laue_zone_zero_sigma"),
        py::arg("default_laue_zone_one_sigma"));

    module.def(
        "prepare_pattern_with_temporary_errors_from_fields",
        [](std::string title,
           const std::array<double, 18>& fields,
           double default_high_voltage_volts,
           double default_laue_zone_zero_sigma,
           double default_laue_zone_one_sigma,
           double minimum_relative_sigma_fraction,
           double minimum_angle_sigma_deg) {
            return prepared_pattern_to_dict(
                piep::search::prepare_pattern_with_temporary_errors(
                    pattern_from_fields(std::move(title), fields),
                    make_pattern_settings(
                        default_high_voltage_volts,
                        default_laue_zone_zero_sigma,
                        default_laue_zone_one_sigma),
                    {
                        minimum_relative_sigma_fraction,
                        minimum_angle_sigma_deg,
                    }));
        },
        py::arg("title"),
        py::arg("fields"),
        py::arg("default_high_voltage_volts"),
        py::arg("default_laue_zone_zero_sigma"),
        py::arg("default_laue_zone_one_sigma"),
        py::arg("minimum_relative_sigma_fraction"),
        py::arg("minimum_angle_sigma_deg"));

    module.def(
        "simulate_pattern_from_indices",
        [](std::string title,
           double a,
           double b,
           double c,
           double alpha_deg,
           double beta_deg,
           double gamma_deg,
           const std::array<int, 3>& first_hkl,
           const std::array<int, 3>& second_hkl,
           double camera_constant,
           double camera_constant_sigma,
           double angle_sigma_deg,
           double high_voltage_volts) {
            return observation_to_dict(
                piep::indexing::simulate_pattern_observation(
                    std::move(title),
                    make_cell(a, b, c, alpha_deg, beta_deg, gamma_deg),
                    {
                        first_hkl[0],
                        first_hkl[1],
                        first_hkl[2],
                    },
                    {
                        second_hkl[0],
                        second_hkl[1],
                        second_hkl[2],
                    },
                    camera_constant,
                    camera_constant_sigma,
                    angle_sigma_deg,
                    high_voltage_volts));
        },
        py::arg("title"),
        py::arg("a"),
        py::arg("b"),
        py::arg("c"),
        py::arg("alpha_deg"),
        py::arg("beta_deg"),
        py::arg("gamma_deg"),
        py::arg("first_hkl"),
        py::arg("second_hkl"),
        py::arg("camera_constant"),
        py::arg("camera_constant_sigma"),
        py::arg("angle_sigma_deg"),
        py::arg("high_voltage_volts") = 0.0);

    module.def(
        "simulate_observation_from_zone_pair",
        [](std::string title,
           double a,
           double b,
           double c,
           double alpha_deg,
           double beta_deg,
           double gamma_deg,
           const py::object& zone_definition,
           const std::array<int, 3>& first_hkl,
           const std::array<int, 3>& second_hkl,
           double camera_constant,
           double maximum_radius_mm,
           const std::string& centering,
           double minimum_radius_mm,
           bool include_friedel_mates,
           bool include_origin,
           double reciprocal_length_padding_fraction,
           std::size_t maximum_spot_count,
           double positional_sigma_mm,
           double reported_radius_sigma_mm,
           double reported_angle_sigma_deg,
           double camera_constant_sigma,
           double high_voltage_volts,
           std::uint64_t seed) {
            const piep::simulation::ZoneDirection zone = zone_direction_from_iterable_item(zone_definition);
            const char centering_code = centering_from_string(centering);
            const auto pattern = piep::simulation::simulate_zone_pattern(
                title,
                make_cell(a, b, c, alpha_deg, beta_deg, gamma_deg),
                zone,
                {
                    centering_code,
                    camera_constant,
                    minimum_radius_mm,
                    maximum_radius_mm,
                    include_friedel_mates,
                    include_origin,
                    reciprocal_length_padding_fraction,
                    maximum_spot_count,
                });

            const auto first_index = find_spot_index(pattern, miller_index_from_array(first_hkl));
            const auto second_index = find_spot_index(pattern, miller_index_from_array(second_hkl));
            const auto selection = piep::simulation::BasisPairSelection {
                first_index,
                second_index,
                miller_index_from_array(first_hkl),
                miller_index_from_array(second_hkl),
                piep::indexing::detail::zone_axis(miller_index_from_array(first_hkl),
                                                  miller_index_from_array(second_hkl)),
                piep::indexing::detail::zone_multiplicity(
                    miller_index_from_array(first_hkl), miller_index_from_array(second_hkl), centering_code),
                {
                    pattern.spots[first_index].reciprocal_length,
                    pattern.spots[second_index].reciprocal_length,
                    piep::simulation::detail::angle_between_detector_vectors(
                        pattern.spots[first_index].detector_coordinates_mm,
                        pattern.spots[second_index].detector_coordinates_mm),
                },
            };
            return simulated_observation_to_dict(piep::simulation::simulate_observation_from_pair(
                std::move(title),
                pattern,
                selection,
                {
                    positional_sigma_mm,
                    reported_radius_sigma_mm,
                    reported_angle_sigma_deg,
                    camera_constant_sigma,
                    high_voltage_volts,
                    seed,
                }));
        },
        py::arg("title"),
        py::arg("a"),
        py::arg("b"),
        py::arg("c"),
        py::arg("alpha_deg"),
        py::arg("beta_deg"),
        py::arg("gamma_deg"),
        py::arg("zone_definition"),
        py::arg("first_hkl"),
        py::arg("second_hkl"),
        py::arg("camera_constant"),
        py::arg("maximum_radius_mm"),
        py::arg("centering") = "P",
        py::arg("minimum_radius_mm") = 0.0,
        py::arg("include_friedel_mates") = true,
        py::arg("include_origin") = false,
        py::arg("reciprocal_length_padding_fraction") = 0.02,
        py::arg("maximum_spot_count") = 0,
        py::arg("positional_sigma_mm") = 0.0,
        py::arg("reported_radius_sigma_mm") = 0.0,
        py::arg("reported_angle_sigma_deg") = 2.5,
        py::arg("camera_constant_sigma") = 0.0,
        py::arg("high_voltage_volts") = 0.0,
        py::arg("seed") = 0);

    module.def(
        "enumerate_zone_axes",
        [](int maximum_index, bool primitive_only, bool canonical_half_space_only, std::size_t maximum_zone_count) {
            py::list result;
            for (const auto& axis : piep::simulation::enumerate_zone_axes(
                     {
                         maximum_index,
                         primitive_only,
                         canonical_half_space_only,
                         maximum_zone_count,
                     })) {
                result.append(axis.as_array());
            }
            return result;
        },
        py::arg("maximum_index"),
        py::arg("primitive_only") = true,
        py::arg("canonical_half_space_only") = true,
        py::arg("maximum_zone_count") = 0);

    module.def(
        "simulate_zone_pattern",
        [](std::string title,
           double a,
           double b,
           double c,
           double alpha_deg,
           double beta_deg,
           double gamma_deg,
           const py::object& zone_definition,
           double camera_constant,
           double maximum_radius_mm,
           const std::string& centering,
           double minimum_radius_mm,
           bool include_friedel_mates,
           bool include_origin,
           double reciprocal_length_padding_fraction,
           std::size_t maximum_spot_count) {
            const char centering_code = centering_from_string(centering);
            return simulated_pattern_to_dict(
                piep::simulation::simulate_zone_pattern(
                    std::move(title),
                    make_cell(a, b, c, alpha_deg, beta_deg, gamma_deg),
                    zone_direction_from_iterable_item(zone_definition),
                    {
                        centering_code,
                        camera_constant,
                        minimum_radius_mm,
                        maximum_radius_mm,
                        include_friedel_mates,
                        include_origin,
                        reciprocal_length_padding_fraction,
                        maximum_spot_count,
                    }),
                centering_code);
        },
        py::arg("title"),
        py::arg("a"),
        py::arg("b"),
        py::arg("c"),
        py::arg("alpha_deg"),
        py::arg("beta_deg"),
        py::arg("gamma_deg"),
        py::arg("zone_definition"),
        py::arg("camera_constant"),
        py::arg("maximum_radius_mm"),
        py::arg("centering") = "P",
        py::arg("minimum_radius_mm") = 0.0,
        py::arg("include_friedel_mates") = true,
        py::arg("include_origin") = false,
        py::arg("reciprocal_length_padding_fraction") = 0.02,
        py::arg("maximum_spot_count") = 0);

    module.def(
        "simulate_zone_observation_ensemble",
        [](std::string title_prefix,
           double a,
           double b,
           double c,
           double alpha_deg,
           double beta_deg,
           double gamma_deg,
           const py::iterable& zones,
           double camera_constant,
           double maximum_radius_mm,
           std::size_t realizations_per_zone,
           const std::string& centering,
           double minimum_radius_mm,
           bool include_friedel_mates,
           bool include_origin,
           double reciprocal_length_padding_fraction,
           std::size_t maximum_spot_count,
           double minimum_basis_angle_deg,
           double maximum_basis_angle_deg,
           int maximum_zone_multiplicity,
           double positional_sigma_mm,
           double reported_radius_sigma_mm,
           double reported_angle_sigma_deg,
           double camera_constant_sigma,
           double high_voltage_volts,
           std::uint64_t seed) {
            const char centering_code = centering_from_string(centering);
            return observation_ensemble_to_dict(
                piep::simulation::simulate_zone_observation_ensemble(
                    std::move(title_prefix),
                    make_cell(a, b, c, alpha_deg, beta_deg, gamma_deg),
                    zone_directions_from_iterable(zones),
                    {
                        centering_code,
                        camera_constant,
                        minimum_radius_mm,
                        maximum_radius_mm,
                        include_friedel_mates,
                        include_origin,
                        reciprocal_length_padding_fraction,
                        maximum_spot_count,
                    },
                    realizations_per_zone,
                    {
                        minimum_basis_angle_deg,
                        maximum_basis_angle_deg,
                        maximum_zone_multiplicity,
                    },
                    {
                        positional_sigma_mm,
                        reported_radius_sigma_mm,
                        reported_angle_sigma_deg,
                        camera_constant_sigma,
                        high_voltage_volts,
                        seed,
                    }),
                centering_code);
        },
        py::arg("title_prefix"),
        py::arg("a"),
        py::arg("b"),
        py::arg("c"),
        py::arg("alpha_deg"),
        py::arg("beta_deg"),
        py::arg("gamma_deg"),
        py::arg("zones"),
        py::arg("camera_constant"),
        py::arg("maximum_radius_mm"),
        py::arg("realizations_per_zone") = 1,
        py::arg("centering") = "P",
        py::arg("minimum_radius_mm") = 0.0,
        py::arg("include_friedel_mates") = true,
        py::arg("include_origin") = false,
        py::arg("reciprocal_length_padding_fraction") = 0.02,
        py::arg("maximum_spot_count") = 0,
        py::arg("minimum_basis_angle_deg") = 5.0,
        py::arg("maximum_basis_angle_deg") = 175.0,
        py::arg("maximum_zone_multiplicity") = 1,
        py::arg("positional_sigma_mm") = 0.0,
        py::arg("reported_radius_sigma_mm") = 0.0,
        py::arg("reported_angle_sigma_deg") = 2.5,
        py::arg("camera_constant_sigma") = 0.0,
        py::arg("high_voltage_volts") = 0.0,
        py::arg("seed") = 0);

    module.def(
        "enumerate_reflections_from_fields",
        [](std::string title,
           const std::array<double, 18>& fields,
           double a,
           double b,
           double c,
           double alpha_deg,
           double beta_deg,
           double gamma_deg,
           const std::string& centering,
           double default_high_voltage_volts,
           double default_laue_zone_zero_sigma,
           double default_laue_zone_one_sigma,
           std::size_t max_reflections_per_pool) {
            const auto prepared = piep::search::prepare_pattern(
                pattern_from_fields(std::move(title), fields),
                make_pattern_settings(
                    default_high_voltage_volts,
                    default_laue_zone_zero_sigma,
                    default_laue_zone_one_sigma));
            piep::indexing::IndexingSettings settings;
            settings.max_reflections_per_pool = max_reflections_per_pool;
            return reflection_enumeration_to_dict(
                piep::indexing::enumerate_reflections(
                    prepared,
                    make_cell(a, b, c, alpha_deg, beta_deg, gamma_deg),
                    centering_from_string(centering),
                    settings));
        },
        py::arg("title"),
        py::arg("fields"),
        py::arg("a"),
        py::arg("b"),
        py::arg("c"),
        py::arg("alpha_deg"),
        py::arg("beta_deg"),
        py::arg("gamma_deg"),
        py::arg("centering") = "P",
        py::arg("default_high_voltage_volts"),
        py::arg("default_laue_zone_zero_sigma"),
        py::arg("default_laue_zone_one_sigma"),
        py::arg("max_reflections_per_pool") = 1999);

    module.def(
        "index_pattern_from_fields",
        [](std::string title,
           const std::array<double, 18>& fields,
           double a,
           double b,
           double c,
           double alpha_deg,
           double beta_deg,
           double gamma_deg,
           const std::string& centering,
           double default_high_voltage_volts,
           double default_laue_zone_zero_sigma,
           double default_laue_zone_one_sigma,
           std::size_t max_reflections_per_pool,
           std::size_t max_stored_matches) {
            piep::indexing::IndexingSettings settings;
            settings.max_reflections_per_pool = max_reflections_per_pool;
            settings.max_stored_matches = max_stored_matches;
            return indexing_result_to_dict(
                piep::indexing::index_pattern(
                    pattern_from_fields(std::move(title), fields),
                    make_cell(a, b, c, alpha_deg, beta_deg, gamma_deg),
                    centering_from_string(centering),
                    make_pattern_settings(
                        default_high_voltage_volts,
                        default_laue_zone_zero_sigma,
                        default_laue_zone_one_sigma),
                    settings));
        },
        py::arg("title"),
        py::arg("fields"),
        py::arg("a"),
        py::arg("b"),
        py::arg("c"),
        py::arg("alpha_deg"),
        py::arg("beta_deg"),
        py::arg("gamma_deg"),
        py::arg("centering") = "P",
        py::arg("default_high_voltage_volts"),
        py::arg("default_laue_zone_zero_sigma"),
        py::arg("default_laue_zone_one_sigma"),
        py::arg("max_reflections_per_pool") = 1999,
        py::arg("max_stored_matches") = 199);

    module.def(
        "select_reference_pattern_from_fields",
        [](const py::iterable& patterns,
           double default_high_voltage_volts,
           double default_laue_zone_zero_sigma,
           double default_laue_zone_one_sigma,
           double wall_sigma_multiplier,
           bool force_full_grid) {
            const auto settings = make_pattern_settings(
                default_high_voltage_volts,
                default_laue_zone_zero_sigma,
                default_laue_zone_one_sigma);
            return reference_selection_to_dict(
                piep::search::select_reference_pattern(
                    search_patterns_from_iterable(patterns, settings),
                    {
                        0.001,
                        0.2,
                        0.005,
                        0.0001,
                        0.01,
                        force_full_grid,
                        wall_sigma_multiplier,
                    }));
        },
        py::arg("patterns"),
        py::arg("default_high_voltage_volts"),
        py::arg("default_laue_zone_zero_sigma"),
        py::arg("default_laue_zone_one_sigma"),
        py::arg("wall_sigma_multiplier") = 0.0,
        py::arg("force_full_grid") = false);

    module.def(
        "initialize_search_grid_from_fields",
        [](const py::iterable& patterns,
           double volume_min,
           double volume_max,
           const std::string& increment_mode,
           double increment_value,
           double default_high_voltage_volts,
           double default_laue_zone_zero_sigma,
           double default_laue_zone_one_sigma,
           double wall_sigma_multiplier,
           bool force_full_grid) {
            const auto settings = make_pattern_settings(
                default_high_voltage_volts,
                default_laue_zone_zero_sigma,
                default_laue_zone_one_sigma);
            return search_grid_to_dict(
                piep::search::initialize_search_grid(
                    search_patterns_from_iterable(patterns, settings),
                    {
                        volume_min,
                        volume_max,
                    },
                    increment_specification_from_string(increment_mode, increment_value),
                    {
                        0.001,
                        0.2,
                        0.005,
                        0.0001,
                        0.01,
                        force_full_grid,
                        wall_sigma_multiplier,
                    }));
        },
        py::arg("patterns"),
        py::arg("volume_min"),
        py::arg("volume_max"),
        py::arg("increment_mode"),
        py::arg("increment_value"),
        py::arg("default_high_voltage_volts"),
        py::arg("default_laue_zone_zero_sigma"),
        py::arg("default_laue_zone_one_sigma"),
        py::arg("wall_sigma_multiplier") = 0.0,
        py::arg("force_full_grid") = false);

    module.def(
        "generate_search_candidates_from_fields",
        [](const py::iterable& patterns,
           double volume_min,
           double volume_max,
           const std::string& increment_mode,
           double increment_value,
           double default_high_voltage_volts,
           double default_laue_zone_zero_sigma,
           double default_laue_zone_one_sigma,
           double wall_sigma_multiplier,
           bool force_full_grid,
           double reduction_cosine_limit,
           std::size_t candidate_limit) {
            const auto settings = make_pattern_settings(
                default_high_voltage_volts,
                default_laue_zone_zero_sigma,
                default_laue_zone_one_sigma);
            const auto grid = piep::search::initialize_search_grid(
                search_patterns_from_iterable(patterns, settings),
                {
                    volume_min,
                    volume_max,
                },
                increment_specification_from_string(increment_mode, increment_value),
                {
                    0.001,
                    0.2,
                    0.005,
                    0.0001,
                    0.01,
                    force_full_grid,
                    wall_sigma_multiplier,
                });
            return candidate_generation_to_dict(
                piep::search::generate_search_candidates(
                    grid,
                    {
                        reduction_cosine_limit,
                        candidate_limit,
                    }));
        },
        py::arg("patterns"),
        py::arg("volume_min"),
        py::arg("volume_max"),
        py::arg("increment_mode"),
        py::arg("increment_value"),
        py::arg("default_high_voltage_volts"),
        py::arg("default_laue_zone_zero_sigma"),
        py::arg("default_laue_zone_one_sigma"),
        py::arg("wall_sigma_multiplier") = 0.0,
        py::arg("force_full_grid") = false,
        py::arg("reduction_cosine_limit") = 0.5,
        py::arg("candidate_limit") = 0);

    module.def(
        "evaluate_candidate_cell_from_fields",
        [](const py::iterable& patterns,
           double a,
           double b,
           double c,
           double alpha_deg,
           double beta_deg,
           double gamma_deg,
           const std::string& centering,
           double default_high_voltage_volts,
           double default_laue_zone_zero_sigma,
           double default_laue_zone_one_sigma,
           std::size_t max_reflections_per_pool,
           std::size_t max_stored_matches) {
            const auto settings = make_pattern_settings(
                default_high_voltage_volts,
                default_laue_zone_zero_sigma,
                default_laue_zone_one_sigma);
            const auto search_patterns = search_patterns_from_iterable(patterns, settings);

            std::vector<std::size_t> active_slots;
            active_slots.reserve(search_patterns.size());
            for (const auto& pattern : search_patterns) {
                if (!pattern.excluded) {
                    active_slots.push_back(pattern.slot);
                }
            }

            piep::search::SearchCandidate candidate;
            candidate.direct_cell = make_cell(a, b, c, alpha_deg, beta_deg, gamma_deg);

            piep::indexing::IndexingSettings indexing_settings;
            indexing_settings.max_reflections_per_pool = max_reflections_per_pool;
            indexing_settings.max_stored_matches = max_stored_matches;

            return search_candidate_evaluation_to_dict(
                piep::search::evaluate_search_candidate(
                    search_patterns,
                    active_slots,
                    candidate,
                    centering_from_string(centering),
                    indexing_settings));
        },
        py::arg("patterns"),
        py::arg("a"),
        py::arg("b"),
        py::arg("c"),
        py::arg("alpha_deg"),
        py::arg("beta_deg"),
        py::arg("gamma_deg"),
        py::arg("centering") = "P",
        py::arg("default_high_voltage_volts"),
        py::arg("default_laue_zone_zero_sigma"),
        py::arg("default_laue_zone_one_sigma"),
        py::arg("max_reflections_per_pool") = 1999,
        py::arg("max_stored_matches") = 199);

    module.def(
        "search_unit_cells_from_fields",
        [](const py::iterable& patterns,
           double volume_min,
           double volume_max,
           const std::string& increment_mode,
           double increment_value,
           const std::string& centering,
           double default_high_voltage_volts,
           double default_laue_zone_zero_sigma,
           double default_laue_zone_one_sigma,
           double wall_sigma_multiplier,
           bool force_full_grid,
           double reduction_cosine_limit,
           std::size_t candidate_limit,
           std::size_t max_reflections_per_pool,
           std::size_t max_stored_matches,
           std::size_t max_candidates,
           double duplicate_angle_tolerance_deg,
           double duplicate_axis_ratio_tolerance,
           double duplicate_support_scale) {
            const auto settings = make_pattern_settings(
                default_high_voltage_volts,
                default_laue_zone_zero_sigma,
                default_laue_zone_one_sigma);
            piep::indexing::IndexingSettings indexing_settings;
            indexing_settings.max_reflections_per_pool = max_reflections_per_pool;
            indexing_settings.max_stored_matches = max_stored_matches;

            return search_engine_to_dict(
                piep::search::search_unit_cells(
                    search_patterns_from_iterable(patterns, settings),
                    {
                        volume_min,
                        volume_max,
                    },
                    centering_from_string(centering),
                    increment_specification_from_string(increment_mode, increment_value),
                    {
                        0.001,
                        0.2,
                        0.005,
                        0.0001,
                        0.01,
                        force_full_grid,
                        wall_sigma_multiplier,
                    },
                    {},
                    {
                        reduction_cosine_limit,
                        candidate_limit,
                    },
                    {
                        indexing_settings,
                        {
                            max_candidates,
                            duplicate_angle_tolerance_deg,
                            duplicate_axis_ratio_tolerance,
                            duplicate_support_scale,
                        },
                    }));
        },
        py::arg("patterns"),
        py::arg("volume_min"),
        py::arg("volume_max"),
        py::arg("increment_mode"),
        py::arg("increment_value"),
        py::arg("centering") = "P",
        py::arg("default_high_voltage_volts"),
        py::arg("default_laue_zone_zero_sigma"),
        py::arg("default_laue_zone_one_sigma"),
        py::arg("wall_sigma_multiplier") = 0.0,
        py::arg("force_full_grid") = false,
        py::arg("reduction_cosine_limit") = 0.5,
        py::arg("candidate_limit") = 0,
        py::arg("max_reflections_per_pool") = 1999,
        py::arg("max_stored_matches") = 199,
        py::arg("max_candidates") = 100,
        py::arg("duplicate_angle_tolerance_deg") = 2.0,
        py::arg("duplicate_axis_ratio_tolerance") = 0.05,
        py::arg("duplicate_support_scale") = 5.0);
}
