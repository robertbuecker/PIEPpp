# Phase 6 SAD Simulation

This note documents the first forward-simulation slice added on top of the
modern geometry and indexing kernels: a shared-kernel SAD simulator driven by a
zone definition.

## Scope

The simulator is intentionally narrow for the first pass.

It currently supports:

- direct-cell input plus centering
- reflection selection by a `u, v, w` zone direction
- exact zones through `target = 0` and `tolerance = 0`
- approximate near-zones through fractional `u, v, w` values or a non-zero
  residual window on the zone condition
- detector-plane projection with a supplied camera constant
- deterministic default basis-pair selection
- noisy synthetic `PatternObservation` generation for regression ensembles

It does not yet support orientation-matrix driven Ewald constructions. That was
investigated, but it would pull in a substantially different forward model and
is better deferred until there is a concrete need for either a second internal
oracle or an external crystallographic package.

## New types

`piep::simulation::ZoneDirection`

- stores the `u, v, w` direction plus a target and tolerance for the zone
  condition

`piep::simulation::SpotSimulationSettings`

- controls centering, camera constant, radius window, Friedel handling, and
  reflection truncation

`piep::simulation::SimulatedSpot`

- stores the Miller index, reciprocal vector, detector coordinates, radius, and
  evaluated zone residual for one simulated reflection

`piep::simulation::SimulatedPattern`

- the full simulated spot list for one zone definition

`piep::simulation::BasisPairSelection`

- the deterministic default pair used to derive a synthetic SAD observation

`piep::simulation::ObservationEnsembleResult`

- the batch result for multiple zones and multiple noisy realizations

## Legacy and modernization role

This module is not meant to reproduce a legacy PIEP CLI command. Its purpose is
to exercise the modernized internals in a closed loop:

- known cell
- chosen or enumerated zone
- simulated SAD spot pattern
- selected basis pair
- synthetic `PatternObservation`
- indexing through the existing modern path

Because it reuses the same geometry kernel as the rest of the modernization, it
is not a fully independent oracle. That is acceptable for now because the main
goal is internal consistency and efficient regression expansion.

## Regression use

The current regression coverage locks down:

- exact cubic-zone spot geometry
- tolerance-based admission of near-zone reflections
- deterministic basis-pair selection
- batched noisy ensemble generation for multiple zones

This is the intended base for the next wave of synthetic tests:

- more zones for already-covered cells
- controlled perturbation studies over position, angle, and camera errors
- larger regression ensembles before final duplicate suppression is ported
