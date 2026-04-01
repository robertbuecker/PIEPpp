# PIEP Modernization Plan

## Objective

Build a modern, maintainable reimplementation that exactly reproduces PIEP's core scientific behavior for:

- unit-cell determination from randomly oriented patterns
- indexing of individual patterns against a candidate cell

The rewrite target is not "a nicer FORTRAN". It is a layered system with:

- a deterministic C++ scientific core,
- Python bindings for scripting and analysis,
- compatibility tooling for regression against the legacy executable and the published examples.

## Guiding principles

### 1. Preserve behavior before redesigning behavior

The first milestone is scientific equivalence, not algorithmic novelty. Tolerances, search-space boundaries, reduction behavior, symmetry classification, and ranking policies must be reproduced closely enough that the published examples yield the same decisions and essentially the same numeric outputs.

### 2. Separate scientific kernels from workflow state

Legacy PIEP mixes session state, file state, command parsing, and numerical logic. The rewrite should expose pure or mostly pure computational units wherever possible.

### 3. Design for regression from day one

Every translated subsystem should immediately gain tests against the legacy executable or against frozen golden outputs extracted from the supplementary information.

### 4. Keep the first API narrow

The first public API should focus on:

- pattern representation
- cell representation
- search settings
- cell search
- indexing
- cell transformations needed for comparison

Only after those are stable should higher-level compatibility features be added.

## Proposed C++ architecture

## Layer 1: foundational math

Purpose:

- fixed-size vectors and matrices
- reciprocal/direct cell conversions
- angle and metric helpers
- robust tolerance-aware comparisons

Suggested modules:

- `math/vector3.hpp`
- `math/matrix3.hpp`
- `crystal/cell.hpp`
- `crystal/metric.hpp`
- `crystal/transforms.hpp`

Responsibilities mapped from legacy:

- `orth`, `orth1`
- `tr`, `trd`
- `xtodg`
- `m3inv`, `det`
- vector and matrix multiply helpers

## Layer 2: domain objects

Purpose:

- explicit typed data structures replacing COMMON blocks

Suggested data types:

- `PatternObservation`
- `PatternToleranceModel`
- `PreparedPattern`
- `CellParameters`
- `ReciprocalBasis`
- `SearchSettings`
- `SearchMode`
- `IndexingSettings`
- `IndexingMatch`
- `SearchCandidate`
- `SearchResult`

These objects should be immutable or near-immutable wherever feasible.

## Layer 3: search preparation

Purpose:

- transform raw pattern measurements into prepared search inputs
- choose reference pattern
- classify symmetry and search dimensionality
- derive volume bounds and layered-grid parameters

Suggested modules:

- `search/pattern_prep.hpp`
- `search/reference_selection.hpp`
- `search/search_grid.hpp`

Responsibilities mapped from legacy:

- `prep1`
- `cksg`
- `ldini`
- `vlim`
- `npl`

## Layer 4: indexing engine

Purpose:

- enumerate candidate reflections
- score pairings for one pattern
- aggregate pattern-level fits into candidate-level scores

Suggested modules:

- `indexing/reflection_enumerator.hpp`
- `indexing/pair_scorer.hpp`
- `indexing/indexing_engine.hpp`

Responsibilities mapped from legacy:

- `indi`
- `eva`
- `outp`
- `ckout`
- `ck3`

This layer is likely to dominate runtime and should be designed for future optimization.

## Layer 5: GM search engine

Purpose:

- generate candidate cells from the layered search coordinates
- evaluate each candidate
- suppress duplicates
- rank final results

Suggested modules:

- `search/gm_search.hpp`
- `search/candidate_generator.hpp`
- `search/candidate_store.hpp`

Responsibilities mapped from legacy:

- `rlgen`
- `rlg`
- `ck`
- `del1`
- `orden`

## Layer 6: cell post-processing

Purpose:

- Delaunay-related transforms
- basis changes
- conventional settings
- reduced-cell comparison helpers

Suggested modules:

