"""Kiểm tra dữ liệu cân bằng trong data/balance/*.csv (S1.T04).

Luật:
  1. Ô bắt buộc không được trống.
  2. Số >= 0, accuracy trong [0, 1], range >= min_range, growth >= 1.
  3. Mọi tham chiếu (trains, replaces) phải tồn tại.
  4. Quân tầm xa (range > 20) phải có projectile; đạn súng/pháo/thuyền phải có ammo (trừ NPC).
  5. era của đơn vị >= era của công trình luyện ra nó.
  6. Phe của đơn vị và công trình luyện ra nó phải tương thích.
Lỗi in theo dạng `file:dòng:cột: thông điệp`, exit code 1 nếu có lỗi.
"""
from __future__ import annotations

import csv
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Any

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "balance"))

from balance_schema import (
    AMMO_PROJECTILES,
    BUILDING_FIELDS,
    UNIT_FIELDS,
    Field,
    ParseError,
    parse_value,
)

MELEE_MAX_RANGE = 20.0


@dataclass(frozen=True)
class Err:
    path: str
    line: int
    col: int
    msg: str

    def __str__(self) -> str:
        return f"{self.path}:{self.line}:{self.col}: {self.msg}"


@dataclass
class Row:
    line: int
    values: dict[str, Any]


def read_table(path: Path, fields: tuple[Field, ...]) -> tuple[list[Row], list[Err]]:
    """Đọc một file CSV, trả về các dòng đã parse và danh sách lỗi."""
    errors: list[Err] = []
    rows: list[Row] = []
    shown = path.as_posix()
    with path.open(encoding="utf-8", newline="") as handle:
        reader = csv.reader(handle)
        header = next(reader, None)
        if header is None:
            return rows, [Err(shown, 1, 1, "file CSV trống")]
        known = {f.name: i for i, f in enumerate(fields)}
        for name in header:
            if name not in known:
                errors.append(Err(shown, 1, header.index(name) + 1, f"cột lạ {name!r}"))
        for field in fields:
            if field.required and field.name not in header:
                errors.append(Err(shown, 1, 1, f"thiếu cột bắt buộc {field.name!r}"))
        if errors:
            return rows, errors
        index = {name: i for i, name in enumerate(header)}
        for record in reader:
            if not any(cell.strip() for cell in record):
                continue
            line = reader.line_num
            values: dict[str, Any] = {}
            for field in fields:
                col = index.get(field.name)
                raw = record[col] if col is not None and col < len(record) else ""
                try:
                    values[field.name] = parse_value(field, raw)
                except ParseError as exc:
                    cell = (col or 0) + 1
                    errors.append(Err(shown, line, cell, f"{field.name}: {exc}"))
                    values[field.name] = field.default
            rows.append(Row(line, values))
    return rows, errors


def _check_unique(rows: list[Row], shown: str, errors: list[Err]) -> dict[str, Row]:
    by_id: dict[str, Row] = {}
    for row in rows:
        row_id = row.values["id"]
        if row_id in by_id:
            errors.append(Err(shown, row.line, 1, f"id trùng {row_id!r} (đã có ở dòng {by_id[row_id].line})"))
        else:
            by_id[row_id] = row
    return by_id


def validate_tables(
    units: list[Row],
    buildings: list[Row],
    units_path: str = "units.csv",
    buildings_path: str = "buildings.csv",
) -> list[Err]:
    """Các luật 2–6 áp dụng lên dữ liệu đã parse."""
    errors: list[Err] = []
    unit_by_id = _check_unique(units, units_path, errors)
    _check_unique(buildings, buildings_path, errors)

    for row in units:
        v = row.values
        if v["range"] < v["min_range"]:
            errors.append(Err(units_path, row.line, 1, f"{v['id']}: range < min_range"))
        if v["range"] > MELEE_MAX_RANGE and not v["projectile"]:
            errors.append(Err(units_path, row.line, 1, f"{v['id']}: tầm xa nhưng thiếu projectile"))
        needs_ammo = v["projectile"] in AMMO_PROJECTILES and v["faction"] != "npc"
        if needs_ammo and not any(v["ammo"]):
            errors.append(Err(units_path, row.line, 1, f"{v['id']}: bắn {v['projectile']} nhưng ammo = 0"))
        replaced = v["replaces"]
        if replaced and replaced not in unit_by_id:
            errors.append(Err(units_path, row.line, 1, f"{v['id']}: replaces trỏ tới đơn vị không tồn tại {replaced!r}"))

    for row in buildings:
        v = row.values
        for unit_id in v["trains"]:
            unit = unit_by_id.get(unit_id)
            if unit is None:
                errors.append(Err(buildings_path, row.line, 1, f"{v['id']}: trains trỏ tới đơn vị không tồn tại {unit_id!r}"))
                continue
            uv = unit.values
            if uv["era"] < v["era"]:
                errors.append(Err(buildings_path, row.line, 1, f"{v['id']}: công trình era {v['era']} luyện {unit_id} era {uv['era']} (đơn vị mở khóa trước công trình)"))
            if uv["faction"] and v["faction"] and uv["faction"] != v["faction"]:
                errors.append(Err(buildings_path, row.line, 1, f"{v['id']}: phe {v['faction']} luyện {unit_id} của phe {uv['faction']}"))
    return errors


def validate_dir(directory: Path) -> list[Err]:
    units_file = directory / "units.csv"
    buildings_file = directory / "buildings.csv"
    units, unit_errors = read_table(units_file, UNIT_FIELDS)
    buildings, building_errors = read_table(buildings_file, BUILDING_FIELDS)
    errors = unit_errors + building_errors
    if errors:
        return errors
    return validate_tables(units, buildings, units_file.as_posix(), buildings_file.as_posix())


def main(argv: list[str]) -> int:
    sys.stdout.reconfigure(encoding="utf-8")  # console Windows mặc định cp1252
    sys.stderr.reconfigure(encoding="utf-8")
    directory = Path(argv[1]) if len(argv) > 1 else Path("data/balance")
    errors = validate_dir(directory)
    for err in errors:
        print(err, file=sys.stderr)
    if errors:
        print(f"{len(errors)} lỗi dữ liệu", file=sys.stderr)
        return 1
    print(f"OK: {directory} hợp lệ")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
