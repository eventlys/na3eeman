#!/usr/bin/env python3
"""Architecture lint: enforce the layering rule that the UI layer
(lib/Packages/**) must not import the API or repository layers directly.

Allowed under lib/Packages/: Providers, Helpers, core/theme, core/widgets, etc.
Forbidden under lib/Packages/: Services/api/... and Services/repositories/...

Run from the repo root:
    python3 scripts/check_architecture.py
Exits 1 (with offending imports listed) if any violation is found.
"""
import re
import sys
from pathlib import Path

PACKAGES = Path("lib/Packages")
FORBIDDEN = re.compile(
    r"""import\s+['"][^'"]*Services/(api|repositories)/[^'"]*['"]"""
)


def main() -> int:
    violations = []
    for path in sorted(PACKAGES.rglob("*.dart")):
        try:
            text = path.read_text(encoding="utf-8")
        except OSError:
            continue
        for lineno, line in enumerate(text.splitlines(), 1):
            if FORBIDDEN.search(line):
                violations.append(f"{path}:{lineno}: {line.strip()}")
    if violations:
        print("Architecture violations (UI importing api/repository layers):")
        for v in violations:
            print("  " + v)
        print(
            f"\n{len(violations)} violation(s). Route data access through a "
            "Provider instead."
        )
        return 1
    print("OK: no api/repository imports under lib/Packages/")
    return 0


if __name__ == "__main__":
    sys.exit(main())
