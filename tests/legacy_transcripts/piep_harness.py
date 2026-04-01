from __future__ import annotations

from dataclasses import dataclass
import os
from pathlib import Path
import re
import subprocess
from typing import Iterable


REPO_ROOT = Path(__file__).resolve().parents[2]
PUB_SI_PATH = REPO_ROOT / "pub_si.md"
PIEP_EXE_PATH = REPO_ROOT / "Piep-Z17.exe"
PIEP_PAR_TEMPLATE_PATH = REPO_ROOT / "Piep.par"

CODE_BLOCK_RE = re.compile(r"```text\r?\n(.*?)```", re.DOTALL)
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
class EmbeddedResponse:
    prompt: str
    response: str


@dataclass(frozen=True)
class ScenarioSpec:
    name: str
    heading_fragment: str
    cell_centering: str
    expected_patterns: tuple[str, ...]


@dataclass(frozen=True)
class InputItem:
    value: str
    kind: str


@dataclass(frozen=True)
class ScenarioAssets:
    sad_data: str
    input_items: tuple[InputItem, ...]


SCENARIOS: tuple[ScenarioSpec, ...] = (
    ScenarioSpec(
        name="cupc",
        heading_fragment="PIEP run for unit cell parameters determination for CuPcCl16",
        cell_centering="P",
        expected_patterns=(
            r"786 sets within\s+12 layers",
            r"\b0\.85\s+3\.82\s+15\.28\s+15\.60\s+111\.7\s+93\.1\s+92\.9\b",
            r"current cell:\s+17\.3289\s+25\.5672\s+3\.8175",
            r"\[\s+-3\s+1\s+-4\]",
            r"\[\s+0\s+0\s+-1\]",
        ),
    ),
    ScenarioSpec(
        name="lysozyme",
        heading_fragment="PIEP run for unit cell parameters determination for lysozyme",
        cell_centering="F",
        expected_patterns=(
            r"102 sets within\s+51 layers",
            r"29492 sets within\s+84 layers",
            r"dir\.lc\.\:\s+79\.0641\s+79\.0641\s+38\.2168",
            r"\[\s+5\s+0\s+-6\]",
            r"\b0\.60\s+38\.48\s+78\.65\s+78\.99\s+90\.0\s+90\.0\s+91\.4\b",
        ),
    ),
    ScenarioSpec(
        name="grgds",
        heading_fragment="PIEP run for unit cell parameters determination for GRGDS",
        cell_centering="F",
        expected_patterns=(
            r"8642 sets within\s+72 layers",
            r"\b0\.84\s+4\.44\s+14\.51\s+19\.47\s+105\.3\s+90\.0\s+98\.8\b",
            r"current cell:\s+28\.6756\s+4\.4446\s+19\.4660",
            r"\[\s+0\s+0\s+1\]",
        ),
    ),
)


def get_scenario(name: str) -> ScenarioSpec:
    for scenario in SCENARIOS:
        if scenario.name == name:
            return scenario
    raise KeyError(f"Unknown scenario: {name}")


def load_pub_si_text() -> str:
    return PUB_SI_PATH.read_text(encoding="utf-8", errors="replace")


def extract_scenario_assets(spec: ScenarioSpec) -> ScenarioAssets:
    section = _extract_top_level_section(load_pub_si_text(), spec.heading_fragment)
    sad_data = _extract_sad_data(section)
    input_items = _extract_protocol_inputs(section)
    return ScenarioAssets(sad_data=sad_data, input_items=input_items)


def write_temp_inputs(workdir: Path, spec: ScenarioSpec, assets: ScenarioAssets) -> None:
    workdir.mkdir(parents=True, exist_ok=True)
    (workdir / "sad.dat").write_text(assets.sad_data.rstrip() + "\n", encoding="utf-8")
    (workdir / "cell.dat").write_text(_dummy_cell_file(spec.cell_centering), encoding="utf-8")
    (workdir / "piep.par").write_text(_rewrite_parameter_file(), encoding="utf-8")


def run_protocol(
    spec: ScenarioSpec,
    workdir: Path,
    max_steps: int | None = None,
    timeout: int = 600,
) -> str:
    assets = extract_scenario_assets(spec)
    write_temp_inputs(workdir, spec, assets)
    input_script = build_input_script(spec, assets, max_steps=max_steps)
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


