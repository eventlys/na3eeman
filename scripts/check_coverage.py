#!/usr/bin/env python3
"""Coverage ratchet: fail if line coverage drops below the recorded floor.

The floor is stored in scripts/coverage_floor.txt (a single number, e.g. 12.8).
Raise it deliberately as coverage improves; never lower it to make CI pass.

Run from the repo root after `flutter test --coverage`:
    python3 scripts/check_coverage.py
"""
import sys
from pathlib import Path

LCOV = Path("coverage/lcov.info")
FLOOR_FILE = Path("scripts/coverage_floor.txt")


def current_coverage() -> float:
    if not LCOV.exists():
        print(f"ERROR: {LCOV} not found — run `flutter test --coverage` first")
        sys.exit(2)
    lines_found = 0
    lines_hit = 0
    for line in LCOV.read_text(encoding="utf-8", errors="replace").splitlines():
        if line.startswith("LF:"):
            lines_found += int(line[3:])
        elif line.startswith("LH:"):
            lines_hit += int(line[3:])
    if lines_found == 0:
        return 0.0
    return 100.0 * lines_hit / lines_found


def main() -> int:
    pct = current_coverage()
    if not FLOOR_FILE.exists():
        print(f"ERROR: floor file {FLOOR_FILE} missing")
        return 2
    floor = float(FLOOR_FILE.read_text().strip())
    print(f"Coverage: {pct:.2f}%  (floor: {floor:.2f}%)")
    if pct < floor:
        print(f"FAIL: coverage {pct:.2f}% dropped below floor {floor:.2f}%")
        return 1
    print("OK: coverage at or above floor")
    return 0


if __name__ == "__main__":
    sys.exit(main())
