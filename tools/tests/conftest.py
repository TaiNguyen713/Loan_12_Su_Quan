"""Cho phép pytest import trực tiếp các script trong tools/."""
import sys
from pathlib import Path

TOOLS = Path(__file__).resolve().parents[1]
for sub in ("balance", "data_validator", "ci"):
    sys.path.insert(0, str(TOOLS / sub))

REPO = TOOLS.parent
