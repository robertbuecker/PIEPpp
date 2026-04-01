# PIEP Test Strategy

## Goal

Create a regression framework that starts by validating the legacy executable exactly as used in the supplementary information, then gradually shifts toward direct, code-driven tests for the reimplementation.

The strategy must support two distinct phases:

- transcript-faithful testing of the legacy interactive program
- API-level testing of the new C++ and Python implementation

## Why start with transcript tests

The supplementary information already gives three valuable assets:

- complete `sad.dat` inputs,
- the command-by-command interaction with PIEP,
- the expected scientific outcomes discussed in the paper.

That makes the SI a ready-made golden test corpus. Before any rewrite, we should turn those examples into repeatable automated runs.

## Phase 1: automate the legacy executable

### Harness type

Use a Python-driven pseudo-terminal harness that can emulate keystroke-style interaction with the PIEP executable.

Recommended on Windows:

- `wexpect`

Portable later option:

- `pexpect` where supported

The harness should:

- start PIEP in an isolated working directory,
- wait for prompts,
- send the exact command sequences from `pub_si.md`,
- capture stdout and generated files,
- normalize outputs for comparison.

### Per-scenario fixture layout

Each supplementary example should live in its own fixture directory containing:

- `sad.dat`
- `piep.par`
- any expected auxiliary files such as `cell.dat`
- the scripted transcript
- normalized expected outputs

Suggested layout:

```text
tests/
  legacy_transcripts/
    fixtures/
      cupc/
      lysozyme_1d/
      lysozyme_2d/
      grgds/
    test_transcripts.py
```

Each run should execute in a temporary copy of the fixture directory so files can be written freely without cross-test contamination.

### Output normalization

Raw PIEP output is interactive and formatting-heavy. Comparison should not rely only on byte-identical terminal logs.

Normalize:

- repeated whitespace
- banner and prompt noise
- line wrapping differences
- insignificant float-format variations

Extract structured checkpoints such as:

- number of generated candidate cells
- top-ranked `DC` cell parameters
- top `R` value
- selected transformation outputs after `DE` or `MV`
- top indexing assignment for chosen patterns

## Minimum golden scenarios

### 1. CuPc example

Use the SI transcript to check at least:

- `DC` candidate count and layer count
- best reduced cell near `a=3.82`, `b=15.28`, `c=15.60`, `alpha=111.7`, `beta=93.1`, `gamma=92.9`
- post-transformation conventionalized cell near `a=17.33`, `b=25.57`, `c=3.82`, `beta=95.35`
- indexing outputs for the patterns highlighted in the SI

### 2. Lysozyme example

Split this into two tests.

- first test: high-symmetry 1D search producing the tetragonal solution
- second test: broader 2D search after excluding problematic patterns

Check at least:

- candidate counts
- top `R` values
- tetragonal transformed cell near `79.06, 79.06, 38.22`
- indexing checkpoints for the cited patterns

### 3. GRGDS example

Check at least:

- candidate count and layer count
- top reduced cell near `a=4.44`, `b=14.51`, `c=19.47`, `alpha=105.3`, `beta=90.0`, `gamma=98.8`
- post-transformation cell near `a=28.68`, `b=4.44`, `c=19.47`, `beta=105.47`
- indexing result for the pattern discussed in the SI

## Assertions to use first

Early tests should be semantic, not overly brittle.

Good first assertions:

- top candidate exists
- cell parameters match within explicit tolerances
- candidate ordering includes the known solution at rank 1
- selected patterns index to the same top zone axis and reflection assignments
- search-mode choice matches the expected dimensionality

Bad first assertions:

- exact byte-for-byte terminal logs
- exact spacing or line-wrapping
- every intermediate prompt character

## Phase 2: extract machine-readable goldens

Once the transcript harness is stable, promote the important outcomes into structured JSON goldens.

Example schema:

```json
{
  "scenario": "cupc",
  "search_mode": "2d",
  "dc_top_result": {
    "R": 0.85,
    "cell": [3.82, 15.28, 15.60, 111.7, 93.1, 92.9]
  },
  "indexing_checks": [
    {"pattern": 19, "zone": [-3, 1, -4]},
    {"pattern": 29, "zone": [-1, 0, -4]}
  ]
}
```

These JSON files become the durable contract for the rewrite.

## Phase 3: direct tests on translated subsystems

As the new implementation appears, stop depending on transcript replay for every assertion.

### Geometry tests

Validate:

- cell to reciprocal-basis conversion
- reciprocal-basis to cell conversion
- reduced-cell transforms
- basis changes used in the SI workflows

### Search-setup tests

Validate:

- `prep1`-equivalent tolerance windows
- reference-pattern selection
- symmetry classification
- derived layer schedule and in-plane step parameters

### Indexing tests

Validate:

- reflection enumeration for known cells and patterns
- best reflection-pair assignment
- FOM component values
- zone-axis results for the SI patterns

### Search-engine tests

Validate:

- number of tested search points for published scenarios
- top-ranked candidate cells
- duplicate suppression behavior

## Phase 4: hybrid comparison tests

During the middle of the rewrite, run the legacy executable and the new code side by side on the same scenario and compare structured results.

This is the most effective way to catch:

- threshold drift
- ranking changes
- reduction mismatches
- accidental symmetry-mode changes

Suggested layout:

```text
tests/
  compare_legacy_modern/
    test_cupc.py
    test_lysozyme.py
    test_grgds.py
```

## Phase 5: modern-native tests only

Once the new implementation is trusted, transcript tests can move to a smaller compatibility suite and the main test load can shift to direct unit and integration tests on the modern API.

At that point the test pyramid should look like:

- many unit tests for geometry, indexing, and search setup
- moderate integration tests for full GM search
- a small number of legacy transcript regression tests

## Recommended tools

### Python test runner

- `pytest`

### Transcript driver

- `wexpect` on Windows

### Golden-data handling

- JSON for structured expectations
- plain text snapshots only for human inspection

### Numeric comparison

- explicit absolute and relative tolerances
- helper assertions for cell equivalence and permutation-aware comparison where needed

## Important implementation details

### Isolate working directories

PIEP writes files as part of its normal workflow. Every transcript test should run in its own temporary working directory populated from fixture files.

### Capture both terminal output and files

Some scientifically important results may appear in logs, while others may be written to output files selected through the parameter file. The harness must inspect both.

### Record environment metadata

Store:

- executable version
- parameter-file contents
- locale-sensitive formatting assumptions
- floating-point tolerance policy used by the tests

That metadata will matter if results differ subtly across compilers or platforms.

## Risks and mitigations

### Risk: prompt synchronization failures

Mitigation:

- synchronize on stable prompt fragments
- support timeouts and transcript logging for debugging

### Risk: formatted-output brittleness

Mitigation:

- compare structured extracted values instead of full logs

### Risk: hidden defaults in `piep.par`

Mitigation:

- check fixture parameter files into version control
- parse and document all fields that affect search or output

### Risk: false failures due to float-format drift

Mitigation:

- compare numerically with explicit tolerances
- preserve full-precision extracted values where possible

## Immediate next actions

1. Build fixture directories for the three SI examples.
2. Write a `pytest` transcript harness using `wexpect`.
3. Encode the main scientific checkpoints from the SI as structured assertions.
4. Add a second layer of tests that compares extracted JSON results rather than raw logs.
5. Use those tests as the acceptance gate for each translated C++ subsystem.
