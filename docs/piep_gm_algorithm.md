# PIEP GM Algorithm

## Scope

This document describes the core unit-cell search implemented by PIEP's `DC` pathway and grounded in the published GM algorithm. The description is matched against the paper and the FORTRAN routines that drive search preparation, candidate generation, evaluation, and storage, especially `cksg`, `ldini`, `npl`, `rlgen`, `rlg`, `indi`, `eva`, `ck`, and `del1`.

## Problem statement

Each diffraction pattern contributes two experimentally measured reciprocal-space vectors:

- `a*` with length `r1`
- `b*` with length `r2`
- included angle `gamma`

The unknown is a third reciprocal vector `c*` such that the full reciprocal basis `(a*, b*, c*)` defines a 3D lattice compatible with multiple patterns from randomly oriented crystals.

PIEP therefore turns cell determination into a constrained search over admissible `c*` vectors for one selected reference pattern, followed by validation against the other patterns.

## Search coordinate system

For the chosen reference pattern, PIEP defines an orthogonal search basis:

- `e1 = a*`
- `e3 = a* x b*`
- `e2 = (e3 x e1) / |e1|`

The unknown reciprocal vector is expanded as:

`c* = x e1 + y e2 + z e3`

Equivalently, the search can be viewed as:

- a stack of planes indexed by `z`,
- with an in-plane search over coordinates `(x, y)`,
- where the reciprocal cell volume is proportional to `z`.

This is exactly the geometric reparameterization described in the paper.

## Symmetry-driven dimensionality reduction

The reference pattern is classified from its metric properties in `cksg`. That routine compares measured lengths and angle-derived quantities to decide whether the pattern should be treated as:

- general oblique: full 3D search
- rectangular / mirror-related: 2D constrained search
- square or hexagonal: 1D constrained search

In practice PIEP uses the mode variable `i05` to choose among:

- `0`: general search
- `1`, `2`: constrained 2D searches
- `6`, `7`: highly symmetric 1D searches

The paper states the same idea in crystallographic language: the search dimensionality can fall from 3D to 2D or 1D when the reference pattern has appropriate symmetry.

This reduction is a major reason the method is computationally practical.

## Search preparation

Before candidate generation, PIEP prepares several quantities.

### 1. Pattern admissibility windows

`prep1` converts pattern error estimates into windows for:

- admissible squared lengths,
- admissible length ratios,
- admissible angular mismatch.

These windows are later used during indexing and candidate validation.

### 2. Search ordering and reference selection

`cksg` computes a pattern-specific scalar used to order patterns and choose a default reference pattern. It also determines how many patterns are sufficiently close to the reference geometry to be used immediately in the search setup.

### 3. Volume range and layer spacing

`ldini` takes the user-provided volume limits and the reference pattern geometry, then derives:

- the initial `z` value,
- the multiplicative layer factor `dc`,
- the in-plane step width for the `(x, y)` scan within each layer.

The key source-level observation is that the layering is multiplicative, not additive: PIEP scales `z` by a constant factor between layers, so the search is approximately uniform in reciprocal volume on a logarithmic scale.

## Candidate generation

The search kernel is split between `rlgen`, `npl`, and `rlg`.

### Layer loop

`rlgen` iterates over layers. For each layer:

1. set the current `z`
2. derive the current in-plane step size from `z`
3. call `npl` to estimate how many grid points will be visited
4. call `rlg` to generate the actual `(x, y)` points

### In-plane grid

The exact set of `(x, y)` points depends on the symmetry mode.

- In the general case, PIEP scans the relevant asymmetric region of the full in-plane domain.
- In the 2D constrained cases, it walks only the symmetry-allowed walls or boundary regions.
- In the 1D high-symmetry cases, it emits only points lying on the special symmetry line.

This is why the number of tested cells differs so strongly between the published examples.

### Candidate cell construction

For each generated `(x, y, z)` triple:

1. assemble the reciprocal basis matrix
2. convert it to cell parameters with `xtodg`
3. apply a light reduction or normalization step
4. evaluate the candidate against observed patterns

## Candidate evaluation by indexing

Candidate validation is not done through a direct least-squares fit to all patterns. Instead, PIEP asks whether each pattern can be indexed consistently by the candidate cell.

### Reflection enumeration

`indi` enumerates possible Miller-index assignments for the two measured vectors of a pattern. It loops over candidate `hkl` values, computes their predicted reciprocal lengths, and retains those that satisfy the prepared tolerance windows.

This stage already applies symmetry and centering restrictions where relevant.

### Pair scoring

