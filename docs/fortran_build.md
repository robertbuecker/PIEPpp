# PIEP Fortran Build on Windows

This repo can be rebuilt successfully on Windows with `gfortran` from WinLibs.

The working setup verified in this repo is:

- toolchain: WinLibs `gfortran`
- install method: `winget install --id BrechtSanders.WinLibs.POSIX.UCRT --accept-source-agreements --accept-package-agreements --disable-interactivity`
- compiler version tested: GNU Fortran 15.2.0
- source file: `piep17Z.for`
- output file used for verification: `piep17z_gfortran_compat.exe`

## Why the build flags matter

PIEP is fixed-form legacy Fortran and does not behave correctly with a plain modern `gfortran` compile.

These flags were required for a rebuild that matches the checked-in executable on the transcript harness:

```powershell
gfortran -std=legacy -ffixed-form -ffixed-line-length-72 -fdec `
  -fallow-argument-mismatch -fno-automatic -fno-align-commons `
  -static-libgcc -static-libgfortran -o piep17z_gfortran_compat.exe piep17Z.for
```

The important compatibility points are:

- `-ffixed-line-length-72`: ignores sequence numbers in columns 73-80
- `-fdec`: accepts DEC-style legacy syntax
- `-fallow-argument-mismatch`: tolerates legacy call signatures
- `-fno-automatic`: gives static local storage, which this code relies on
- `-fno-align-commons`: avoids `COMMON` layout drift

Without the last two flags, the program compiled but did not reproduce the expected CuPc workflow.

## WinLibs installation and PATH

Install WinLibs with:

```powershell
winget install --id BrechtSanders.WinLibs.POSIX.UCRT --accept-source-agreements --accept-package-agreements --disable-interactivity
```

After install, open a new terminal. `winget` updates the user `PATH`, but existing shells do not automatically pick that up.

If you use VS Code integrated terminals or Windows Terminal tabs launched from an already-running parent process, that parent may still hold the old environment block. In practice that means:

- restarting only the shell tab may not be enough
- restarting VS Code or Windows Terminal may be required
- terminals spawned from stale parents can fail to see the WinLibs path even though the registry PATH is correct

On this machine, WinLibs was installed under:

```text
C:\Users\robert.buecker\AppData\Local\Microsoft\WinGet\Packages\BrechtSanders.WinLibs.POSIX.UCRT_Microsoft.Winget.Source_8wekyb3d8bbwe\mingw64\bin
```

If `gfortran --version` works in a new PowerShell session, the compiler side is set up correctly.

## Runtime DLL requirement

The rebuilt executable still depends on DLLs from the WinLibs `bin` directory, notably:

- `libquadmath-0.dll`
- `libwinpthread-1.dll`

That means the WinLibs `bin` directory must be on `PATH` when you run `piep17z_gfortran_compat.exe`.

The provided `run_piep.ps1` wrapper handles this automatically.

## Helper scripts

### Build

From the repo root:

```powershell
.\build.ps1
```

This script:

- finds `gfortran` on `PATH`, or falls back to the WinGet-installed WinLibs location
- builds `piep17Z.for`
- writes `piep17z_gfortran_compat.exe`

Optional verification run:

```powershell
.\build.ps1 -VerifyScenarios
```

That rebuilds PIEP and runs the three transcript scenarios against the rebuilt executable:

- `cupc`
- `lysozyme`
- `grgds`

### Run interactively

From the repo root:

```powershell
.\run_piep.ps1
```

This prepends the WinLibs runtime directory to `PATH` and starts the rebuilt executable.

If you want to run in a specific working directory:

```powershell
.\run_piep.ps1 -Workdir .\test_runs\build_verify_cupc_compat
```

## Verified result

The following succeeded with the rebuilt binary:

- build of `piep17Z.for` with `gfortran`
- transcript verification of `cupc`
- transcript verification of `lysozyme`
- transcript verification of `grgds`

This gives a reproducible Windows Fortran build path for the legacy PIEP executable using WinLibs.
