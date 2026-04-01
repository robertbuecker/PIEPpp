# Phase 8: Post-Processing

## Scope

This phase adds the first complete modern post-processing layer on top of the
typed GM search.

Covered pieces:

- explicit Delaunay-style primitive reduction wrapper around the existing
  `del1`-equivalent geometry code
- conventional-setting enumeration from the reduced primitive cell
- robust reduced-cell comparison that tolerates small branch flips between
  equivalent primitive settings
- transcript-tight post-search checks for CuPc, GRGDS, and Lysozyme

The goal here is not to reproduce the legacy `DE` implementation line by line.
Instead, the modern code starts from the already-validated reduced primitive
cell and enumerates small unimodular basis changes together with the known
centering transforms. For the current SI corpus, that is enough to recover the
same conventional cells that matter scientifically.

## Implementation

Core implementation:

- `include/piep/postprocessing/cell_postprocessing.hpp`

Key API pieces:

- `delaunay_reduce_cell(...)`
- `conventionalize_cell(...)`
- `compare_reduced_cells(...)`

### Conventional-cell search strategy

The modern conventionalizer works in three steps:

1. convert the input cell to primitive if needed
2. reduce that primitive cell with the faithful `del1`-style reduction already
   present in `cell.hpp`
3. enumerate conventional settings by applying:
   - a bounded set of unimodular integer basis changes with entries in
     `{-1, 0, 1}`
   - the inverse of the standard primitive-basis transforms for
     `P/A/B/C/I/F/R`

Each candidate is then:

- symmetry-classified with a strict modern tolerance set
- also classified with a looser legacy-style tolerance set
- deduplicated by direct-cell closeness
- ranked for automatic selection by:
  - crystal system
  - transform complexity
  - symmetry error
  - a small monoclinic tie-break that keeps the CuPc and GRGDS settings stable

### Reduced-cell comparison

The first comparison attempt is the usual reduced-cell ratio/angle check.
That is sufficient for stable cases, but not for all perturbed monoclinic
cells. GRGDS in particular can jump to a nearby equivalent reduced branch
under tiny perturbations.

To make the comparison usable for robustness tests, the implementation now
falls back to a small primitive-basis search:

- take the reduced primitive cell of the right-hand lattice
- apply the same bounded unimodular basis family
- accept equivalence if any of those primitive variants matches the left-hand
  reduced cell within the requested tolerances

That keeps the comparison faithful to lattice equivalence instead of treating
the first reduced representation as uniquely stable.

## Regression Coverage

Native regression target:

- `tests/test_postprocessing.cpp`

Checks included:

- Delaunay wrapper agrees with the already-ported reduced primitive cell
- CuPc transcript `A` setting is present
- CuPc preferred `C` setting matches the stored modern cell
- GRGDS transcript `A` setting is present
- GRGDS preferred `C` setting matches the stored modern cell
- Lysozyme tetragonal `P` setting is present and selected
- reduced-cell comparison recognizes equivalent CuPc conventional cells
- small artificial perturbations still conventionalize to the same lattice
- full search-to-conventional pipeline matches the transcript cells for all
  three archived systems

## Outcome

The modern tree now has the minimum viable post-processing path needed for the
scientific workflow:

- SAD patterns -> GM search -> reduced primitive cell -> conventional cell

That closes the biggest remaining gap between the typed search engine and the
post-search workflows shown in the supplementary information.