`eva` then considers pairs drawn from the two candidate reflection pools. For each pair it computes:

- angular mismatch between predicted and observed vectors,
- mismatch of the observed length ratio,
- mismatch of the implied camera or scale constant.

These are combined into a weighted figure of merit:

`FOM = w_angle * |angle_error| + w_ratio * |ratio_error| + w_scale * |scale_error|`

For each pattern, the best-scoring assignments are retained. Across patterns, the candidate cell inherits an aggregate score that PIEP later uses for ranking.

This matches the paper's description of the `R` value as a weighted sum of these three discrepancy terms.

## Candidate acceptance and deduplication

When a candidate survives evaluation, `ck` decides whether it should be stored in C-memory.

The routine compares the new candidate to stored ones using tolerances on:

- search coordinates `(x, y, z)`,
- axis ratios,
- cell angles.

Near-duplicate cells are merged or replaced rather than all being kept. This is important because neighboring search points often collapse to equivalent reduced cells.

Before final storage, `del1` is used so that the candidate is compared and printed in a reduced form.

## Post-processing

The raw GM output is often not yet in the most interpretable cell setting. PIEP therefore expects a follow-up workflow using:

- `DE` for Delaunay or related transformations,
- `MV` and `MA` for basis changes,
- `CW` or similar helpers for conventional settings,
- `I` for explicit indexing of selected patterns.

This is visible in all three supplementary-information examples.

## High-level pseudocode

```text
function determine_cells(patterns, search_settings):
    prepared_patterns = prepare_pattern_tolerances(patterns)
    reference = choose_reference_pattern(prepared_patterns, search_settings)
    mode = classify_reference_symmetry(reference, search_settings)
    grid_setup = initialize_search(reference, prepared_patterns, search_settings, mode)

    candidates = []
    for layer in generate_layers(grid_setup):
        z = layer.z
        xy_points = generate_xy_points(layer, mode)
        for (x, y) in xy_points:
            reciprocal_basis = build_basis(reference, x, y, z)
            cell = reciprocal_basis_to_cell(reciprocal_basis)
            cell = lightly_reduce(cell)

            score, per_pattern_matches = evaluate_cell(cell, prepared_patterns, search_settings)
            if score is acceptable:
                store_or_merge_candidate(candidates, cell, score, per_pattern_matches)

    return rank_and_reduce(candidates)
```

Evaluation itself expands to:

```text
function evaluate_cell(cell, patterns, settings):
    total_score = 0
    matches = []
    for pattern in selected_patterns(patterns, settings):
        reflections_1 = enumerate_reflections(cell, pattern.vector_1, settings)
        reflections_2 = enumerate_reflections(cell, pattern.vector_2, settings)
        best = best_pair_score(reflections_1, reflections_2, pattern, settings)
        if no acceptable best pair exists:
            apply penalty or reject cell
        total_score += best.score
        matches.append(best)
    return total_score, matches
```

## Numerically expensive parts

The main runtime cost is concentrated in four places.

### 1. Number of search points

The layered `(x, y, z)` search can grow quickly in low-symmetry cases or when the volume range is broad. The published examples already show the scale:

- CuPc: hundreds of candidates
- GRGDS: thousands
- Lysozyme 2D search: tens of thousands

### 2. Reflection enumeration

`indi` performs many repeated geometric checks over possible Miller indices. This cost scales with the search bounds on `h`, `k`, and `l`, and with the looseness of the admissibility windows.

### 3. Pairwise candidate scoring

`eva` is the dominant hotspot for indexing-heavy runs because it effectively forms a Cartesian product between the two reflection pools for each pattern. If a pattern produces `n1` and `n2` admissible reflections, the scoring work is `O(n1 * n2)`.

### 4. Repeated transcendental operations

The hot loops contain many calls to `sqrt`, `acos`-related angle recovery, trigonometric functions, and reciprocal/direct-space conversions. A modern rewrite should minimize repeated recomputation and prefer vectorized or cache-friendly kernels where possible.

## Numerically sensitive parts

The method is not just expensive; some parts are delicate.

- Classification in `cksg` is threshold-based and can change the dimensionality of the search.
- Near-boundary patterns can flip between symmetry classes if tolerances are interpreted differently.
- Small errors in measured angles can strongly affect `z` and therefore reciprocal volume.
- Reduced-cell comparison can merge candidates that are numerically close but not identical if tolerances are changed carelessly.

Because of this, the rewrite should preserve legacy arithmetic behavior first, and only then consider improvements such as stronger normalization or more robust optimization.
