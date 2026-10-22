"""Test cho tools/balance/csv_to_tres.py (S1.T04)."""
from conftest import REPO
from csv_to_tres import sync

BALANCE = REPO / "data" / "balance"


def test_S1_T04_TC1_generates_one_file_per_row(tmp_path):
    problems = sync(BALANCE, tmp_path)
    units = list((tmp_path / "units").glob("unit_*.tres"))
    buildings = list((tmp_path / "buildings").glob("building_*.tres"))
    assert len(units) == 18 and len(buildings) == 21
    assert len(problems) == 39


def test_S1_T04_TC4_second_run_changes_nothing(tmp_path):
    sync(BALANCE, tmp_path)
    before = {p: p.read_bytes() for p in tmp_path.rglob("*.tres")}
    assert sync(BALANCE, tmp_path) == []
    assert before == {p: p.read_bytes() for p in tmp_path.rglob("*.tres")}


def test_output_matches_godot_resource_format(tmp_path):
    sync(BALANCE, tmp_path)
    text = (tmp_path / "units" / "unit_linh_giao.tres").read_text(encoding="utf-8")
    assert text.startswith('[gd_resource type="Resource" script_class="UnitDef" load_steps=2 format=3]')
    assert "cost = PackedFloat32Array(30, 10, 0, 0, 0, 0)" in text
    assert 'tags = PackedStringArray("infantry", "melee")' in text
    assert '&"cavalry": 2.0' in text
    house = (tmp_path / "buildings" / "building_nha.tres").read_text(encoding="utf-8")
    assert "growth = 1.05" in house
    assert "size = Vector2i(2, 2)" in house


def test_check_mode_reports_stale_and_extra_files(tmp_path):
    sync(BALANCE, tmp_path)
    (tmp_path / "units" / "unit_dan.tres").write_text("cũ", encoding="utf-8")
    (tmp_path / "units" / "unit_thua.tres").write_text("thừa", encoding="utf-8")
    problems = sync(BALANCE, tmp_path, check=True)
    assert "cũ: " + (tmp_path / "units" / "unit_dan.tres").as_posix() in problems
    assert "thừa: " + (tmp_path / "units" / "unit_thua.tres").as_posix() in problems
    assert (tmp_path / "units" / "unit_thua.tres").exists()  # --check không xóa


def test_committed_tres_files_are_up_to_date():
    assert sync(BALANCE, REPO / "data", check=True) == []


def test_every_exported_field_exists_in_gdscript_defs():
    """Cột CSV phải trùng tên biến @export trong scripts/defs/."""
    import re

    from balance_schema import BUILDING_FIELDS, UNIT_FIELDS

    for fields, script in ((UNIT_FIELDS, "unit_def.gd"), (BUILDING_FIELDS, "building_def.gd")):
        source = (REPO / "scripts" / "defs" / script).read_text(encoding="utf-8")
        exported = set(re.findall(r"@export var (\w+)", source))
        assert {f.name for f in fields} == exported, script