def assert_expected_patterns(text: str, patterns: Iterable[str]) -> None:
    for pattern in patterns:
        assert re.search(pattern, text, flags=re.MULTILINE), f"Missing pattern: {pattern}"


def build_input_script(
    spec: ScenarioSpec,
    assets: ScenarioAssets | None = None,
    max_steps: int | None = None,
) -> str:
    if assets is None:
        assets = extract_scenario_assets(spec)

    items = assets.input_items if max_steps is None else assets.input_items[:max_steps]
    lines = [item.value for item in items]
    if max_steps is None:
        lines.extend(["n"] * 8)

    return "\n".join(lines) + "\n"


def steps_before_command(spec: ScenarioSpec, command: str) -> int:
    assets = extract_scenario_assets(spec)
    target = command.lower()
    for index, item in enumerate(assets.input_items):
        if item.kind == "command" and item.value.lower() == target:
            return index
    raise ValueError(f"Command {command!r} not found in scenario {spec.name!r}")


def _extract_top_level_section(markdown: str, heading_fragment: str) -> str:
    match = re.search(
        rf"^# .*(?:{re.escape(heading_fragment)}).*$",
        markdown,
        flags=re.MULTILINE,
    )
    if not match:
        raise ValueError(f"Could not find section heading containing: {heading_fragment}")
    start = match.start()

    next_match = re.search(r"^# ", markdown[start + 1 :], flags=re.MULTILINE)
    if not next_match:
        return markdown[start:]
    end = start + 1 + next_match.start()
    return markdown[start:end]


def _extract_sad_data(section: str) -> str:
    input_heading = section.find("## Input file")
    protocol_heading = section.find("## Communication protocol with PIEP")
    if input_heading == -1 or protocol_heading == -1 or protocol_heading <= input_heading:
        raise ValueError("Could not isolate SAD input block in SI section.")

    input_region = section[input_heading:protocol_heading]
    match = CODE_BLOCK_RE.search(input_region)
    if not match:
        raise ValueError("Could not find SAD code block in SI section.")
    return match.group(1).strip()


def _extract_protocol_inputs(section: str) -> tuple[InputItem, ...]:
    protocol_heading = section.find("## Communication protocol with PIEP")
    if protocol_heading == -1:
        raise ValueError("Could not find protocol heading in SI section.")

    protocol_region = section[protocol_heading:]
    blocks = list(CODE_BLOCK_RE.finditer(protocol_region))
    if not blocks:
        raise ValueError("Protocol section does not contain any code blocks.")

    items: list[InputItem] = []
    for index, block in enumerate(blocks):
        next_start = blocks[index + 1].start() if index + 1 < len(blocks) else len(protocol_region)
        input_region = protocol_region[block.end() : next_start]
        region_inputs = _parse_input_region(input_region)
        block_items, consumed_from_region = _extract_block_inputs(block.group(1), region_inputs)
        items.extend(block_items)
        for line in region_inputs[consumed_from_region:]:
            items.append(InputItem(value=line, kind="command"))

    return _apply_runtime_compatibility_defaults(tuple(items))


def _parse_input_region(text: str) -> list[str]:
    lines = [line.strip() for line in text.splitlines() if not line.strip().startswith("#")]
    return [line for line in lines if line]


def _extract_block_inputs(output_block: str, following_inputs: list[str]) -> tuple[tuple[InputItem, ...], int]:
    lines = [line.strip() for line in output_block.splitlines() if line.strip()]
    if not lines:
        return tuple(), 0

    prompt_indexes = [index for index, line in enumerate(lines) if _looks_like_prompt_line(line)]
    waiting_for_external_input = lines[-1] != "*"
    command_menu = _looks_like_command_menu(lines[-1])
    external_response_allowed = waiting_for_external_input and not command_menu
    consumed_indexes: set[int] = set()
    consumed_from_region = 0
    items: list[InputItem] = []

    if _needs_hidden_default(lines):
        items.append(InputItem(value=" ", kind="default"))

    for prompt_index in prompt_indexes:
        next_index, next_line = _next_unconsumed_line(lines, prompt_index + 1, consumed_indexes)
        if next_line is not None and _looks_like_embedded_input(next_line):
            items.append(
                InputItem(
                    value=_normalize_response_for_prompt(lines[prompt_index], next_line),
                    kind="response",
                )
            )
            consumed_indexes.add(next_index)
            continue

        if _prompt_followed_by_output(prompt_index, lines):
            omitted_response = _implicit_response_for_prompt(lines[prompt_index])
            items.append(
                InputItem(
                    value=omitted_response if omitted_response is not None else " ",
                    kind="response" if omitted_response is not None else "default",
                )
            )
            continue

    if external_response_allowed:
        prompt_line = lines[prompt_indexes[-1]] if prompt_indexes else lines[-1]
        if following_inputs and not _looks_like_command(following_inputs[0]):
            items.append(
                InputItem(
                    value=_normalize_response_for_prompt(prompt_line, following_inputs[0]),
                    kind="response",
                )
            )
            consumed_from_region = 1
        else:
            items.append(InputItem(value=" ", kind="default"))

    return tuple(items), consumed_from_region


