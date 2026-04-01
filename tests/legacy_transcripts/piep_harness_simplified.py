from __future__ import annotations

from dataclasses import dataclass
import json
from pathlib import Path
import re
import subprocess
from typing import Iterable


REPO_ROOT = Path(__file__).resolve().parents[2]
PIEP_EXE_PATH = REPO_ROOT / "Piep-Z17.exe"
PIEP_PAR_TEMPLATE_PATH = REPO_ROOT / "Piep.par"
PROTOCOLS_DIR = Path(__file__).resolve().parent / "protocols"

KNOWN_COMMANDS = {
    "ap",
    "ax",
    "dc",
    "de",
    "en",
    "i",
    "m1",
    "m2",
    "ma",
    "mi",
    "mm",
    "mr",
    "mv",
    "pc",
    "pg",
    "v",
    "vm",
    "vs",
    "vv",
}


@dataclass(frozen=True)
class ProtocolSpec:
    name: str
    source_heading: str
    cell_centering: str
    sad_dat_lines: tuple[str, ...]
    stdin_tokens: tuple[str, ...]
    expected_patterns: tuple[str, ...]
    notes: tuple[str, ...]
    protocol_path: Path


def load_protocols() -> tuple[ProtocolSpec, ...]:
    return tuple(
        _load_protocol(path)
        for path in sorted(PROTOCOLS_DIR.glob("*.json"))
    )


def get_protocol(name: str) -> ProtocolSpec:
    for protocol in PROTOCOLS:
        if protocol.name == name:
            return protocol
    raise KeyError(f"Unknown protocol: {name}")


def write_temp_inputs(workdir: Path, spec: ProtocolSpec) -> None:
    workdir.mkdir(parents=True, exist_ok=True)
    (workdir / "sad.dat").write_text("\n".join(spec.sad_dat_lines) + "\n", encoding="utf-8")
    (workdir / "cell.dat").write_text(_dummy_cell_file(spec.cell_centering), encoding="utf-8")
    (workdir / "piep.par").write_text(_rewrite_parameter_file(), encoding="utf-8")


def build_input_script(
    spec: ProtocolSpec,
    max_steps: int | None = None,
) -> str:
    tokens = spec.stdin_tokens if max_steps is None else spec.stdin_tokens[:max_steps]
    lines = [_materialize_token(token) for token in tokens]
    return "\n".join(lines) + "\n"


def run_protocol(
    spec: ProtocolSpec,
    workdir: Path,
    max_steps: int | None = None,
    timeout: int = 600,
) -> str:
    write_temp_inputs(workdir, spec)
    input_script = build_input_script(spec, max_steps=max_steps)
    (workdir / "input.script").write_text(input_script, encoding="utf-8", newline="\n")

    session_log_path = workdir / "session.log"
    try:
        completed = subprocess.run(
            [str(PIEP_EXE_PATH)],
            cwd=str(workdir),
            input=input_script,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            encoding="cp1252",
            errors="replace",
            timeout=timeout,
        )
        session_log_path.write_text(completed.stdout, encoding="utf-8")
        return completed.stdout
    except subprocess.TimeoutExpired as exc:
        partial = exc.stdout or ""
        session_log_path.write_text(partial, encoding="utf-8")
        raise TimeoutError(f"PIEP timed out while running scenario {spec.name!r}") from exc


def output_files(workdir: Path) -> tuple[Path, Path, Path]:
    return workdir / "session.log", workdir / "pro1.dat", workdir / "pro2.dat"


def steps_before_command(spec: ProtocolSpec, command: str) -> int:
    target = command.lower()
    for index, token in enumerate(spec.stdin_tokens):
        lowered = token.lower()
        if lowered == target and lowered in KNOWN_COMMANDS:
            return index
    raise ValueError(f"Command {command!r} not found in scenario {spec.name!r}")


def assert_expected_patterns(text: str, patterns: Iterable[str]) -> None:
    for pattern in patterns:
        assert re.search(pattern, text, flags=re.MULTILINE), f"Missing pattern: {pattern}"


def _load_protocol(path: Path) -> ProtocolSpec:
    data = json.loads(path.read_text(encoding="utf-8"))
    return ProtocolSpec(
        name=data["scenario"],
        source_heading=data["source_heading"],
        cell_centering=data["cell_centering"],
        sad_dat_lines=tuple(data["sad_dat_lines"]),
        stdin_tokens=tuple(data["stdin_tokens"]),
        expected_patterns=tuple(data["expected_patterns"]),
        notes=tuple(data.get("notes", ())),
        protocol_path=path,
    )


def _materialize_token(token: str) -> str:
    if token == "<RETURN>":
        return " "
    return token


def _dummy_cell_file(centering: str) -> str:
    return (
        "dummy\n"
        "  10.0000  10.0000  10.0000  90.00  90.00  90.00\n"
        f"{centering} (***)\n"
        "END$\n"
    )


def _rewrite_parameter_file() -> str:
    text = PIEP_PAR_TEMPLATE_PATH.read_text(encoding="utf-8", errors="replace")
    lines = text.splitlines()

    dollar_index = None
    for index, line in enumerate(lines):
        if line.startswith("$"):
            dollar_index = index
            break
    if dollar_index is None:
        raise ValueError("Could not find filename section in Piep.par.")

    filenames = ("cell.dat", "sad.dat", "pro1.dat", "pro2.dat", "cell.sc")
    for offset, filename in enumerate(filenames, start=1):
        current = lines[dollar_index + offset]
        lines[dollar_index + offset] = filename.ljust(20) + current[20:]

    return "\n".join(lines) + "\n"


PROTOCOLS = load_protocols()
