"""Sinh data/units/*.tres và data/buildings/*.tres từ data/balance/*.csv (S1.T04).

Chạy hai lần cho ra cùng file (idempotent); chỉ ghi file khi nội dung đổi.
`--check`: không ghi, thoát 1 nếu có file thiếu, cũ hoặc thừa (dùng trong CI).
"""
from __future__ import annotations

import sys
from pathlib import Path
from typing import Any

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
sys.path.insert(0, str(HERE.parent / "data_validator"))

from balance_schema import BUILDING_FIELDS, UNIT_FIELDS, Field  # noqa: E402
from validate import read_table, validate_dir  # noqa: E402

TARGETS = (
    # (csv, fields, script_class, script_path, output_dir, file_prefix)
    ("units.csv", UNIT_FIELDS, "UnitDef", "res://scripts/defs/unit_def.gd", "units", "unit_"),
    ("buildings.csv", BUILDING_FIELDS, "BuildingDef", "res://scripts/defs/building_def.gd", "buildings", "building_"),
)

STRING_NAME_KINDS = ("id", "faction", "domain", "projectile")


def fmt_number(value: float) -> str:
    number = float(value)
    return str(int(number)) if number == int(number) else repr(number)


def fmt_float(value: float) -> str:
    return repr(float(value))


def fmt_value(field: Field, value: Any) -> str:
    kind = field.kind
    if kind in STRING_NAME_KINDS:
        return f'&"{value}"'
    if kind == "str":
        return f'"{value}"'
    if kind == "int":
        return str(int(value))
    if kind == "float":
        return fmt_float(value)
    if kind == "bool":
        return "true" if value else "false"
    if kind == "res":
        return "PackedFloat32Array(" + ", ".join(fmt_number(v) for v in value) + ")"
    if kind in ("list", "reslist"):
        return "PackedStringArray(" + ", ".join(f'"{v}"' for v in value) + ")"
    if kind == "bonus":
        if not value:
            return "{}"
        items = ",\n".join(f'&"{k}": {fmt_float(v)}' for k, v in value.items())
        return "{\n" + items + "\n}"
    if kind == "size":
        return f"Vector2i({value[0]}, {value[1]})"
    raise ValueError(f"kind không biết: {kind}")


def render(script_class: str, script_path: str, fields: tuple[Field, ...], values: dict[str, Any]) -> str:
    lines = [
        f'[gd_resource type="Resource" script_class="{script_class}" load_steps=2 format=3]',
        "",
        f'[ext_resource type="Script" path="{script_path}" id="1_def"]',
        "",
        "[resource]",
        'script = ExtResource("1_def")',
    ]
    for field in fields:
        lines.append(f"{field.name} = {fmt_value(field, values[field.name])}")
    return "\n".join(lines) + "\n"


def generate(balance_dir: Path, data_dir: Path) -> dict[Path, str]:
    """Trả về {đường dẫn .tres: nội dung}."""
    outputs: dict[Path, str] = {}
    for csv_name, fields, script_class, script_path, out_dir, prefix in TARGETS:
        rows, errors = read_table(balance_dir / csv_name, fields)
        if errors:
            raise ValueError("\n".join(str(e) for e in errors))
        for row in rows:
            target = data_dir / out_dir / f"{prefix}{row.values['id']}.tres"
            outputs[target] = render(script_class, script_path, fields, row.values)
    return outputs


def sync(balance_dir: Path, data_dir: Path, check: bool = False) -> list[str]:
    """Ghi (hoặc kiểm tra) các .tres. Trả về danh sách thay đổi/lệch."""
    outputs = generate(balance_dir, data_dir)
    problems: list[str] = []
    for path, content in sorted(outputs.items()):
        current = path.read_text(encoding="utf-8") if path.exists() else None
        if current == content:
            continue
        problems.append(f"{'thiếu' if current is None else 'cũ'}: {path.as_posix()}")
        if not check:
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(content, encoding="utf-8", newline="\n")
    for _, _, _, _, out_dir, prefix in TARGETS:
        for existing in sorted((data_dir / out_dir).glob(f"{prefix}*.tres")):
            if existing not in outputs:
                problems.append(f"thừa: {existing.as_posix()}")
                if not check:
                    existing.unlink()
    return problems


def main(argv: list[str]) -> int:
    sys.stdout.reconfigure(encoding="utf-8")  # console Windows mặc định cp1252
    sys.stderr.reconfigure(encoding="utf-8")
    check = "--check" in argv
    args = [a for a in argv[1:] if not a.startswith("--")]
    balance_dir = Path(args[0]) if args else Path("data/balance")
    data_dir = Path(args[1]) if len(args) > 1 else Path("data")

    errors = validate_dir(balance_dir)
    if errors:
        for err in errors:
            print(err, file=sys.stderr)
        return 1
    problems = sync(balance_dir, data_dir, check=check)
    for problem in problems:
        print(problem)
    if check and problems:
        print("Dữ liệu .tres chưa khớp CSV; chạy: python tools/balance/csv_to_tres.py", file=sys.stderr)
        return 1
    print(f"OK: {len(generate(balance_dir, data_dir))} file .tres" + (" (đã cập nhật)" if problems and not check else ""))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
