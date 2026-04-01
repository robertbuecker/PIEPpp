from __future__ import annotations

from pathlib import Path
import shutil
from uuid import uuid4

import pytest

from .piep_harness import SCENARIOS
from .piep_harness import PIEP_EXE_PATH
from .piep_harness import REPO_ROOT
from .piep_harness import assert_expected_patterns
from .piep_harness import output_files
from .piep_harness import run_protocol
from .piep_harness import steps_before_command

@pytest.mark.parametrize("scenario", SCENARIOS, ids=[scenario.name for scenario in SCENARIOS])
def test_pub_si_pattern_ingestion_prefix(scenario) -> None:
    assert PIEP_EXE_PATH.exists(), f"Missing PIEP executable: {PIEP_EXE_PATH}"

    prefix_steps = steps_before_command(scenario, "pc")
    runs_root = REPO_ROOT / "test_runs"
    runs_root.mkdir(exist_ok=True)
    workdir = runs_root / f"{scenario.name}_ingest_{uuid4().hex[:8]}"
    workdir.mkdir()

    try:
        transcript = run_protocol(scenario, workdir, max_steps=prefix_steps, timeout=60)
        assert "which number?" in transcript
        assert "consec. # of data set?" in transcript

        expected_ingestion_patterns = {
            "cupc": (
                r"\b1\s+7\.5862\s+3\.00\s+3\.7509",
                r"\b7\s+14\.1515\s+3\.00\s+14\.4490",
            ),
            "lysozyme": (
                r"\b1 4\s+79\.0641\s+3\.00\s+79\.0641",
                r"\b6 L\s+79\.6400\s+3\.00\s+12\.0911",
            ),
            "grgds": (
                r"\b1 V\s+13\.8185\s+3\.00\s+4\.3885",
                r"\b5\s+12\.9900\s+3\.00\s+1\.4687",
            ),
        }
        assert_expected_patterns(transcript, expected_ingestion_patterns[scenario.name])
    finally:
        shutil.rmtree(workdir, ignore_errors=True)


@pytest.mark.parametrize("scenario", SCENARIOS, ids=[scenario.name for scenario in SCENARIOS])
def test_pub_si_protocol_runs_end_to_end(scenario) -> None:
    assert PIEP_EXE_PATH.exists(), f"Missing PIEP executable: {PIEP_EXE_PATH}"

    runs_root = REPO_ROOT / "test_runs"
    runs_root.mkdir(exist_ok=True)
    workdir = runs_root / f"{scenario.name}_{uuid4().hex[:8]}"
    workdir.mkdir()

    try:
        transcript = run_protocol(scenario, workdir)
        session_log, pro1_path, pro2_path = output_files(workdir)

        assert session_log.exists(), "The transcript log was not written."
        assert session_log.stat().st_size > 0, "The transcript log is empty."

        combined_parts = [transcript]
        if pro1_path.exists() and pro1_path.stat().st_size > 0:
            combined_parts.append(pro1_path.read_text(encoding="utf-8", errors="replace"))
        if pro2_path.exists() and pro2_path.stat().st_size > 0:
            combined_parts.append(pro2_path.read_text(encoding="utf-8", errors="replace"))

        combined_text = "\n".join(combined_parts)
        assert_expected_patterns(combined_text, scenario.expected_patterns)
    finally:
        pass
        shutil.rmtree(workdir, ignore_errors=True)
