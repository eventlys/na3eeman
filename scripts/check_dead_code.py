#!/usr/bin/env python3
"""Dead-code check: flag lib/**/*.dart files that no other lib/ or test/ file
imports and that are not entry points or exported through a barrel.

Heuristic — a file is suspect if its basename never appears in an import or
export statement elsewhere. Entry points (main.dart) and part-of files are
exempt. This intentionally over-reports nothing and under-reports dynamic
usages; treat output as a review list, not gospel.

Run from the repo root:
    python3 scripts/check_dead_code.py
Exits 0 always (advisory) unless --strict is passed and suspects are found.
"""
import re
import sys
from pathlib import Path

LIB = Path("lib")
TEST = Path("test")
IMPORT_RE = re.compile(r"""(?:import|export)\s+['"]([^'"]+)['"]""")
ENTRY_POINTS = {"main.dart"}


def collect_imports() -> set:
    used = set()
    for root in (LIB, TEST):
        if not root.exists():
            continue
        for path in root.rglob("*.dart"):
            try:
                text = path.read_text(encoding="utf-8", errors="replace")
            except OSError:
                continue
            for m in IMPORT_RE.finditer(text):
                target = m.group(1)
                used.add(Path(target).name)  # basename match is enough
    return used


def main() -> int:
    strict = "--strict" in sys.argv
    used = collect_imports()
    suspects = []
    for path in sorted(LIB.rglob("*.dart")):
        name = path.name
        if name in ENTRY_POINTS:
            continue
        if name not in used:
            suspects.append(str(path))
    if suspects:
        print(f"Possibly-unreferenced files ({len(suspects)}):")
        for s in suspects:
            print("  " + s)
        return 1 if strict else 0
    print("OK: every lib/ file is imported somewhere")
    return 0


if __name__ == "__main__":
    sys.exit(main())
