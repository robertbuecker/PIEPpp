param(
    [string]$Source = "piep17Z.for",
    [string]$Output = "piep17z_gfortran_compat.exe",
    [string]$CompilerPath = "",
    [switch]$VerifyScenarios
)

$ErrorActionPreference = "Stop"

function Get-GFortranPath {
    param([string]$RequestedPath)

    if ($RequestedPath) {
        if (-not (Test-Path -LiteralPath $RequestedPath)) {
            throw "Requested compiler does not exist: $RequestedPath"
        }
        return (Resolve-Path -LiteralPath $RequestedPath).Path
    }

    $command = Get-Command gfortran -ErrorAction SilentlyContinue
    if ($command) {
        return $command.Source
    }

    $wingetRoot = Join-Path $env:LOCALAPPDATA "Microsoft\WinGet\Packages"
    $candidate = Get-ChildItem -Path $wingetRoot -Directory -Filter "BrechtSanders.WinLibs.*" -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending |
        ForEach-Object { Join-Path $_.FullName "mingw64\bin\gfortran.exe" } |
        Where-Object { Test-Path -LiteralPath $_ } |
        Select-Object -First 1

    if ($candidate) {
        return $candidate
    }

    throw "Could not find gfortran. Install WinLibs or pass -CompilerPath. See docs/fortran_build.md."
}

$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$sourcePath = Join-Path $repoRoot $Source
$outputPath = Join-Path $repoRoot $Output

if (-not (Test-Path -LiteralPath $sourcePath)) {
    throw "Source file not found: $sourcePath"
}

$gfortran = Get-GFortranPath -RequestedPath $CompilerPath
$compilerBin = Split-Path -Parent $gfortran
$env:PATH = "$compilerBin;$env:PATH"

$flags = @(
    "-std=legacy"
    "-ffixed-form"
    "-ffixed-line-length-72"
    "-fdec"
    "-fallow-argument-mismatch"
    "-fno-automatic"
    "-fno-align-commons"
    "-static-libgcc"
    "-static-libgfortran"
    "-o"
    $outputPath
    $sourcePath
)

Write-Host "Compiler: $gfortran"
Write-Host "Building:  $sourcePath"
Write-Host "Output:    $outputPath"
& $gfortran @flags

if ($LASTEXITCODE -ne 0) {
    throw "gfortran failed with exit code $LASTEXITCODE"
}

Write-Host "Build completed."

if ($VerifyScenarios) {
    $pythonScript = @'
import os
from pathlib import Path
from tests.legacy_transcripts import piep_harness as h

repo_root = Path.cwd()
h.PIEP_EXE_PATH = repo_root / "piep17z_gfortran_compat.exe"

for name in ("cupc", "lysozyme", "grgds"):
    spec = h.get_scenario(name)
    workdir = repo_root / "test_runs" / f"build_verify_{name}_compat"
    text = h.run_protocol(spec, workdir=workdir, timeout=600)
    h.assert_expected_patterns(text, spec.expected_patterns)
    print(f"{name}: OK ({len(text)} chars)")
'@

    Write-Host "Running transcript verification with the rebuilt executable..."
    $pythonScript | python -
    if ($LASTEXITCODE -ne 0) {
        throw "Scenario verification failed."
    }
}
