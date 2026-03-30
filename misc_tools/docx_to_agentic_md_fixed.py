#!/usr/bin/env python3
"""
Convert a .docx file to Markdown optimized for agentic coding / test generation.

Main behaviors:
- Preserve normal prose as Markdown text, using heading styles when detectable.
- Replace embedded images with dummy Markdown references.
- Detect Courier New content and preserve it with exact spacing.
- Treat red Courier text as user commands / inputs and emit them as normal text.
- Treat non-red Courier text as program responses (or .dat file printouts) and emit them as fenced code blocks.

This script is designed for Word documents similar to the uploaded PIEP supplementary file,
where protocol transcripts are formatted in Courier New and commands are red.

Usage:
    python docx_to_agentic_md.py input.docx -o output.md
"""

from __future__ import annotations

import argparse
import re
import sys
import zipfile
from dataclasses import dataclass, field
from pathlib import Path
from typing import Dict, Iterable, List, Optional, Tuple
import xml.etree.ElementTree as ET


NS = {
    "w": "http://schemas.openxmlformats.org/wordprocessingml/2006/main",
    "r": "http://schemas.openxmlformats.org/officeDocument/2006/relationships",
    "a": "http://schemas.openxmlformats.org/drawingml/2006/main",
    "wp": "http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing",
    "pic": "http://schemas.openxmlformats.org/drawingml/2006/picture",
    "v": "urn:schemas-microsoft-com:vml",
}

W = f"{{{NS['w']}}}"


@dataclass
class StyleInfo:
    style_id: str
    name: str = ""
    outline_level: Optional[int] = None
    based_on: Optional[str] = None


@dataclass
class EffectiveFormat:
    font: Optional[str] = None
    color: Optional[str] = None


@dataclass
class ParaToken:
    kind: str  # text | command | response | image | blank
    text: str = ""
    meta: Dict[str, str] = field(default_factory=dict)


class DocxReader:
    def __init__(self, docx_path: Path):
        self.docx_path = Path(docx_path)
        self.zf = zipfile.ZipFile(self.docx_path)
        self.styles = self._load_styles()
        self._document_tree = ET.fromstring(self.zf.read("word/document.xml"))

    def close(self) -> None:
        self.zf.close()

    def _load_styles(self) -> Dict[str, StyleInfo]:
        styles: Dict[str, StyleInfo] = {}
        try:
            xml = self.zf.read("word/styles.xml")
        except KeyError:
            return styles

        root = ET.fromstring(xml)
        for st in root.findall("w:style", NS):
            if st.get(f"{W}type") != "paragraph":
                continue
            style_id = st.get(f"{W}styleId") or ""
            info = StyleInfo(style_id=style_id)
            name_el = st.find("w:name", NS)
            if name_el is not None:
                info.name = name_el.get(f"{W}val") or ""
            based_on_el = st.find("w:basedOn", NS)
            if based_on_el is not None:
                info.based_on = based_on_el.get(f"{W}val")
            ppr = st.find("w:pPr", NS)
            if ppr is not None:
                outline = ppr.find("w:outlineLvl", NS)
                if outline is not None and outline.get(f"{W}val") is not None:
                    try:
                        info.outline_level = int(outline.get(f"{W}val"))
                    except ValueError:
                        pass
            styles[style_id] = info
        return styles

    def iter_block_items(self) -> Iterable[ET.Element]:
        body = self._document_tree.find("w:body", NS)
        if body is None:
            return []
        return list(body)


# ---------- Formatting helpers ----------

def get_attr(el: Optional[ET.Element], qname: str) -> Optional[str]:
    if el is None:
        return None
    return el.get(qname)


def normalize_color(val: Optional[str]) -> Optional[str]:
    if not val:
        return None
    val = val.strip().upper()
    if val in {"AUTO", "000000"}:
        return "000000"
    if re.fullmatch(r"[0-9A-F]{6}", val):
        return val
    return val


def is_red(color: Optional[str]) -> bool:
    color = normalize_color(color)
    if not color:
        return False
    return color in {
        "FF0000",
        "C00000",
        "9C0006",
        "RED",
    }


def normalize_font_name(name: Optional[str]) -> Optional[str]:
    if not name:
        return None
    return name.strip().lower()


def is_courier_font(name: Optional[str]) -> bool:
    n = normalize_font_name(name)
    if not n:
        return False
    return n in {"courier new", "couriernew", "courier"}


def first_not_none(*values: Optional[str]) -> Optional[str]:
    for v in values:
        if v is not None:
            return v
    return None


