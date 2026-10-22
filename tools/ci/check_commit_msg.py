"""Kiểm tra dòng đầu của commit message theo Conventional Commits + mã task (S0.T03)."""
from __future__ import annotations

import re
import sys
from pathlib import Path

TYPES = "feat|fix|docs|test|refactor|perf|chore|ci"
TASK = r"S\d{1,2}\.T\d{2}"
# docs và chore không bắt buộc mã task
WITH_TASK = re.compile(rf"^({TYPES})(\([a-z0-9_/-]+\))?: .+ \({TASK}\)$")
WITHOUT_TASK = re.compile(r"^(docs|chore)(\([a-z0-9_/-]+\))?: .+$")
SKIP_PREFIXES = ("Merge ", "Revert ", "fixup!", "squash!")


def check(first_line: str) -> str | None:
    """Trả về None nếu hợp lệ, ngược lại là thông báo lỗi."""
    line = first_line.strip()
    if line.startswith(SKIP_PREFIXES):
        return None
    if WITH_TASK.match(line) or WITHOUT_TASK.match(line):
        return None
    return (
        f"Commit message không hợp lệ: {line!r}\n"
        "Dạng đúng: <type>(<scope>): <mô tả> (Sx.Tyy)\n"
        f"type: {TYPES.replace('|', ', ')}; docs/chore có thể bỏ mã task."
    )


def main(argv: list[str]) -> int:
    sys.stdout.reconfigure(encoding="utf-8")  # console Windows mặc định cp1252
    sys.stderr.reconfigure(encoding="utf-8")
    if len(argv) != 2:
        print("Cách dùng: check_commit_msg.py <file-commit-msg>", file=sys.stderr)
        return 2
    text = Path(argv[1]).read_text(encoding="utf-8")
    first = next((ln for ln in text.splitlines() if ln.strip() and not ln.startswith("#")), "")
    error = check(first)
    if error:
        print(error, file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
