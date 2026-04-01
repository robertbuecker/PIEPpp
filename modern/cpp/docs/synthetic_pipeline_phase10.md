# Phase 10: Synthetic Pipeline Expansion

## Scope

This phase expands closed-loop testing with simulator-generated SAD patterns,
including noisy inputs that stress search, reduction, and conventionalization.

The goals were:

- reuse the shared-kernel simulator to generate realistic synthetic patterns
- exercise the whole pipeline with numerical noise, especially in angular data
- keep real archived SAD patterns as the transcript-tight oracle

## Native Coverage

Core regression target:

- `tests/test_pipeline_synthetic.cpp`

The current suite is intentionally split by how constrained each system is.

### Candidate-level synthetic checks

For CuPc and GRGDS, synthetic patterns now check candidate self-consistency
against the known cell. These cases are strong enough to validate the
forward-model and indexing path, but small synthetic sets can still leave the
full GM search underconstrained.

### Full noisy end-to-end check

For Lysozyme, the modern suite now runs a noisy synthetic search all the way to
post-processing and conventionalization. That is the strongest closed-loop
search regression currently in the tree.

## Python Coverage

The notebook-facing Python suite mirrors that strategy in
`python/test_api.py`:

- archived transcript-tight search and conventionalization for CuPc, GRGDS,
  and Lysozyme
- simulator-backed candidate evaluation for synthetic CuPc and GRGDS patterns
- a noisy archived-match synthetic Lysozyme search that must yield a close
  tetragonal conventional candidate

The Python end-to-end Lysozyme test uses explicit reflection pairs derived from
the archived source patterns instead of relying only on the simulator's default
basis-pair choice. That keeps the test strong while remaining fully synthetic.

## Limitations

Synthetic search goldens are still weaker than real archived-pattern goldens.
That is expected:

- they reuse the same geometric kernel as the search code
- sparse synthetic pattern sets can be scientifically valid but still too weak
  to force a unique GM ranking

For that reason:

- archived real-data searches remain the primary transcript oracle
- synthetic tests are used to stress internal consistency and numerical
  robustness

## Outcome

The modernization now has two complementary regression pillars:

- transcript-tight archived-pattern searches
- simulator-driven closed-loop consistency tests with controlled numerical noise

That is enough to keep extending the scientific core without losing sight of
either legacy behavior or internal numerical stability.

