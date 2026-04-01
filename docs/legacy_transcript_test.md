# Legacy Transcript Regression Test

## Scope

This note documents the current regression test for the legacy PIEP executable, and records the practical issues that came up while turning the supplementary-information transcripts into automated tests.

The relevant implementation is:

- [piep_harness.py](c:/Users/robert.buecker/codes/PIEP/tests/legacy_transcripts/piep_harness.py)
- [test_pub_si_protocols.py](c:/Users/robert.buecker/codes/PIEP/tests/legacy_transcripts/test_pub_si_protocols.py)

The new explicit protocol fixtures derived from this work live in:

- `tests/legacy_transcripts/protocols/cupc.json`
- `tests/legacy_transcripts/protocols/lysozyme.json`
- `tests/legacy_transcripts/protocols/grgds.json`

## What The Current Test Does

The legacy test runs `Piep-Z17.exe` against the three scenarios from `pub_si.md`:

- CuPcCl16
- lysozyme
- GRGDS

For each scenario the harness:

- extracts the `sad.dat` block from `pub_si.md`
- writes a temporary `sad.dat`, `cell.dat`, and rewritten `piep.par`
- builds an input script from the publication transcript plus compatibility fixes
- runs PIEP in an isolated temporary working directory
- captures `session.log`
- checks scientifically relevant transcript patterns, rather than relying on byte-identical terminal logs

There are two test layers:

- a prefix test that only covers pattern ingestion up to `pc`
- a full end-to-end transcript test

## Why The Harness Uses Redirected Stdin

The original plan was to drive PIEP with a pseudo-terminal package such as `wexpect`. In practice, `wexpect.spawn()` was unreliable here and hung during pipe setup before the child session became usable. Because of that, the working harness uses `subprocess.run(..., input=...)` and feeds PIEP a complete redirected stdin script.

This approach is simpler and stable enough for regression testing, but it exposes several legacy stdin quirks that are not visible in the publication transcript.

## Important Edge Cases

### 1. Bare Return Is Not Always Representable As A Truly Empty Record

Semantically, several prompts want a plain `Return` to accept a default. Under redirected stdin, PIEP did not always behave well when the script began with truly empty records. The current harness therefore writes a single-space line for a default confirmation when talking to the legacy executable.

This is a transport workaround, not a protocol truth.

The new explicit protocol fixtures do not store a literal single space. They use the semantic token `<RETURN>`, and the test backend can map that token to the concrete representation it needs.

### 2. The SI Transcript Omits Some Default Confirmations

The supplementary-information transcript is a human-readable interaction log, not a machine-ready script. Several prompts are followed immediately by more PIEP output, which means an implicit input happened even though no separate input line is shown.

Examples:

- startup defaults
- `dc` -> `ok?`
- `ma` -> `apply matrix 1?`
- `ma` -> `replace current cell parameters?`
- some `pg` transitions where the next pattern appears immediately

These inputs had to be made explicit for automation.

### 3. Not Every Prompt Ends With `?`

The harness could not rely on `?` alone to detect input boundaries. The important counterexample is:

- `factor for default increment (0.025), def.:1., max:6; <0 : increment`

This line still requires input, even though it is not formatted as a conventional question line in every transcript layout.

### 4. `pg` Is Ambiguous In The SI Transcript

The SI often shows:

- `pg`
- PIEP prints `consec. # of data set? 0 or <0: next set (   N )`
- then the next pattern appears immediately in the same block

That means the operator advanced to the displayed next set, but the exact keystroke is not always written as a separate line.

For the explicit protocol files this ambiguity is removed: the displayed set number is always written explicitly into the input token list.

This is preferable to preserving the omission, because it makes the intended action unambiguous and keeps the fixture independent of backend-specific default handling.

### 5. The SI `0.025` Increment Entry Is Not What PIEP Actually Expects

The publication shows `0.025` at the `factor for default increment` prompt. The FORTRAN source shows that PIEP interprets:

- positive values as a factor applied to the default increment
- negative values as an absolute increment

For the published runs to behave as shown, the automation has to use `-0.025`, not `0.025`.

This is the most important SI-to-executable normalization in the harness.

The explicit protocol fixtures therefore store `-0.025` directly and document why.

