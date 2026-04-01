# Modern C++ Build Setup

The repo now contains an initial GCC/CMake/Ninja-based scaffold for the planned C++ rewrite under `modern/cpp`.

## What is set up

- build system: CMake with Ninja
- compiler: GCC / `g++`
- source layout root: `modern/cpp`
- build presets: root `CMakePresets.json`
- native smoke executable: `piep_geometry_smoke`
- native test executable: `piep_geometry_tests`
- optional Python bindings smoke module: `piep_core` via `pybind11`

## Implemented core functionality

The initial scaffold covers the first pieces of the planned geometry layer:

- 3-vector arithmetic
- 3x3 determinant and inverse
- direct cell volume
- reciprocal-cell conversion

These are intentionally small but directly aligned with Phase 1 of `docs/piep_modernization_plan.md`.

## Libraries and tools checked

Accessible on this machine:

- `g++`
- `gcc`
- `cmake`
- `ninja`
- `python`
- `pytest`
- `pybind11`
- `numpy`

The modernization plan explicitly calls for `pybind11`; that is installed and CMake locates it through `python -m pybind11 --cmakedir`.

## Build commands

From the repo root:

```powershell
cmake --preset modern-gcc-debug
cmake --build --preset build-modern-gcc-debug
ctest --preset test-modern-gcc-debug
```

Run the native smoke executable:

```powershell
.\out\build\modern-gcc-debug\piep_geometry_smoke.exe
```

Import the Python bindings smoke module from the build tree:

```powershell
$env:PYTHONPATH = (Resolve-Path .\out\build\modern-gcc-debug).Path
python -c "import piep_core; print(piep_core.dot3([1,2,3],[4,-5,6]))"
```

## Extension path

This setup is meant to scale into the structure proposed in the modernization plan:

- `modern/cpp/include/piep/math/...`
- `modern/cpp/include/piep/crystal/...`
- later `modern/cpp/include/piep/search/...`
- later `modern/cpp/include/piep/indexing/...`

The immediate next implementation work can add more geometry and crystal kernels without changing the build tooling.