def extract_rpr_format(rpr: Optional[ET.Element]) -> EffectiveFormat:
    if rpr is None:
        return EffectiveFormat()
    rfonts = rpr.find("w:rFonts", NS)
    color_el = rpr.find("w:color", NS)
    font = None
    if rfonts is not None:
        font = (
            rfonts.get(f"{W}ascii")
            or rfonts.get(f"{W}hAnsi")
            or rfonts.get(f"{W}cs")
            or rfonts.get(f"{W}eastAsia")
        )
    color = color_el.get(f"{W}val") if color_el is not None else None
    return EffectiveFormat(font=font, color=normalize_color(color))


def merge_effective_format(parent: EffectiveFormat, child: EffectiveFormat) -> EffectiveFormat:
    return EffectiveFormat(
        font=first_not_none(child.font, parent.font),
        color=first_not_none(child.color, parent.color),
    )


# ---------- Paragraph extraction ----------

def paragraph_default_format(p: ET.Element) -> EffectiveFormat:
    ppr = p.find("w:pPr", NS)
    if ppr is None:
        return EffectiveFormat()
    rpr = ppr.find("w:rPr", NS)
    return extract_rpr_format(rpr)


def paragraph_style_id(p: ET.Element) -> Optional[str]:
    ppr = p.find("w:pPr", NS)
    if ppr is None:
        return None
    pstyle = ppr.find("w:pStyle", NS)
    if pstyle is None:
        return None
    return pstyle.get(f"{W}val")


def heading_level_for_style(style_id: Optional[str], styles: Dict[str, StyleInfo]) -> Optional[int]:
    if not style_id:
        return None

    seen = set()
    cur = style_id
    while cur and cur not in seen:
        seen.add(cur)
        info = styles.get(cur)
        if info is None:
            break
        if info.outline_level is not None:
            return info.outline_level + 1
        text = f"{info.style_id} {info.name}".lower()
        if "title" in text:
            return 1
        if "heading" in text or "überschrift" in text:
            m = re.search(r"(heading|überschrift)\s*([1-9])", text)
            if m:
                return int(m.group(2))
            return 1
        cur = info.based_on

    text = (style_id or "").lower()
    if "title" in text:
        return 1
    m = re.search(r"heading\s*([1-9])|überschrift\s*([1-9])", text)
    if m:
        nums = [g for g in m.groups() if g]
        if nums:
            return int(nums[0])
    return None


def collect_run_text(run: ET.Element) -> str:
    parts: List[str] = []
    for node in run.iter():
        tag = node.tag
        if tag == f"{W}t":
            parts.append(node.text or "")
        elif tag == f"{W}tab":
            parts.append("\t")
        elif tag in {f"{W}br", f"{W}cr"}:
            parts.append("\n")
    return "".join(parts)


def iter_runs_in_order(paragraph: ET.Element) -> Iterable[ET.Element]:
    for child in paragraph:
        if child.tag == f"{W}r":
            yield child
        elif child.tag == f"{W}hyperlink":
            for r in child.findall("w:r", NS):
                yield r
        elif child.tag == f"{W}smartTag":
            for r in child.findall(".//w:r", NS):
                yield r
        elif child.tag == f"{W}sdt":
            for r in child.findall(".//w:r", NS):
                yield r


def paragraph_has_image(paragraph: ET.Element) -> bool:
    return (
        paragraph.find(".//w:drawing", NS) is not None
        or paragraph.find(".//w:pict", NS) is not None
        or paragraph.find(".//v:imagedata", NS) is not None
    )


def paragraph_text(paragraph: ET.Element) -> str:
    parts: List[str] = []
    for run in iter_runs_in_order(paragraph):
        parts.append(collect_run_text(run))
    return "".join(parts)


def classify_paragraph(paragraph: ET.Element, styles: Dict[str, StyleInfo], image_counter: int) -> Tuple[List[ParaToken], int]:
    tokens: List[ParaToken] = []

    if paragraph_has_image(paragraph):
        image_counter += 1
        tokens.append(
            ParaToken(
                kind="image",
                text=f"![Image placeholder](image_placeholder_{image_counter:03d}.png)",
                meta={"index": str(image_counter)},
            )
        )

    default_fmt = paragraph_default_format(paragraph)
    runs = list(iter_runs_in_order(paragraph))

    non_ws_runs: List[Tuple[str, EffectiveFormat]] = []
    for run in runs:
        txt = collect_run_text(run)
        if txt == "":
            continue
        rfmt = merge_effective_format(default_fmt, extract_rpr_format(run.find("w:rPr", NS)))
        if txt.strip() != "":
            non_ws_runs.append((txt, rfmt))

    if non_ws_runs:
        courier_runs = sum(1 for _txt, fmt in non_ws_runs if is_courier_font(fmt.font))
        all_courier = courier_runs == len(non_ws_runs)
    else:
        all_courier = is_courier_font(default_fmt.font)

    full_text = paragraph_text(paragraph)

    if full_text == "" and not tokens:
        tokens.append(ParaToken(kind="blank", text=""))
        return tokens, image_counter

    if all_courier:
        has_red = False
        has_non_red = False
        for _txt, fmt in non_ws_runs:
            if is_red(fmt.color):
                has_red = True
            else:
                has_non_red = True

        if has_red and not has_non_red:
            tokens.append(ParaToken(kind="command", text=full_text))
        else:
            tokens.append(ParaToken(kind="response", text=full_text))
        return tokens, image_counter

    style_id = paragraph_style_id(paragraph)
    level = heading_level_for_style(style_id, styles)
    if full_text == "":
        tokens.append(ParaToken(kind="blank", text=""))
    else:
        meta: Dict[str, str] = {}
        if level is not None:
            meta["heading_level"] = str(level)
        tokens.append(ParaToken(kind="text", text=full_text, meta=meta))
    return tokens, image_counter


