"""Schema dùng chung cho csv_to_tres.py và validate.py (S1.T03, S1.T04).

Mỗi cột CSV trùng tên với biến `@export` của UnitDef / BuildingDef trong scripts/defs/.
"""
from __future__ import annotations

from dataclasses import dataclass
from typing import Any

# Thứ tự 6 tài nguyên: Lúa, Gỗ, Đá, Tiền, Sắt, Diêm tiêu (viết ASCII trong CSV)
RES_KEYS = ("L", "G", "DA", "T", "S", "DI")
FACTIONS = ("", "trinh", "nguyen", "npc")
DOMAINS = ("LAND", "WATER")
ERAS = (1, 2, 3)  # 3 để dành cho sau phát hành
PROJECTILES = ("", "ball", "arrow", "shell", "ship_shot")
AMMO_PROJECTILES = ("ball", "shell", "ship_shot")


class ParseError(ValueError):
    """Giá trị trong ô CSV sai định dạng."""


@dataclass(frozen=True)
class Field:
    name: str
    kind: str
    required: bool = False
    default: Any = None
    minimum: float | None = 0.0
    maximum: float | None = None


ZERO_RES = (0.0,) * len(RES_KEYS)

UNIT_FIELDS: tuple[Field, ...] = (
    Field("id", "id", required=True),
    Field("name_key", "str", required=True),
    Field("faction", "faction", default=""),
    Field("era", "int", required=True, minimum=1, maximum=3),
    Field("cost", "res", default=ZERO_RES),
    Field("hp", "float", required=True, minimum=1),
    Field("armor", "float", default=0.0),
    Field("attack", "float", default=0.0),
    Field("range", "float", default=0.0),
    Field("min_range", "float", default=0.0),
    Field("reload_s", "float", default=0.0),
    Field("accuracy", "float", default=1.0, maximum=1.0),
    Field("projectile", "projectile", default=""),
    Field("splash_px", "float", default=0.0),
    Field("speed", "float", required=True),
    Field("sight", "float", default=220.0),
    Field("radius", "float", default=8.0, minimum=1),
    Field("pop", "int", default=1),
    Field("train_s", "float", default=0.0),
    Field("upkeep", "res", default=ZERO_RES),
    Field("ammo", "res", default=ZERO_RES),
    Field("tags", "list", default=()),
    Field("bonus", "bonus", default={}),
    Field("rank", "int", default=5),
    Field("domain", "domain", default="LAND"),
    Field("capturable", "bool", default=False),
    Field("can_damage_military", "bool", default=False),
    Field("replaces", "str", default=""),
)

BUILDING_FIELDS: tuple[Field, ...] = (
    Field("id", "id", required=True),
    Field("name_key", "str", required=True),
    Field("faction", "faction", default=""),
    Field("era", "int", required=True, minimum=1, maximum=3),
    Field("cost", "res", default=ZERO_RES),
    Field("growth", "float", default=1.0, minimum=1.0),
    Field("hp", "float", required=True, minimum=1),
    Field("armor", "float", default=0.0),
    Field("size", "size", required=True),
    Field("build_s", "float", default=0.0),
    Field("pop_bonus", "int", default=0),
    Field("military", "bool", default=False),
    Field("capturable", "bool", default=False),
    Field("max_count", "int", default=0),
    Field("coast_only", "bool", default=False),
    Field("slots", "int", default=0),
    Field("territory_radius", "int", default=0),
    Field("trains", "list", default=()),
    Field("researches", "list", default=()),
    Field("dropoff", "reslist", default=()),
    Field("wall", "bool", default=False),
    Field("gate", "bool", default=False),
    Field("walk_inf_owner", "bool", default=False),
    Field("attack", "float", default=0.0),
    Field("range", "float", default=0.0),
    Field("reload_s", "float", default=0.0),
    Field("anti_capture_radius", "int", default=0),
)


def parse_bool(raw: str) -> bool:
    value = raw.strip().lower()
    if value in ("true", "1"):
        return True
    if value in ("false", "0"):
        return False
    raise ParseError(f"không phải true/false: {raw!r}")


