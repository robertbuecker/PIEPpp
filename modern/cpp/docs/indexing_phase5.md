# Phase 5 Indexing

This note documents the next modernization slice after candidate generation:
typed single-pattern indexing for PIEP's `indi` / `eva` path.

## Scope

The current C++ layer now covers the default, non-interactive behavior of:

- `indi`
- `eva`

The port stops at typed match generation and ranking. It does not yet recreate
the printed `outp` report, duplicate suppression, or candidate-level search
aggregation.

## New types

`piep::indexing::ReflectionCandidate`

- one admissible reflection from the `indi` loops
- stores Miller indices, orthogonalized reciprocal vector, and squared length

`piep::indexing::ReflectionEnumerationResult`

- the two reflection pools consumed by `eva`
- reports overflow when the legacy per-pool limit is exceeded

`piep::indexing::IndexingMatch`

- one scored reflection pair
- keeps the predicted radii, angle, camera constant, Laue-zone quantity, and
  the three FOM components used by PIEP

`piep::indexing::PatternIndexingResult`

- the typed result for one prepared pattern against one candidate cell
- carries the crystal-system classification, centering, enumeration pools, and
  sorted matches

## Legacy mappings

The implementation follows the original split closely:

1. `enumerate_reflections(...)` ports the `indi` loops and their centering and
   asymmetric-unit restrictions.
2. `index_prepared_pattern(...)` ports the `eva` Cartesian-product scoring and
   weighted FOM.
3. sign normalization uses the same `chgs` convention that `outp` applies
   before printing transcript-visible Miller indices.

The default indexing weights remain the legacy values:

- angle term: `0.6`
- radius-ratio term: `0.8`
- camera-constant term: `0.3`

## Current regression coverage

The indexing tests now validate:

- low-level centering extinctions and asymmetric-unit restrictions
- zone-axis multiplicity handling
- a synthetic closed-loop SAD pattern generated from a known cell and known
  reflections
- transcript-backed top matches for CuPc, GRGDS, and Lysozyme

The synthetic case is important: it is the first test that closes the loop from
known cell -> simulated SAD observation -> preparation -> reflection
enumeration -> pair scoring.

## Testing expansion checkpoint

This is the right point to start expanding tests with synthetic SAD patterns.
Before `indi` / `eva` existed, synthetic patterns could only validate geometry
or preparation in isolation. Now they exercise the full per-pattern indexing
path and can be used to lock down:

- exact reflection-pair recovery
- sign and zone-axis conventions
- camera-constant and angle residuals
- sensitivity to tolerance inflation

Broader real-data expansion should happen in two stages:

- now: add more synthetic patterns and more archived SAD patterns against the
  already-covered cells
- after `ck` and the final candidate-ranking loop are ported: add whole-cell
  end-to-end goldens for additional systems, because only then will the modern
  search reproduce PIEP's final duplicate handling and ranking surface
