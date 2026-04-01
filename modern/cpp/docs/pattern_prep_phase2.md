# Phase 2 Pattern Preparation

This note documents the second modernization slice: faithful preparation of
pattern tolerances before search or indexing.

## Scope

The current C++ layer now covers the low-level legacy behavior of:

- `resto`
- `prep1`
- `rfo`

These routines normalize one persisted `sad.dat` pattern record and derive the
admissibility windows later consumed by `indi` and `eva`.

## `sad.dat` record layout

The modern `piep::search::PatternObservation` mirrors the 18 numeric values
written by legacy `PG/PS`, in this order:

1. `ak`
2. `dak`
3. `r1`
4. `dr1`
5. `r2`
6. `dr2`
7. `r3`
8. `dr3`
9. `wi`
10. `dwi`
11. `an1`
12. `an2`
13. `an0`
14. `r0`
15. `sr0`
16. `r0m`
17. `su1`
18. `hv`

This is intentionally different from the transient `c(15)` parser workspace.
That distinction matters because regression against the published `sad.dat`
examples must target the saved record format, not the interactive input buffer.

## Derived quantities

`restore_pattern(...)` reproduces the `resto` defaults and bounds:

- default `sr0` and `su1`
- lower-limit handling for negative `r0m`
- camera-constant upper/lower squares
- rounded high-voltage kV
- electron wavelength from the high voltage
- primitive-volume estimate `vca` when Laue-zone data is present

`prepare_pattern(...)` then reproduces `prep1`:

- normalized lower/upper radius windows for the first two vectors
- cosine-space angle bounds
- `d4`, the reflection search limit used by later indexing code

`apply_temporary_errors(...)` and
`prepare_pattern_with_temporary_errors(...)` reproduce the `rfo` path that
temporarily inflates sigmas before recomputing those same windows.

## Current regression coverage

The pattern-preparation tests now cover:

- exact 18-field `sad.dat` ordering through round-trip conversion
- `resto` defaults and lower-limit handling
- synthetic `prep1` window calculations with hand-checkable numbers
- `rfo` temporary sigma flooring
- one real CuPc record from the transcript fixtures

This keeps the next porting step clear: reference-pattern classification and
search-grid setup can now consume typed prepared-pattern objects instead of
working directly against legacy COMMON-block state.