- `crystal/reduction.hpp`
- `crystal/conventionalization.hpp`
- `crystal/basis_change.hpp`

Responsibilities mapped from legacy:

- `del`
- `delc`
- parts of `ca`
- `mvvm`

## Proposed Python interface

The Python layer should not mirror the legacy command vocabulary. It should expose domain operations directly.

Example conceptual API:

```python
patterns = piep.load_patterns("sad.dat")
prepared = piep.prepare_patterns(patterns, tolerances=...)

results = piep.search_unit_cells(
    prepared,
    volume_range=(vmin, vmax),
    reference_pattern=19,
    mode="auto",
)

cell = results.best_cell()
indexing = piep.index_pattern(prepared[0], cell)
```

Recommended Python packages:

- `piep.core`: low-level bindings
- `piep.search`: high-level cell determination workflow
- `piep.indexing`: direct indexing utilities
- `piep.io`: readers for legacy files and modern structured formats
- `piep.compat`: optional helpers for reproducing legacy command behavior

Bindings should be implemented with `pybind11`.

## Compatibility surface

The rewrite should support three user-facing modes.

### 1. Native library mode

Modern C++ and Python API centered on explicit objects and function calls.

### 2. Batch CLI mode

Deterministic command-line tools for search, indexing, and conversions.

### 3. Legacy compatibility mode

A limited shell or script runner that can replay important PIEP workflows closely enough for regression testing and user migration.

This compatibility layer should remain thin. It must not become the new core architecture.

## Phased implementation plan

### Phase 0: freeze legacy behavior

- compile the legacy executable reproducibly
- capture exact outputs for the three supplementary examples
- normalize those outputs into machine-checkable fixtures
- document accepted numeric tolerances for comparison

Deliverable:

- golden regression corpus

### Phase 1: geometry kernel

- implement cell and reciprocal-basis conversions
- implement matrix and vector helpers
- reproduce reduced-cell and basis-change primitives

Deliverable:

- low-level tests comparing C++ results to legacy helper behavior

### Phase 2: pattern preparation and search setup

- port `prep1`, `cksg`, `ldini`, and related helpers
- reproduce reference-pattern selection and search-mode classification exactly

Deliverable:

- tests that confirm the same search mode, volume-derived bounds, and grid parameters for published inputs

### Phase 3: indexing engine

- port reflection enumeration and pair scoring
- reproduce the legacy FOM components and ranking

Deliverable:

- per-pattern indexing tests against supplementary examples
- first closed-loop synthetic SAD tests derived from known cells and chosen reflection pairs

### Phase 4: GM candidate generation

- implement the layered search loop
- generate the same candidate counts and top-ranked cells as the legacy executable for the published cases

Deliverable:

- end-to-end unit-cell search equivalence

## Testing expansion checkpoints

The test corpus should expand in layers, not all at once.

### After Phase 3 is in place

Add more synthetic SAD tests immediately after the indexing engine exists.
Before this point, synthetic patterns only exercise geometry and preparation.
Once `indi` / `eva` are available, they become closed-loop tests for:

- known cell -> simulated pattern -> prepared pattern -> indexed reflection pair
- sign conventions and zone-axis normalization
- FOM stability under small tolerance changes

This is also the right point to add more archived SAD patterns for cells that
are already in the regression corpus, because the per-pattern indexing surface
is now stable enough to compare directly to transcript output.

The shared-kernel SAD simulator now covers the missing forward direction for
those tests. It is intentionally limited to zone-driven simulation:

- choose an exact or approximate `u, v, w` zone
- admit reflections by a residual window on the zone condition
- project them to a synthetic SAD pattern
- generate noisy synthetic observations in batch

That is enough to expand closed-loop regression without committing yet to a
separate orientation-matrix or Ewald-sphere forward model.

Candidate-level GM search evaluation and `ck`-style duplicate suppression are
now in place as a first typed search engine. The current regression strategy is
therefore split in two:

- real stored SAD-pattern searches with transcript-tight CuPc, GRGDS, and
  Lysozyme search recovery
