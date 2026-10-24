#!/usr/bin/env python3
"""Locale parity check: en-US.json and ar-EG.json must have identical key sets.

Exit 0 if in parity, 1 (with a diff report) otherwise. Also validates that both
files are well-formed JSON. Run from the repo root:
    python3 scripts/check_locale_parity.py
"""
import json
import sys
from pathlib import Path

LANG_DIR = Path("assets/Lang")
LOCALES = ["en-US.json", "ar-EG.json"]


def load_keys(path: Path):
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except (json.JSONDecodeError, FileNotFoundError) as exc:
        print(f"ERROR: {path} is not valid/readable JSON: {exc}")
        sys.exit(2)
    if not isinstance(data, dict):
        print(f"ERROR: {path} root must be a JSON object")
        sys.exit(2)
    return set(data.keys())


def main() -> int:
    key_sets = {loc: load_keys(LANG_DIR / loc) for loc in LOCALES}
    reference = LOCALES[0]
    ok = True
    for other in LOCALES[1:]:
        only_ref = sorted(key_sets[reference] - key_sets[other])
        only_other = sorted(key_sets[other] - key_sets[reference])
        if only_ref or only_other:
            ok = False
            print(f"Locale drift between {reference} and {other}:")
            for k in only_ref:
                print(f"  missing in {other}: {k}")
            for k in only_other:
                print(f"  missing in {reference}: {k}")
    if ok:
        counts = {loc: len(keys) for loc, keys in key_sets.items()}
        print(f"OK: locales in parity {counts}")
        return 0
    return 1


if __name__ == "__main__":
    sys.exit(main())
