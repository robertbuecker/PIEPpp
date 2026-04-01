# Phase 1 Geometry Kernel

This folder documents the first clean-room translation slice for the PIEP rewrite.

## Scope

The current C++ layer deliberately covers only the low-level routines that the rest of PIEP depends on:

- `dire`: direct/reciprocal metric conversion
- `orth`, `orth1`: legacy triangular orthogonalization coefficients
- `tr`, `trd`: Cartesian transforms for reciprocal-space and direct-space coordinates
- `xtodg`: Cartesian basis to metric conversion
- `uni`: 2D zone-basis normalization
- `del1`, `orden`: reduced-cell preparation used before ranking/output
- `MV/MA`-style basis changes for direct cells

## Data conventions

PIEP uses two closely related cell representations:

1. Human-facing cell parameters:
   - `a`, `b`, `c`, `alpha`, `beta`, `gamma`
   - angles in degrees
2. Internal metric form:
   - `a`, `b`, `c`, `cos(alpha)`, `cos(beta)`, `cos(gamma)`

The modern headers mirror that split:

- `piep::crystal::CellParameters`
- `piep::crystal::CellMetric`

That distinction is important because the FORTRAN code mostly works on cosine angles, not degree angles.

## Matrix conventions

`piep::math::Matrix3` stores values in row-major order.

The legacy PIEP matrix input convention is different:

- `MV/MA` reads matrices column-by-column
- the Python debug binding therefore accepts basis-change matrices as a flat 9-value array in legacy column-major order

This avoids silently changing semantics when reproducing publication workflows.

## Current regression coverage

The geometry tests now validate three categories of behavior:

1. Exact helper parity:
   - reciprocal conversion
   - orthogonalization coefficients
   - `tr`/`trd`/`xtodg` consistency
2. Publication checkpoints:
   - CuPc A-centered to C-centered basis change
   - GRGDS A-centered to C-centered basis change
   - CuPc reduced-cell recovery
   - GRGDS reduced-cell recovery
3. Pattern-basis normalization:
   - unchanged, swapped, and angle-flipped `uni` cases

## Why this slice comes first

Every later subsystem depends on these operations:

- pattern preparation needs `uni`
- indexing needs reciprocal/direct conversions and transforms
- search output comparison needs `del1` and basis-change support

Porting them first gives us stable building blocks and testable intermediate states before translating search logic.
