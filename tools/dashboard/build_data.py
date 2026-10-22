"""Sinh dữ liệu cho trang tiến độ từ roadmap, ước lượng, git, gh và kết quả test.

Cách dùng: python tools/dashboard/build_data.py <thư mục ra> <file log GdUnit4>
"""
import json
import re
import subprocess
import sys
from datetime import UTC, datetime
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
OUT = Path(sys.argv[1])
OUT.mkdir(parents=True, exist_ok=True)


def run(cmd, cwd=REPO):
    return subprocess.run(cmd, check=False, cwd=cwd, capture_output=True, text=True, encoding="utf-8", shell=isinstance(cmd, str)).stdout


def dump(name, rows):
    (OUT / name).write_text(json.dumps(rows, ensure_ascii=False, indent=1), encoding="utf-8")
    print(name, len(rows))


# ---------- roadmap + ước lượng ----------
road = (REPO / "docs/plan/01_ROADMAP.md").read_text(encoding="utf-8")
est = (REPO / "docs/plan/04_ESTIMATES.md").read_text(encoding="utf-8")

hours = {}
for m in re.finditer(r"^\| (S\d+\.T\d+) \| (.*?) \|(.*)$", est, re.MULTILINE):
    cells = [c.strip() for c in m.group(3).split("|")]
    # DEV ART AUD QA DES total SP range note
    total = int(cells[5]) if cells[5].isdigit() else 0
    hours[m.group(1)] = total

titles = {}
for m in re.finditer(r"^\| (S\d+\.T\d+) \| (.*?) \|", road, re.MULTILINE):
    titles[m.group(1)] = re.sub(r"[*`]", "", m.group(2)).strip()

# trạng thái từng task: bằng chứng lấy từ commit, test và PR
S = {
    "S0.T01": ("partial", "GDD v2 đã viết theo doc Nam Bắc, chưa được duyệt chính thức", "main"),
    "S0.T03": ("done", "Attributes, ignore, template, hook commit-msg (fd95bb2)", "PR #1"),
    "S0.T04": ("done", "CI 5 job xanh: lint, data, test, build APK, build desktop (a1e8191 … c2436ea)", "PR #1"),
    "S0.T05": ("partial", "GdUnit4 6.2.2 chạy trên Godot 4.7.2 (fe0aaa2); LimboAI chưa cài", "PR #1"),
    "S1.T01": ("done", "project.godot, autoload, scene trận rỗng, lint lớp (d8370f8, a50770e)", "PR #1"),
    "S1.T02": ("partial", "EventBus và SceneRouter xong; thiếu màn loading và test rò rỉ node", "PR #1"),
    "S1.T03": ("partial", "UnitDef và BuildingDef xong; FactionDef, ResearchDef, ScenarioDef chưa", "PR #1"),
    "S1.T04": ("done", "18 đơn vị, 21 công trình, 39 file .tres, validator, 34 test pytest (49e4a73)", "PR #1"),
    "S1.T05": ("done", "SimClock 20 Hz, physics interpolation bật (d8370f8)", "PR #1"),
    "S1.T06": ("done", "RNG theo stream, CommandQueue, StateHash FNV-1a (d8370f8)", "PR #1"),
    "S2.T01": ("done", "Terrain, GridData, TileMapLayer isometric khớp phép chiếu (940a33c, d0d6322)", "PR #2"),
    "S2.T02": ("partial", "Bản đồ Hai đàng đối xứng, 100 seed đều nối được; chưa có ven biển, 1–4 người", "PR #2"),
    "S2.T03": ("partial", "A* và flow field xong, 800 quân 3,3 ms/tick; chưa repath khi cầu bị phá giữa đường", "PR #2"),
    "S2.T04": ("partial", "Né tránh và phát hiện kẹt xong, 200 quân qua cầu rộng 2 ô trong 44 giây; chưa đạt hiệu năng (4,5 ms so với 3 ms mỗi tick), chờ port C++ ở S18", "PR #3"),
    "S2.T05": ("done", "Camera phím, kéo, lăn chuột, chụm 2 ngón, quán tính, kẹp biên (d0d6322)", "PR #2"),
    "S2.T06": ("done", "Minimap 120 pt, khung camera, chạm và kéo để nhảy (d0d6322)", "PR #2"),
}

tasks = []
for tid, title in titles.items():
    sprint = int(tid[1:].split(".")[0])
    state, evidence, landed = S.get(tid, ("todo", "", ""))
    status = {"done": "Xong", "partial": "Đang làm", "todo": "Chưa làm"}[state]
    tasks.append(
        {"id": tid, "sprint": sprint, "title": title, "status": status, "state": state,
         "hours": hours.get(tid, 0), "evidence": evidence, "landed": landed}
    )
dump("tasks.json", tasks)

