# Phase 11: Python Workflow API

## Scope

This phase adds a notebook-friendly Python layer on top of the debug-oriented
`pybind11` binding surface.

The raw extension is still available as `piep_core`, but normal scientific use
should now go through the higher-level `piep` package in `modern/cpp/python`.

## Layout

New Python package:

- `python/piep/api.py`
- `python/piep/examples.py`
- `python/piep/__init__.py`

New Python regression target:

- `python/test_api.py`

Updated smoke target:

- `python/smoke_bindings.py`

## API Design

The package uses a small typed layer built from Python dataclasses:

- `Cell`
- `PatternObservation`
- `SearchPattern`
- `SearchDefaults`
- `SearchResult`
- `Conventionalization`
- `PatternIndexing`
- `ZoneDirection`

Important workflow helpers:

- `PatternObservation.from_reciprocal_vectors(...)`
- `PatternObservation.from_detector_geometry(...)`
- `index_pattern(...)`
- `search_unit_cells(...)`
- `search_and_conventionalize(...)`
- `delaunay_reduce_cell(...)`
- `compare_reduced_cells(...)`
- `simulate_zone_observation_ensemble(...)`
- `simulate_observation_from_zone_pair(...)`

Archived example data is provided through:

- `piep.examples.cupc_case()`
- `piep.examples.grgds_case()`
- `piep.examples.lysozyme_case()`

That keeps the notebooks and tests on a stable scientific surface rather than
forcing them to reconstruct 18-field tuples manually.

## Python Regression Coverage

`python/test_api.py` now mirrors the native suite at a high level:

- SAD-input adapter checks
- archived transcript-tight search and conventionalization
- post-processing robustness checks
- simulator-backed candidate evaluation for synthetic CuPc and GRGDS patterns
- noisy archived-match synthetic Lysozyme search with tetragonal recovery

## Notebooks

Notebook examples live in:

- `python/notebooks/01_archived_examples.ipynb`
- `python/notebooks/02_synthetic_pipeline.ipynb`

They are written as conceptual reproductions of the published examples and the
modern closed-loop workflow, with Markdown cells that connect the code to the
scientific steps described in `pub.md`.

## Outcome

The modern tree now has a usable Python-first MVP:

- typed scientific inputs
- direct access to the full non-interactive search pipeline
- regression-tested examples ready for notebooks and exploratory work

