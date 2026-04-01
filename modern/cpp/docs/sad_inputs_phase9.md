# Phase 9: SAD Input Adapters

## Scope

This phase broadens the way modern PIEP accepts SAD observations. The legacy
program persists one 18-value `sad.dat` record, but real scientific workflows
often start from other descriptions:

- direct reciprocal-plane vectors in inverse Angstrom
- detector geometry given by spot positions, detector distance, wavelength, and
  pixel size

The modern tree now supports those descriptions without forcing callers to
manually derive the legacy fields first.

## Implementation

Core implementation:

- `include/piep/search/pattern_prep.hpp`

New typed adapters:

- `ReciprocalVectorPairObservationInput`
- `DetectorGeometryObservationInput`
- `observation_from_reciprocal_vectors(...)`
- `observation_from_detector_geometry(...)`

The adapters still produce the same typed `PatternObservation` object consumed
by `restore_pattern(...)` and `prepare_pattern(...)`. That keeps the downstream
search code unchanged while making the front end much more notebook-friendly.

### Wavelength handling

One small modern-only addition was needed here: `PatternObservation` now carries
an optional `wavelength_override_angstrom`. This is not serialized into the
legacy 18-field record, but it allows direct detector-geometry or
reciprocal-vector inputs to preserve an explicitly supplied wavelength even when
the observation also carries a high voltage.

`restore_pattern(...)` now prefers that explicit wavelength when present.

## Regression Coverage

Native regression remains in:

- `tests/test_pattern_prep.cpp`

Added checks:

- reciprocal-vector input reproduces the expected radii and inter-vector angle
- detector-geometry input reproduces the expected camera constant and spot
  metric
- explicit wavelength overrides survive the restoration path instead of being
  replaced by the voltage-derived default

## Outcome

The search and indexing pipeline no longer depends on precomputed `sad.dat`
records as its only entry point. Modern callers can now define SAD data from
the quantities they naturally have in hand and still feed exactly the same
validated downstream preparation code.