# ---------- Markdown emission ----------

def format_normal_text(text: str, meta: Dict[str, str]) -> str:
    if "heading_level" in meta:
        level = int(meta["heading_level"])
        return f"{'#' * max(1, level)} {text.strip()}"
    return text.rstrip()


def flush_response_block(out: List[str], response_lines: List[str]) -> None:
    if not response_lines:
        return
    block = "\n".join(response_lines)
    out.append("```text")
    out.append(block)
    out.append("```")
    out.append("")
    response_lines.clear()


def emit_markdown(tokens: List[ParaToken]) -> str:
    out: List[str] = []
    response_lines: List[str] = []
    pending_blank_text = False

    def ensure_paragraph_spacing() -> None:
        nonlocal pending_blank_text
        if out and out[-1] != "":
            out.append("")
        pending_blank_text = False

    for tok in tokens:
        if tok.kind == "response":
            response_lines.append(tok.text)
            pending_blank_text = False
            continue

        if tok.kind == "blank":
            # Critical fix:
            # If we are currently in a response/code block, preserve the blank
            # line inside that same block instead of flushing/splitting it.
            if response_lines:
                response_lines.append("")
                pending_blank_text = False
            else:
                if out and out[-1] != "":
                    out.append("")
                pending_blank_text = True
            continue

        flush_response_block(out, response_lines)

        if tok.kind == "image":
            ensure_paragraph_spacing()
            out.append(tok.text)
            out.append("")
            continue

        if tok.kind == "command":
            ensure_paragraph_spacing()
            out.append(tok.text)
            out.append("")
            continue

        if tok.kind == "text":
            ensure_paragraph_spacing()
            out.append(format_normal_text(tok.text, tok.meta))
            out.append("")
            continue

    flush_response_block(out, response_lines)

    while out and out[-1] == "":
        out.pop()
    return "\n".join(out) + "\n"


# ---------- Conversion driver ----------

def convert_docx_to_markdown(docx_path: Path, output_path: Path) -> None:
    reader = DocxReader(docx_path)
    try:
        tokens: List[ParaToken] = []
        image_counter = 0
        for block in reader.iter_block_items():
            if block.tag == f"{W}p":
                ptoks, image_counter = classify_paragraph(block, reader.styles, image_counter)
                tokens.extend(ptoks)
            elif block.tag == f"{W}tbl":
                for tr in block.findall("w:tr", NS):
                    cells: List[str] = []
                    for tc in tr.findall("w:tc", NS):
                        paras = []
                        for p in tc.findall("w:p", NS):
                            paras.append(paragraph_text(p).strip())
                        cells.append(" ".join(x for x in paras if x != ""))
                    row = " | ".join(cells)
                    tokens.append(ParaToken(kind="text", text=row))
                tokens.append(ParaToken(kind="blank", text=""))

        md = emit_markdown(tokens)
        output_path.write_text(md, encoding="utf-8", newline="\n")
    finally:
        reader.close()


def main(argv: Optional[List[str]] = None) -> int:
    parser = argparse.ArgumentParser(description="Convert a .docx protocol document into agent-friendly Markdown.")
    parser.add_argument("input", type=Path, help="Input .docx file")
    parser.add_argument("-o", "--output", type=Path, help="Output .md file")
    args = parser.parse_args(argv)

    if not args.input.exists():
        print(f"Input file not found: {args.input}", file=sys.stderr)
        return 2
    if args.input.suffix.lower() != ".docx":
        print("Input must be a .docx file", file=sys.stderr)
        return 2

    output = args.output or args.input.with_suffix(".md")
    convert_docx_to_markdown(args.input, output)
    print(str(output))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