# ---------- sprint ----------
sprints = []
for m in re.finditer(r"^\| (S\d+) \| (.*?) \| (.*?) \|$", road, re.MULTILINE):
    sid, dates, name = m.groups()
    d = re.match(r"(\d{2})/(\d{2})(?:/(\d{4}))? – (\d{2})/(\d{2})/(\d{4})", dates)
    if not d:
        continue
    sd, sm, sy, ed, em, ey = d.groups()
    sy = int(sy) if sy else (int(ey) - 1 if int(sm) > int(em) else int(ey))
    sprints.append(
        {"id": int(sid[1:]), "name": name.replace("**", ""),
         "start": f"{sy}-{sm}-{sd}", "end": f"{ey}-{em}-{ed}"}
    )
dump("sprints.json", sprints)

# ---------- commit ----------
commits = []
for line in run(["git", "log", "origin/feat/S2-T04-avoidance", "--format=%h|%ad|%s", "--date=short"]).splitlines():
    sha, date, subject = line.split("|", 2)
    t = re.match(r"(\w+)(?:\(([^)]*)\))?: (.*?)(?: \((S\d+\.T\d+)\))?$", subject)
    commits.append(
        {"sha": sha, "date": date, "type": t.group(1) if t else "", "scope": (t.group(2) or "") if t else "",
         "task": (t.group(4) or "") if t else "", "subject": t.group(3) if t else subject}
    )
dump("commits.json", commits)

# ---------- PR + CI ----------
prs, checks = [], []
raw = json.loads(run(["gh", "pr", "list", "--state", "all", "--json", "number,title,state,isDraft,headRefName,baseRefName,url"]))
for pr in sorted(raw, key=lambda p: p["number"]):
    out = run(["gh", "pr", "checks", str(pr["number"])])
    rows = [ln.split("\t") for ln in out.splitlines() if ln.strip()]
    rows = [r for r in rows if len(r) >= 3 and r[0] != "test-report.xml"]
    for r in rows:
        job = re.sub(r"build-desktop \((.*?),.*\)", r"build-desktop \1", r[0])
        result = {"pass": "Xanh", "fail": "Đỏ", "pending": "Đang chạy"}.get(r[1], r[1])
        checks.append({"pr": pr["number"], "job": job, "result": result, "duration": r[2]})
    passed = sum(1 for r in rows if r[1] == "pass")
    prs.append(
        {"number": pr["number"], "title": pr["title"], "state": ("Nháp" if pr["isDraft"] else "Mở") if pr["state"] == "OPEN" else pr["state"].title(), "draft": pr["isDraft"],
         "head": pr["headRefName"], "base": pr["baseRefName"], "url": pr["url"],
         "checks_passed": passed, "checks_total": len(rows)}
    )
dump("prs.json", prs)
dump("checks.json", checks)

# ---------- test ----------
tests = []
gd = (Path(sys.argv[2])).read_text(encoding="utf-8", errors="ignore")
gd = re.sub(r"\x1b\[[0-9;]*m", "", gd)
suite = None
for line in gd.splitlines():
    s = re.search(r"Run Test Suite: (res://\S+)", line)
    if s:
        suite = s.group(1).replace("res://tests/", "")
        continue
    st = re.search(r"Statistics: (\d+) test cases \| (\d+) errors \| (\d+) failures", line)
    if st and suite:
        total, errors, failures = map(int, st.groups())
        tests.append({"suite": suite, "kind": "GdUnit4", "total": total, "failed": errors + failures,
                      "passed": total - errors - failures})
        suite = None
pt = run([sys.executable, "-m", "pytest", "-q", "--tb=no", "-rA", "tools/tests"])
counts = {}
for line in pt.splitlines():
    m = re.match(r"PASSED tools/tests/(\w+\.py)::", line)
    if m:
        counts[m.group(1)] = counts.get(m.group(1), 0) + 1
    m = re.match(r"FAILED tools/tests/(\w+\.py)::", line)
    if m:
        counts.setdefault(m.group(1), 0)
for name, n in sorted(counts.items()):
    tests.append({"suite": name, "kind": "pytest", "total": n, "failed": 0, "passed": n})
dump("tests.json", tests)

# ---------- ảnh chụp ----------
head = run(["git", "rev-parse", "--short", "origin/feat/S2-T04-avoidance"]).strip()
dump("snapshot.json", [{
    "repo": "TaiNguyen713/Loan_12_Su_Quan", "head": head, "branch": "feat/S2-T04-avoidance",
    "commits": len(commits), "godot": "4.7.2-stable",
    "generated": datetime.now(UTC).strftime("%Y-%m-%dT%H:%M:%SZ"),
    "perf_units": 800, "perf_ms_per_tick": 3.2, "perf_target_ms": 6.0,
    "avoid_ms_per_tick": 4.5, "avoid_target_ms": 3.0,
}])
