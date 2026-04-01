# PIEP Source Synopsis

## Repository-level view

The repository combines publication material, user-facing command documentation, example data, and the legacy FORTRAN source.

Important top-level files:

- `pub.md`: main publication text
- `pub_si.md`: supplementary information with worked examples
- `scheme1.png`: workflow and memory-bank overview
- `commands-n.md`, `commands.txt`, `DC-short.md`, `conventions-t.md`: operator documentation
- `piep17.for`, `piep17Z.for`: main PIEP source
- `Ckpar-Z.for`: parameter-file checking utility
- `sub_program_list.txt`: highly useful routine inventory and terse routine descriptions

For understanding behavior, `sub_program_list.txt` is nearly as important as the source itself because it exposes the intended subprogram decomposition.

## Runtime architecture

PIEP is a classic monolithic interactive scientific application.

- A command loop parses short textual commands.
- Global state is kept in large COMMON blocks and shared arrays.
- Commands mutate memory banks, files, current settings, and current cell or pattern selections.
- Scientific kernels are invoked from inside this interactive environment.

This means the present code structure reflects user interaction history as much as numerical design.

## Main subsystems

### 1. Command interpreter and session control

The top-level program handles:

- startup and parameter-file loading,
- file opening and closing,
- reading command lines,
- dispatching to operation-specific routines,
- formatted output and prompts.

Representative routines:

- `opn`
- `clos`
- `les`
- `edit`

These are not scientifically central, but they explain why the code is tightly coupled.

### 2. Memory and file transfers

PIEP uses separate logical workspaces for pattern data, stored cells, and search results. Routines move data between memory and file-backed records.

Representative routines:

- `atoh`, `htoa`
- `ltoh`, `htol`
- `htof`
- `dlgk`
- `pos`

In modern terms, these routines are persistence and workspace adapters.

### 3. Pattern preparation

Before a cell search can run, patterns are normalized into the internal representation and equipped with tolerance-derived admissibility bounds.

Representative routines:

- `resto`
- `prep1`
- `rfo`

`prep1` is especially important because it converts the measurement uncertainty model into the numerical windows later used during indexing.

### 4. Search initialization and search-space control

This is the front end of the GM algorithm.

Representative routines:

- `cksg`
- `ldini`
- `vlim`
- `npl`

Responsibilities:

- classify the reference pattern,
- order candidate patterns,
- choose or validate the reference pattern,
- derive search mode and symmetry restrictions,
- set reciprocal-volume limits and the layer schedule,
- estimate search-point counts.

### 5. Candidate generation

This is the geometric heart of the search.

Representative routines:

- `rlgen`
- `rlg`
- `xtodg`

Responsibilities:

- generate `(x, y, z)` search coordinates,
- convert the orthogonal search basis back to reciprocal-basis and cell parameters,
- hand candidate cells off for evaluation.

### 6. Indexing and candidate scoring

This is the dominant scientific validation layer.

Representative routines:

- `indi`
- `eva`
- `outp`
- `ckout`
- `ck3`

Responsibilities:

- enumerate reflections compatible with each measured vector,
- form reflection-pair assignments,
- compute the pattern-level figure of merit,
- retain, sort, and print the best indexing results.

### 7. Candidate storage and reduction

Representative routines:

- `ck`
- `del1`
- `orden`

Responsibilities:

- compare new search hits to existing C-memory entries,
- suppress near-duplicates,
- prepare candidates in reduced form before display or later use.

### 8. Cell transformation and conventionalization

Representative routines:

- `del`
- `delc`
- `ca`
- `mvvm`

These routines support operations that are visible in the SI workflows after the main `DC` search, including Delaunay-related transformations, basis changes, and direct/reciprocal conversions.

### 9. Geometry and linear algebra kernel

Representative routines:

- `orth`, `orth1`
- `tr`, `trd`
- `m3inv`, `det`
- `mm`, `mv`, `vm`
- `vv`, `vs`
- `rr33`
- `arco`
- `uni`

