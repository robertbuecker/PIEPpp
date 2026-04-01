# Phase 13: Next Steps After The MVP

## What Is Now Complete

The modern tree now covers the full non-interactive scientific path needed for
the published examples:

- SAD observation preparation
- search-grid initialization
- candidate generation
- per-pattern indexing
- GM search and duplicate suppression
- Delaunay-style post-processing
- conventional-setting selection
- simulator-backed closed-loop regression
- notebook-friendly Python access

That is the minimum viable product requested for the modernization.

## Recommended Next Steps

### 1. Expand the scientific corpus

The next highest-value scientific work is more data:

- more archived SAD patterns for CuPc, GRGDS, and Lysozyme
- additional unrelated cells from the corpus
- more difficult monoclinic and pseudo-higher-symmetry examples

This will do more to harden the search engine than cosmetic refactoring.

### 2. Strengthen forward models

The shared-kernel simulator is already useful for regression and notebook work,
but there is still room to grow:

- more explicit synthetic helpers around archived-match generation
- broader zone ensembles and sampling policies
- eventually, if needed, an external forward model for stronger independence

The orientation-matrix / Ewald-style selection path is still best treated as a
future extension or as a task for an external crystallographic package.

### 3. Refine post-processing heuristics

The current conventionalizer is already scientifically useful, but future work
should still examine:

- additional centered and pseudo-centered edge cases
- more ambiguous monoclinic branches
- transcript checks beyond the current SI systems

### 4. Refactor structure once interfaces settle

The heavy code should move into `.cpp` files later, but only after the current
API and heuristic surfaces are stable enough to freeze.

### 5. Performance work

After the scientific surface is broadened, profile and optimize:

- reflection enumeration
- pattern indexing hot loops
- GM candidate evaluation
- repeated metric and trigonometric calculations

## Practical Immediate Recommendation

The best next overnight-style task is not structural refactoring. It is
scientific expansion:

1. add more archived systems
2. add more archived patterns per current system
3. keep tightening synthetic stress tests around the difficult cases

That sequence will tell us where the real remaining weaknesses are before we
freeze the implementation layout.
