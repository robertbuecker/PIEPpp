# PIEP++

Modernization and test harness for **PIEP**, a program for unit-cell
determination from selected-area electron diffraction (SAD) patterns.

This repository contains:

- the original legacy FORTRAN sources
- a checked-in Windows legacy executable for transcript regression runs
- a modern C++ reimplementation of the non-interactive scientific core
- native and Python regression tests
- notebooks and documentation for the modernization effort

## Background

PIEP is described in:

- Bücker et al., *Reduction of electron diffraction patterns*, Acta Cryst. A,
  2025. DOI: <https://doi.org/10.1107/S2053273325000300>

The original legacy program is available from Zenodo:

- Original PIEP release: <https://doi.org/10.5281/zenodo.7859090>

Related supplementary basis-picking script referenced in the publication:

- Supplementary script deposit: <https://doi.org/10.5281/zenodo.7863651>

## What This Repository Provides

### Legacy baseline

The root of the repository contains the original FORTRAN code and a checked-in
Windows executable:

- [piep17Z.for](piep17Z.for)
- [Piep-Z17.exe](Piep-Z17.exe)

That executable is intentionally kept in version control so transcript-based
legacy regression tests can run on a Windows machine even without a FORTRAN
toolchain.

### Modern implementation

The modern work lives under [modern/cpp](modern/cpp).
It currently covers:

- crystal/cell geometry
- pattern preparation
- search-grid setup
- candidate generation
- indexing and GM search
- simulator-backed synthetic SAD generation
- post-processing to reduced and conventional cells
- notebook-friendly Python bindings and workflow API

### Regression strategy

The repository keeps two complementary validation paths:

- transcript-tight regression against archived real PIEP examples
- closed-loop synthetic tests for internal consistency and numerical robustness

The legacy transcript framework lives under
[tests/legacy_transcripts](tests/legacy_transcripts).

## Quick Start

### Run the legacy transcript harness

Requires Windows. No FORTRAN compiler is needed if you use the checked-in
legacy executable.

```powershell
pytest tests/legacy_transcripts -q
```

### Build and test the modern C++ implementation

```powershell
cmake --preset modern-gcc-debug
cmake --build --preset build-modern-gcc-debug
ctest --preset test-modern-gcc-debug --output-on-failure
```

See [docs/modern_cpp_build.md](docs/modern_cpp_build.md)
for build details and [docs/fortran_build.md](docs/fortran_build.md)
for rebuilding the legacy executable.

### Use the Python workflow API

The modern Python layer lives in
[modern/cpp/python/piep](modern/cpp/python/piep).

It exposes typed helpers for:

- SAD input construction from legacy fields, reciprocal vectors, or detector geometry
- search and conventionalization
- pattern indexing
- synthetic observation generation

Notebook examples are included in:

- [01_archived_examples.ipynb](modern/cpp/python/notebooks/01_archived_examples.ipynb)
- [02_synthetic_pipeline.ipynb](modern/cpp/python/notebooks/02_synthetic_pipeline.ipynb)

## Repository Layout

```text
docs/                      project notes, build docs, modernization plan
modern/cpp/                modern C++ implementation, tests, Python bindings
tests/legacy_transcripts/  legacy transcript harness and protocol fixtures
pub.md                     publication text snapshot used during modernization
pub_si.md                  supplementary information snapshot
```

## Current Status

The current MVP reproduces the full non-interactive scientific path needed for
the published examples:

- SAD preparation
- GM search
- duplicate suppression
- indexing
- Delaunay-style post-processing
- conventional-cell selection
- simulator-backed synthetic testing
- high-level Python access

The current roadmap and post-MVP recommendations are documented in
[docs/piep_modernization_plan.md](docs/piep_modernization_plan.md)
and
[next_steps_phase13.md](modern/cpp/docs/next_steps_phase13.md).

## License

This repository is released under the MIT License. See
[LICENSE](LICENSE).
