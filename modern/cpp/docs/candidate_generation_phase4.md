# Phase 4 Candidate Generation

This note documents the next modernization slice after search setup:
typed candidate generation for PIEP's `DC` search stream.

## Scope

The current C++ layer now covers the default, non-interactive behavior of:

- `rlg`
- `rlgen`

The modern port does not evaluate or rank candidates yet. It stops at the point
where PIEP has generated `(x, y, z)` search coordinates and converted each
reciprocal basis into a candidate cell.

## New types

`piep::search::PlaneScanRequest`

- one in-plane layer definition
- half widths, layer height, increment, symmetry mode, and requested wall depth

`piep::search::PlaneScanResult`

- exact `rlg` point order for one layer
- includes the derived `nx`, `ny`, `dx`, `dy`, and effective wall-cycle count

`piep::search::SearchLayer`

- one multiplicative `z` layer from `rlgen`
- stores layer height, `p`, direct-cell volume, and point count

`piep::search::SearchCandidate`

- one generated search point after `xtodg`
- keeps both the raw reciprocal metric and the post-`minni` metric
- records whether the one-pass `minni` fallback was used

`piep::search::CandidateGenerationResult`

- the full typed candidate stream for a prepared `SearchGridSetup`
- optional truncation for debug previews without losing the total count

## Legacy mappings

The implementation keeps the same search-mode split as the FORTRAN code:

- `0`: general
- `1`: centered wall scan
- `2`: rectangular wall scan
- `6`: square special points
- `7`: hexagonal special points

The post-processing step also follows `rlgen` exactly:

1. build the reciprocal basis for `(x, y, z)`
2. call `xtodg`
3. skip reduction when `|cos(alpha*)|` and `|cos(beta*)|` are both below
   `flim`
4. otherwise run one `minni` pass and recompute the metric

For the default `DC` path, the modern debug surface uses the same effective
`flim = 0.5` threshold.

## Current regression coverage

The candidate-generation tests validate:

- low-level point order for general, centered, rectangular, square, and hex scans
- CuPc candidate generation with `786` search points
- GRGDS candidate generation with `8642` search points
- Lysozyme square candidate generation with `102` search points
- Lysozyme rectangular candidate generation with `29492` search points
- synthetic triggering of the one-pass `minni` fallback

This gives the next modernization slice a stable, typed input stream for the
indexing routines (`indi` / `eva`) without recreating the legacy CLI.
