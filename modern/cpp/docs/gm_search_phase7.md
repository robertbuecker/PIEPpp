# Phase 7 GM Search Engine

This note documents the first modern candidate-level search layer on top of the
already-ported grid generation and per-pattern indexing code.

## Scope

The current C++ layer now covers the non-interactive scientific core of:

- candidate evaluation across multiple patterns
- candidate storage and duplicate suppression
- final ranking of stored GM search hits

The port is centered on two new modules:

- `search/candidate_store.hpp`
- `search/gm_search.hpp`

## Legacy mapping

The implementation follows the `DC` loop structure visible around `outp`,
`rlgen`, and `ck`.

`evaluate_search_candidate(...)`

- indexes each active pattern against one candidate cell
- keeps the best `eva` match for each pattern
- averages those best-match FOM values to obtain the candidate score used by
  the store

`insert_candidate(...)`

- ports the typed `ck` logic
- keeps candidates sorted by aggregate FOM
- rejects worse near-duplicates in search space
- merges or replaces reduced-cell duplicates using the same axis-ratio and
  angle tolerances
- accumulates the legacy-style auxiliary support score

`search_unit_cells(...)`

- combines `initialize_search_grid`, `generate_search_candidates`, candidate
  evaluation, and duplicate suppression in one typed call
- evaluates GM candidates in the primitive setting, matching the legacy
  `such` routine's unconditional `ila=1` reset before the `DC` search loop

## Duplicate criteria

The duplicate store currently uses the same default tolerances as the legacy
parameter initialization:

- reduced-cell angle tolerance: `2.0` degrees
- reduced-cell axis-ratio tolerance: `0.05`
- support transform scale `fkk`: `5.0`

The search-space proximity gate still uses the per-layer `dx`, `dy`, `dz`
values scaled by `1.5`, matching the `ck` call site in the original `DC`
search loop.

## Regression coverage

The new tests cover three different levels:

- low-level candidate-store replacement and support accumulation
- real archived SAD-pattern searches for CuPc, GRGDS, and Lysozyme with
  transcript-tight top-cell recovery
- synthetic candidate-evaluation checks for CuPc, GRGDS, and Lysozyme built
  from simulator-generated zone patterns and exact reflection pairs

The important point is that synthetic tests are now no longer limited to
single-pattern indexing. They cover the multi-pattern candidate-evaluation
surface directly, while archived real-data searches remain the primary oracle
for transcript-tight full-search behavior.

Small exact synthetic pattern sets were also tried as full-search oracles, but
they can still leave the GM grid underconstrained. Those attempts were kept out
of the regression suite until the simulator can generate denser search-ready
ensembles.