### 6. Later `dc` Calls May Ask For An Extra `delete?`

Once C-memory already contains solutions, later `dc` calls can prompt with:

- `*** ... solutions in C-memory, delete? ("n" will falsify int.!)`

This prompt is not consistently represented in the SI transcript, but it appears in automated runs of the legacy executable.

The current harness compensates for this by inserting an extra default-confirmation slot after later `dc` commands. The explicit protocol fixtures record those extra confirmations directly.

### 7. Commands And Responses Can Be Adjacent In Markdown

In the SI file, a line immediately after a code block can either be:

- the operator response to the preceding prompt, or
- the next PIEP command

This is one of the reasons a naive parser fails. The current harness has to distinguish real commands such as `dc`, `de`, `pg`, `i`, `ax`, and `mv` from prompt responses.

The explicit protocol fixtures remove this ambiguity completely by storing only the final ordered input token sequence.

### 8. `pro1.dat` And `pro2.dat` Are Not Reliable Regression Oracles Here

Under this redirected-stdin setup, PIEP does not reliably write `pro1.dat` and `pro2.dat` for all scenarios. The stable oracle is the transcript content in `session.log`.

For that reason the current tests:

- always require a non-empty `session.log`
- optionally include `pro1.dat` and `pro2.dat` if they exist
- assert only against the combined scientific output text

### 9. PIEP Still Shows EOF-Style Shutdown Noise

Even with extra trailing `n` responses, the legacy executable may still emit shutdown noise such as:

- `Fortran runtime error: Read past ENDFILE record`
- a trailing `exit?`

The core scientific workflow is already complete at that point, and the expected search/indexing results are present in the transcript. The current regression suite therefore treats these as legacy shutdown behavior, not scientific failures.

## Current Scientific Oracle

The regression suite intentionally validates semantic transcript checkpoints instead of full terminal snapshots.

Examples:

- candidate-count lines from `pc`
- top `dc` solution parameters
- transformed current-cell parameters
- selected indexing vectors such as `[ -3  1 -4 ]`, `[ 5  0 -6 ]`, or `[ 0  0  1 ]`

This keeps the tests focused on the crystallographic behavior rather than on line wrapping, prompt spacing, or optional auxiliary output files.

## Explicit Protocol Fixture Format

The new fixtures in `tests/legacy_transcripts/protocols/` are meant to replace SI-transcript parsing in future simplified tests.

Each JSON fixture contains:

- `format`
  - protocol schema version
- `scenario`
  - short scenario id
- `source_heading`
  - the publication section from which the fixture was derived
- `cell_centering`
  - starting centering used for the dummy `cell.dat`
- `notes`
  - scenario-specific normalization notes
- `sad_dat_lines`
  - exact `sad.dat` contents from `pub_si.md`
- `stdin_tokens`
  - fully explicit input sequence
- `expected_patterns`
  - the semantic transcript checks already used by the current test

### `stdin_tokens` Convention

`stdin_tokens` is the key part of the explicit fixture format.

Rules:

- normal strings are literal PIEP inputs such as `pg`, `dc`, `2`, `C`, or `0 1500`
- `<RETURN>` means "press Return and accept the current default"
- all default confirmations that were implicit in the SI transcript are written explicitly
- scenario-specific compatibility additions are also written explicitly

This format is intentionally semantic. A future lightweight test can:

- join `sad_dat_lines` with `\\n`
- translate each `<RETURN>` token into the backend-specific blank-input representation
- join the resulting input stream with `\\n`
- run PIEP
- assert `expected_patterns`

## Why These Fixtures Are Better Than Re-Parsing `pub_si.md`

They remove four classes of ambiguity:

- missing default confirmations
- prompts without conventional punctuation
- SI formatting that merges prompts and later output into one block
- legacy-executable quirks that only appear under redirected stdin

In other words, `pub_si.md` remains the archival human source, while the new protocol fixtures are the executable regression source.

## Recommended Next Use

For the next test simplification step, the future harness should prefer:

- protocol JSON fixture
- direct `sad.dat` write
- direct `stdin_tokens` playback
- direct `expected_patterns` assertion

and should stop reparsing `pub_si.md` during normal test execution.