def _next_unconsumed_line(
    lines: list[str],
    start_index: int,
    consumed_indexes: set[int],
) -> tuple[int, str | None]:
    for index in range(start_index, len(lines)):
        if index not in consumed_indexes:
            return index, lines[index]
    return -1, None


def _looks_like_embedded_input(line: str) -> bool:
    tokens = line.split()
    if not tokens:
        return False
    if "?" in line:
        return False
    if len(tokens) > 12:
        return False

    token_pattern = re.compile(r"[A-Za-z]|[+-]?(?:\d+(?:\.\d*)?|\.\d+)")
    return all(token_pattern.fullmatch(token) for token in tokens)


def _looks_like_prompt_line(line: str) -> bool:
    lowered = line.lower()
    return (
        "?" in line
        or (
            "def.:" in lowered
            and not lowered.startswith("def.:")
            and any(char.isalpha() for char in lowered.split("def.:", maxsplit=1)[0])
        )
    )


def _prompt_followed_by_output(prompt_index: int, lines: list[str]) -> bool:
    for line in lines[prompt_index + 1 :]:
        if "?" in line:
            continue
        if _looks_like_prompt_line(line):
            continue
        if _looks_like_instruction_line(line):
            continue
        return True
    return False


def _looks_like_instruction_line(line: str) -> bool:
    lowered = line.lower()
    return (
        lowered.startswith("def.:")
        or lowered.startswith("one line:")
        or lowered.startswith("1st:")
        or lowered.startswith("2nd:")
        or lowered.startswith("abs. value >")
    )


def _looks_like_command_menu(line: str) -> bool:
    return line.count(",") >= 3 and ";" in line


def _looks_like_command(line: str) -> bool:
    return line.strip().lower() in KNOWN_COMMANDS


def _normalize_response_for_prompt(prompt_line: str, response: str) -> str:
    lowered = prompt_line.lower()
    if "factor for default increment" not in lowered:
        return response

    prompt_default = re.search(r"\(([-+]?(?:\d+(?:\.\d*)?|\.\d+))\)", prompt_line)
    response_value = _parse_numeric_response(response)
    if prompt_default is None or response_value is None or response_value <= 0:
        return response

    default_value = float(prompt_default.group(1))
    if abs(response_value - default_value) > 1e-6:
        return response

    return f"-{response.strip()}"


def _parse_numeric_response(response: str) -> float | None:
    stripped = response.strip()
    if not stripped or " " in stripped:
        return None
    try:
        return float(stripped)
    except ValueError:
        return None


def _implicit_response_for_prompt(prompt_line: str) -> str | None:
    lowered = prompt_line.lower()
    if "consec. # of data set?" not in lowered:
        return None

    match = re.search(r"\(\s*(-?\d+)\s*\)", prompt_line)
    if match is None:
        return None
    return match.group(1)


def _apply_runtime_compatibility_defaults(items: tuple[InputItem, ...]) -> tuple[InputItem, ...]:
    patched: list[InputItem] = []
    dc_count = 0
    add_delete_default = False

    for item in items:
        patched.append(item)

        if item.kind == "command" and item.value.lower() == "dc":
            dc_count += 1
            add_delete_default = dc_count > 1
            continue

        if add_delete_default and item.kind != "command":
            patched.append(InputItem(value=" ", kind="default"))
            add_delete_default = False

    return tuple(patched)


def _needs_hidden_default(lines: list[str]) -> bool:
    has_numbered_instruction = any(
        line.lower().startswith("1st:") or line.lower().startswith("2nd:")
        for line in lines
    )
    has_return_hint = any("<return>" in line.lower() for line in lines)
    return has_numbered_instruction or has_return_hint


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
