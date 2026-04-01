# Phase 3 Search Setup

This note documents the next modernization slice after pattern preparation:
default reference selection and layered search-grid setup for `PC`/`DC`.

## Scope

The current C++ layer now covers the default, non-interactive behavior of:

- `cksg`
- `ldini`
- `npl`

The prompt-level override flow is still intentionally out of scope. The modern
API exposes the default scientific decisions directly:

- classify each active pattern by 2D metric symmetry
- order patterns by the same scalar PIEP uses for `PC`
- choose the default `a*, b*`-defining pattern
- derive the reduced in-plane reference basis
- clamp the requested primitive-volume range
- derive layer spacing and count the candidate grid points

## New types

`piep::search::SearchPattern`

- one prepared pattern plus a 1-based A-memory style slot number
- optional exclusion flag corresponding to `AX`

`piep::search::ReferenceSelection`

- per-pattern symmetry classifications
- default reference slot and search mode
- remaining sequence after removing the reference slot
- close-pattern list from the `uni`-based shape comparison

`piep::search::SearchGridSetup`

- reduced reference basis used for the layered search
- chosen and suggested primitive-volume ranges
- first and last `p` values
- layer count
- first-layer and total grid-point counts

## Legacy mappings

`PatternSymmetryIndicator` mirrors `irf(5, i)`:

1. oblique
2. rectangular
3. `r1 ~= r2`
4. `r1 ~= r3`
5. `r2 ~= r3`
6. square
7. hexagonal

`SearchMode` mirrors `i05`:

- `0`: general
- `1`: centered / wall scan
- `2`: rectangular
- `6`: square
- `7`: hexagonal

## Current regression coverage

The new search-setup tests validate:

- low-level symmetry classification
- CuPc default reference choice and `786`-set layered grid
- GRGDS default reference choice and `8642`-set layered grid
- Lysozyme first square search with `102` sets
- Lysozyme second rectangular search after exclusions with `29492` sets

Those checks are tied directly to the publication transcripts, so later work on
`rlgen`, `rlg`, and indexing can build on a fixed search-setup surface.