- synthetic candidate-evaluation tests for each covered cell, built from the
  forward simulator and exact known cells

An important legacy detail is now locked into the modern search engine:
the GM search evaluates candidates in the primitive setting, matching
`such`'s unconditional `ila=1` reset before the `DC` loop. That primitive
search step is what makes the archived CuPc and GRGDS rankings come out
correctly before later basis changes and conventionalization.

### After candidate ranking is in place

Add substantially more distinct cells and whole published systems after the
`ck`-style duplicate suppression and final candidate ranking are ported. Before
that, end-to-end search tests are still missing the logic that decides which
candidate survives when several reduced or symmetry-related cells compete.

Recommended order:

1. synthetic closed-loop indexing tests
2. more real SAD patterns for CuPc, GRGDS, Lysozyme, and other already-frozen cells
3. additional whole systems and full search goldens once duplicate suppression and final ranking are implemented

### Phase 5: transformation and conventionalization tools

- port Delaunay-related transforms and basis changes used in post-processing

Deliverable:

- scriptable reproduction of the SI post-search workflows

Status:

- implemented in the modern tree through
  `modern/cpp/include/piep/postprocessing/cell_postprocessing.hpp`
- current regression coverage is transcript-tight for CuPc, GRGDS, and
  Lysozyme, including robustness checks against small artificial perturbations
- the reduced-cell comparison now tolerates small equivalent-branch flips in
  primitive reduction instead of assuming the first reduced representation is
  numerically stable enough on its own

### Phase 6: Python bindings and workflow API

- expose stable Python bindings
- ship notebook-friendly APIs and structured outputs

Deliverable:

- Python-first interface for scientific use

Status:

- implemented through `modern/cpp/python/piep`
- backed by `pybind11` bindings in `modern/cpp/python/module.cpp`
- covered by `modern/cpp/python/test_api.py` and notebook examples in
  `modern/cpp/python/notebooks`

### Phase 7: current MVP checkpoint

The modernization now has the full non-interactive path requested for the
published examples:

- archived SAD input handling
- typed search and indexing pipeline
- post-processing to conventional cells
- closed-loop simulator-backed regression
- notebook-friendly Python workflows

The deliberate implementation-layout decision for this checkpoint is to keep
the current header-first structure. A `.cpp` refactor remains recommended
later, but only after the scientific and Python-facing interfaces are stable
enough to freeze.

### Phase 7: performance work

- profile search and indexing hotspots
- cache repeated metric computations
- parallelize reflection enumeration or candidate evaluation where safe
- consider SIMD-friendly math kernels

Deliverable:

- modern implementation that is at least as fast as the legacy code on representative workloads

## Performance priorities

Optimization should focus on the real hotspots identified from the source.

- candidate generation count in broad searches
- reflection enumeration bounds
- Cartesian-product scoring in pattern indexing
- repeated trigonometric and square-root operations inside hot loops

The C++ design should therefore make it easy to:

- precompute cell metrics,
- reuse per-pattern admissibility windows,
- vectorize repeated numeric kernels,
- run candidate evaluation in parallel without shared mutable state.

## Recommended repository structure for the new code

```text
modern/
  cpp/
    include/piep/...
    src/...
    tests/...
  python/
    src/piep/...
    tests/...
  compat/
    legacy_runner/...
  data/
    golden/...
    fixtures/...
  docs/
    architecture/...
    algorithms/...
```

## Migration risks

The main technical risks are:

- accidental changes in symmetry classification thresholds
- non-equivalent reduced-cell handling
- subtle drift in floating-point behavior affecting ranking order
- underestimating how much search behavior depends on legacy defaults hidden in parameter files or COMMON state

These risks are manageable if the rewrite proceeds with fine-grained regression tests instead of a single end-to-end port.

## Immediate next step

Before writing the new implementation, build the regression harness around the supplementary-information examples and isolate the exact numerical contracts that the modern code must satisfy. That test scaffold is the prerequisite for any safe translation effort.
