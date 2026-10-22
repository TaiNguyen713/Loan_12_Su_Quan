"""Đảm bảo phiên bản Godot khớp nhau ở mọi nơi khai báo (S0.T04, xem docs/plan/05_VERSIONS.md)."""
from __future__ import annotations

import re
import sys
from pathlib import Path

WORKFLOW_GODOT = re.compile(r"GODOT_VERSION:\s*[\"']?(\d+\.\d+(?:\.\d+)?)[\"']?")
WORKFLOW_IMAGE = re.compile(r"barichello/godot-ci:(\d+\.\d+(?:\.\d+)?)")
PROJECT_FEATURES = re.compile(r"config/features=PackedStringArray\(\s*\"(\d+\.\d+)\"")
PLUGIN_VERSION = re.compile(r'^version="([^"]+)"', re.MULTILINE)


def check(root: Path) -> list[str]:
    errors: list[str] = []
    workflows = sorted((root / ".github" / "workflows").glob("*.yml"))
    if not workflows:
        return ["không tìm thấy workflow nào trong .github/workflows"]

    versions: dict[str, str] = {}
    for workflow in workflows:
        text = workflow.read_text(encoding="utf-8")
        for match in WORKFLOW_GODOT.finditer(text):
            versions[f"{workflow.name}: GODOT_VERSION"] = match.group(1)
        for match in WORKFLOW_IMAGE.finditer(text):
            versions[f"{workflow.name}: image godot-ci"] = match.group(1)
    if not versions:
        errors.append("workflow không khai báo GODOT_VERSION")
    elif len(set(versions.values())) > 1:
        detail = ", ".join(f"{k}={v}" for k, v in sorted(versions.items()))
        errors.append(f"phiên bản Godot trong workflow không khớp nhau: {detail}")

    project = root / "project.godot"
    if project.exists() and versions:
        match = PROJECT_FEATURES.search(project.read_text(encoding="utf-8"))
        if not match:
            errors.append("project.godot thiếu config/features với phiên bản Godot")
        else:
            workflow_version = next(iter(versions.values()))
            workflow_minor = ".".join(workflow_version.split(".")[:2])
            if match.group(1) != workflow_minor:
                errors.append(
                    f"project.godot ghi Godot {match.group(1)} nhưng workflow dùng {workflow_version}"
                )

    for plugin in sorted((root / "addons").glob("*/plugin.cfg")):
        readme = root / "addons" / "README.md"
        if not readme.exists():
            errors.append("có addon nhưng thiếu addons/README.md ghi phiên bản đã khóa")
            break
        match = PLUGIN_VERSION.search(plugin.read_text(encoding="utf-8"))
        if match and match.group(1).lstrip("v") not in readme.read_text(encoding="utf-8"):
            errors.append(f"{plugin.parent.name} {match.group(1)} chưa được ghi trong addons/README.md")
    return errors


def main(argv: list[str]) -> int:
    sys.stdout.reconfigure(encoding="utf-8")
    sys.stderr.reconfigure(encoding="utf-8")
    root = Path(argv[1]) if len(argv) > 1 else Path(".")
    errors = check(root)
    for error in errors:
        print(error, file=sys.stderr)
    if errors:
        return 1
    print("OK: phiên bản Godot khớp nhau")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
