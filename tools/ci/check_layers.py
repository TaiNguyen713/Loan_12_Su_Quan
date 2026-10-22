"""Kiểm tra quy tắc phụ thuộc giữa các lớp trong scripts/ (S1.T01).

Bảng ALLOWED lấy từ docs/plan/03_SKELETON.md §2. Autoload (EventBus, SceneRouter, ...) được
gọi từ mọi lớp. Các lớp mô phỏng không được gọi API vẽ.
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

ALLOWED: dict[str, set[str]] = {
    "defs": set(),
    "core": {"defs"},
    "sim": {"core", "defs", "entities", "commands"},
    "entities": {"core", "defs", "sim", "commands"},
    "commands": {"core", "defs", "sim", "entities"},
    "ai": {"core", "defs", "sim", "commands", "entities"},
    "input": {"core", "defs", "sim", "commands", "entities"},
    "render": {"core", "defs", "sim", "commands", "entities", "input"},
    "ui": {"core", "defs", "sim", "commands", "entities", "input", "render"},
    "campaign": {"core", "defs", "sim"},
    "platform": {"core", "defs"},
    "net": {"core", "defs", "sim", "commands"},
    "autoload": {"core", "defs"},
}
NO_DRAWING = {"defs", "core", "sim", "entities", "commands", "ai", "input", "campaign", "net"}

CLASS_NAME = re.compile(r"^\s*class_name\s+(\w+)", re.M)
RES_PATH = re.compile(r"res://scripts/(\w+)/")
STRING = re.compile(r'"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'')
DRAWING = re.compile(r"\bqueue_redraw\s*\(|\bdraw_\w+\s*\(|\bCanvasItem\b")


def layer_of(path: Path, scripts_dir: Path) -> str | None:
    parts = path.relative_to(scripts_dir).parts
    return parts[0] if len(parts) > 1 else None


def code_lines(text: str) -> list[tuple[int, str, str]]:
    """(số dòng, dòng gốc, dòng đã bỏ chuỗi và comment). Bỏ qua dòng comment thuần."""
    result = []
    for number, raw in enumerate(text.splitlines(), start=1):
        if raw.lstrip().startswith("#"):
            continue
        stripped = STRING.sub('""', raw).split("#", 1)[0]
        result.append((number, raw, stripped))
    return result


def check(scripts_dir: Path) -> list[str]:
    files = sorted(scripts_dir.rglob("*.gd"))
    class_layer: dict[str, str] = {}
    for file in files:
        layer = layer_of(file, scripts_dir)
        if layer is None:
            continue
        for name in CLASS_NAME.findall(file.read_text(encoding="utf-8")):
            class_layer[name] = layer

    errors: list[str] = []
    for file in files:
        layer = layer_of(file, scripts_dir)
        if layer is None or layer not in ALLOWED:
            continue
        shown = file.as_posix()
        allowed = ALLOWED[layer] | {layer, "autoload"}
        for number, raw, code in code_lines(file.read_text(encoding="utf-8")):
            for target in RES_PATH.findall(raw):
                if target not in allowed:
                    errors.append(f"{shown}:{number}:1: lớp '{layer}' không được dùng lớp '{target}'")
            for name, target in class_layer.items():
                if target not in allowed and re.search(rf"\b{name}\b", code):
                    errors.append(f"{shown}:{number}:1: lớp '{layer}' không được dùng {name} (lớp '{target}')")
            if layer in NO_DRAWING and DRAWING.search(code):
                errors.append(f"{shown}:{number}:1: lớp '{layer}' không được gọi API vẽ")
    return errors


def main(argv: list[str]) -> int:
    sys.stdout.reconfigure(encoding="utf-8")
    sys.stderr.reconfigure(encoding="utf-8")
    scripts_dir = Path(argv[1]) if len(argv) > 1 else Path("scripts")
    errors = check(scripts_dir)
    for error in errors:
        print(error, file=sys.stderr)
    if errors:
        return 1
    print(f"OK: {scripts_dir} đúng quy tắc lớp")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