These are the routines most suitable for direct translation into a modern C++ math layer.

## Compact routine map

The following routines are the most important ones to preserve or emulate during the rewrite.

| Routine | Role |
| --- | --- |
| `prep1` | Derives pattern-specific admissibility windows from experimental tolerances. |
| `cksg` | Classifies the reference pattern, orders patterns, chooses search mode, and selects the search anchor. |
| `ldini` | Initializes the GM search geometry, layer schedule, and effective search limits. |
| `npl` | Estimates or counts the number of in-plane grid points for a search layer. |
| `rlgen` | Drives the layer-by-layer candidate-cell generation loop. |
| `rlg` | Generates the actual `(x, y)` search points for one layer according to symmetry mode. |
| `xtodg` | Converts a reciprocal-basis description back into cell parameters. |
| `indi` | Enumerates candidate reflections compatible with the measured pattern vectors. |
| `eva` | Scores reflection-pair assignments and computes the indexing figure of merit. |
| `ck` | Inserts or merges accepted `DC` candidates into C-memory. |
| `del1` | Prepares reduced-form cell output before storage or comparison. |
| `orden` | Orders or normalizes cell-parameter representations for later comparison. |
| `del` | Performs Delaunay-related transformations on candidate cells. |
| `delc` | Supports conventionalization or Delaunay-adjacent post-processing. |
| `ca` | Performs reciprocal/direct cell calculations used across several commands. |
| `mvvm` | Supports basis-change style transformations invoked by `MV` and related commands. |
| `orth`, `orth1` | Build orthogonalized metric representations from cell parameters. |
| `tr`, `trd` | Perform transformation operations between reciprocal and direct settings. |
| `m3inv`, `det` | Low-level matrix inversion and determinant helpers. |
| `vv`, `vs`, `mm`, `mv`, `vm` | Vector and matrix arithmetic primitives used throughout the code. |

## Source structure by importance to the rewrite

Not all source components are equally important.

### Must preserve first

- geometry conversions and matrix helpers
- tolerance preparation
- symmetry classification of reference patterns
- GM search initialization
- layered candidate generation
- indexing-based candidate scoring
- cell reduction and duplicate suppression

### Preserve for compatibility, but later

- interactive command parser
- file naming conventions
- print formatting
- memory-bank bookkeeping as currently exposed to the user

### Potentially omit from the first clean-room API

- command abbreviations
- interactive editing commands
- legacy record-style I/O patterns

## Likely call flow for cell determination

At a high level the `DC` workflow appears to be:

1. load patterns into A-memory
2. prepare tolerances and pattern descriptors
3. choose search settings with `PC`
4. call `cksg` to classify and order patterns
5. call `ldini` to initialize the search grid
6. call `rlgen` and `rlg` to generate candidate cells
7. for each candidate, call indexing routines to compute fit quality
8. reduce and store accepted candidates through `ck`
9. review and post-process the resulting C-memory list

This flow is confirmed jointly by the source, `DC-short.md`, and the worked protocols in `pub_si.md`.

## Architectural issues that block maintainability

The legacy code has several structural problems that the rewrite should explicitly eliminate.

- Heavy reliance on COMMON blocks makes data ownership unclear.
- UI logic and scientific kernels are interleaved.
- Routine names are terse and historically meaningful rather than self-describing.
- Numerical policies are encoded as scattered thresholds instead of explicit configuration objects.
- Data transfer between memory banks and files obscures the actual domain model.

These are design problems, not scientific problems. The rewrite should preserve behavior while replacing this architecture entirely.

## Practical reading order for future work

For anyone continuing the rewrite analysis, the most effective reading order is:

1. `pub.md`
2. `pub_si.md`
3. `scheme1.png`
4. `DC-short.md`
5. `sub_program_list.txt`
6. search-related routines in `piep17Z.for`
7. indexing-related routines in `piep17Z.for`
8. transformation and geometry helpers

That order builds domain understanding first, then maps concepts onto the actual implementation.
