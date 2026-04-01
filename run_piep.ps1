param(
    [string]$ExePath = ".\piep17z_gfortran_compat.exe",
    [string]$Workdir = "."
)

$ErrorActionPreference = "Stop"

function Get-WinLibsBin {
    $exeCommand = Get-Command $ExePath -ErrorAction SilentlyContinue
    if ($exeCommand -and $exeCommand.Source -match "WinLibs") {
        return (Split-Path -Parent $exeCommand.Source)
    }

    $gfortran = Get-Command gfortran -ErrorAction SilentlyContinue
    if ($gfortran) {
        return (Split-Path -Parent $gfortran.Source)
    }

    $wingetRoot = Join-Path $env:LOCALAPPDATA "Microsoft\WinGet\Packages"
    $candidate = Get-ChildItem -Path $wingetRoot -Directory -Filter "BrechtSanders.WinLibs.*" -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending |
        ForEach-Object { Join-Path $_.FullName "mingw64\bin" } |
        Where-Object { Test-Path -LiteralPath (Join-Path $_ "libquadmath-0.dll") } |
        Select-Object -First 1

    if ($candidate) {
        return $candidate
    }

    throw "Could not find the WinLibs runtime directory. See docs/fortran_build.md."
}

$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

if ([System.IO.Path]::IsPathRooted($ExePath)) {
    $resolvedExe = $ExePath
}
else {
    $resolvedExe = Join-Path $repoRoot $ExePath
}

if ([System.IO.Path]::IsPathRooted($Workdir)) {
    $resolvedWorkdir = $Workdir
}
else {
    $resolvedWorkdir = Join-Path (Get-Location).Path $Workdir
}

if (-not (Test-Path -LiteralPath $resolvedExe)) {
    throw "Executable not found: $resolvedExe"
}

if (-not (Test-Path -LiteralPath $resolvedWorkdir)) {
    throw "Working directory not found: $resolvedWorkdir"
}

$winLibsBin = Get-WinLibsBin
$env:PATH = "$winLibsBin;$env:PATH"

Push-Location $resolvedWorkdir
try {
    & $resolvedExe
}
finally {
    Pop-Location
}
