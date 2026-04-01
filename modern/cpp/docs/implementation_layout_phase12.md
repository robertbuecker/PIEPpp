# Phase 12: Implementation Layout Decision

## Question

The overnight scope explicitly asked whether this is the right point to move
the heavier modernization code into `.cpp` files.

## Decision

For now, the implementation stays header-first.

This is a deliberate deferral, not an omission.

## Why It Stays Header-First

At the current stage, the strongest benefits still come from keeping the core
scientific kernels adjacent to:

- the legacy mapping comments
- the typed public data structures
- the per-function regression targets

That is especially valuable while:

- post-processing is still fresh
- the Python workflow surface has just been stabilized
- the synthetic-regression strategy is still evolving

The cost of splitting now would be real:

- extra build-system churn
- more moving parts while interfaces are still settling
- noisier review when the scientific priority is still behavior fidelity

## When The Refactor Should Happen

Moving heavy implementations into `.cpp` files becomes worthwhile once the
following surfaces stop changing frequently:

- search engine settings and result structures
- simulator helper inventory
- Python workflow API
- post-processing ranking and conventional-setting heuristics

At that point the natural split is:

- keep tiny math and crystal helpers header-only
- move search, indexing, simulation, and post-processing bodies into `src/`
- turn `piep_core` into a compiled library target linked by tests and Python
  bindings

## Outcome

The modernization keeps the current header-first structure for this MVP.
That choice is now explicit and documented, rather than an accidental state of
the tree.

