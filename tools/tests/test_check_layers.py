"""Test cho tools/ci/check_layers.py (S1.T01)."""
from check_layers import check
from conftest import REPO


def make_tree(tmp_path, files):
    scripts = tmp_path / "scripts"
    for rel, content in files.items():
        path = scripts / rel
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content, encoding="utf-8", newline="\n")
    return scripts


def test_repo_scripts_follow_layer_rules():
    assert check(REPO / "scripts") == []


def test_S1_T01_TC3_drawing_in_sim_is_reported_with_file_and_line(tmp_path):
    scripts = make_tree(tmp_path, {"sim/combat/damage.gd": "extends RefCounted\n\nfunc f() -> void:\n\tqueue_redraw()\n"})
    errors = check(scripts)
    assert len(errors) == 1
    assert errors[0].endswith("damage.gd:4:1: lớp 'sim' không được gọi API vẽ")


def test_render_may_draw(tmp_path):
    scripts = make_tree(tmp_path, {"render/view.gd": "extends Node2D\n\nfunc _draw() -> void:\n\tdraw_circle(Vector2.ZERO, 4.0, Color.RED)\n"})
    assert check(scripts) == []


def test_sim_must_not_use_render_class(tmp_path):
    scripts = make_tree(
        tmp_path,
        {
            "render/unit_view.gd": "class_name UnitView\nextends Node2D\n",
            "sim/economy/gather.gd": "extends RefCounted\n\nvar view: UnitView\n",
        },
    )
    errors = check(scripts)
    assert any("không được dùng UnitView (lớp 'render')" in e for e in errors)


def test_resource_path_across_layers_is_reported(tmp_path):
    scripts = make_tree(tmp_path, {"core/pool.gd": 'extends RefCounted\n\nconst UI := preload("res://scripts/ui/hud.gd")\n'})
    assert any("không được dùng lớp 'ui'" in e for e in check(scripts))


def test_comments_and_strings_are_ignored(tmp_path):
    scripts = make_tree(
        tmp_path,
        {
            "render/unit_view.gd": "class_name UnitView\nextends Node2D\n",
            "sim/a.gd": '# UnitView chỉ nhắc trong comment\nextends RefCounted\n\nvar s := "UnitView draw_circle(x)"\n',
        },
    )
    assert check(scripts) == []