def parse_res(raw: str) -> tuple[float, ...]:
    """'L:30|G:10' -> (30, 10, 0, 0, 0, 0)."""
    values = dict.fromkeys(RES_KEYS, 0.0)
    if raw.strip():
        for part in raw.split("|"):
            key, sep, num = part.partition(":")
            key = key.strip()
            if not sep or key not in values:
                raise ParseError(f"khóa tài nguyên sai {key!r}, cần một trong {RES_KEYS}")
            try:
                values[key] = float(num)
            except ValueError as exc:
                raise ParseError(f"số sai trong {part!r}") from exc
    return tuple(values[k] for k in RES_KEYS)


def parse_list(raw: str) -> tuple[str, ...]:
    return tuple(p.strip() for p in raw.split("|") if p.strip())


def parse_bonus(raw: str) -> dict[str, float]:
    """'cavalry:2.0|elephant:2.5' -> {'cavalry': 2.0, 'elephant': 2.5}."""
    result: dict[str, float] = {}
    for part in parse_list(raw):
        tag, sep, num = part.partition(":")
        if not sep or not tag.strip():
            raise ParseError(f"bonus sai định dạng: {part!r}")
        try:
            result[tag.strip()] = float(num)
        except ValueError as exc:
            raise ParseError(f"số sai trong bonus {part!r}") from exc
    return result


def parse_size(raw: str) -> tuple[int, int]:
    """'4x3' -> (4, 3)."""
    left, sep, right = raw.lower().partition("x")
    if not sep:
        raise ParseError(f"kích thước phải dạng WxH: {raw!r}")
    try:
        width, height = int(left), int(right)
    except ValueError as exc:
        raise ParseError(f"kích thước sai: {raw!r}") from exc
    if width < 1 or height < 1:
        raise ParseError(f"kích thước phải >= 1: {raw!r}")
    return width, height


def parse_value(field: Field, raw: str) -> Any:
    """Chuyển chuỗi CSV thành giá trị Python. Ô trống dùng giá trị mặc định."""
    text = raw.strip()
    if text == "":
        if field.required:
            raise ParseError("ô bắt buộc đang để trống")
        return field.default
    kind = field.kind
    try:
        if kind in ("id", "str"):
            value: Any = text
        elif kind == "faction":
            if text not in FACTIONS:
                raise ParseError(f"phe không hợp lệ {text!r}, cần một trong {FACTIONS[1:]}")
            value = text
        elif kind == "domain":
            if text not in DOMAINS:
                raise ParseError(f"domain không hợp lệ {text!r}, cần một trong {DOMAINS}")
            value = text
        elif kind == "projectile":
            if text not in PROJECTILES:
                raise ParseError(f"projectile không hợp lệ {text!r}")
            value = text
        elif kind == "int":
            value = int(text)
        elif kind == "float":
            value = float(text)
        elif kind == "bool":
            value = parse_bool(text)
        elif kind == "res":
            value = parse_res(text)
        elif kind == "list":
            value = parse_list(text)
        elif kind == "reslist":
            value = parse_list(text)
            bad = [v for v in value if v not in RES_KEYS]
            if bad:
                raise ParseError(f"khóa tài nguyên sai {bad}")
        elif kind == "bonus":
            value = parse_bonus(text)
        elif kind == "size":
            value = parse_size(text)
        else:
            raise ParseError(f"kind không biết: {kind}")
    except ValueError as exc:
        if isinstance(exc, ParseError):
            raise
        raise ParseError(f"không đọc được {text!r} thành {kind}") from exc

    _check_range(field, value)
    return value


def _check_range(field: Field, value: Any) -> None:
    numbers: list[float] = []
    if field.kind in ("int", "float"):
        numbers = [float(value)]
    elif field.kind == "res":
        numbers = list(value)
    elif field.kind == "bonus":
        numbers = list(value.values())
    for number in numbers:
        if field.minimum is not None and number < field.minimum:
            raise ParseError(f"{number} nhỏ hơn mức tối thiểu {field.minimum}")
        if field.maximum is not None and number > field.maximum:
            raise ParseError(f"{number} lớn hơn mức tối đa {field.maximum}")
