"""Test cho tools/ci/version_guard.py (S0.T04-TC4)."""
from conftest import REPO
from version_guard import check

WORKFLOW = 'env:\n  GODOT_VERSION: "4.7.2"\njobs:\n  b:\n    container: barichello/godot-ci:{image}\n'
PROJECT = 'config/features=PackedStringArray("{minor}", "GL Compatibility")\n'


def make_repo(tmp_path, image="4.7.2", minor="4.7"):
    (tmp_path / ".github" / "workflows").mkdir(parents=True)
    (tmp_path / ".github" / "workflows" / "ci.yml").write_text(WORKFLOW.format(image=image), encoding="utf-8")
    (tmp_path / "project.godot").write_text(PROJECT.format(minor=minor), encoding="utf-8")
    return tmp_path


def test_repo_versions_are_consistent():
    assert check(REPO) == []


def test_matching_versions_pass(tmp_path):
    assert check(make_repo(tmp_path)) == []


def test_S0_T04_TC4_image_differs_from_godot_version(tmp_path):
    errors = check(make_repo(tmp_path, image="4.7.1"))
    assert any("không khớp nhau" in e for e in errors)


def test_project_minor_differs_from_workflow(tmp_path):
    errors = check(make_repo(tmp_path, minor="4.6"))
    assert any("project.godot ghi Godot 4.6" in e for e in errors)


def test_missing_workflows(tmp_path):
    assert check(tmp_path) == ["không tìm thấy workflow nào trong .github/workflows"]
