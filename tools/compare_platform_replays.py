#!/usr/bin/env python3
"""Compare normalized Golden Replay outputs from Windows and Linux CI."""

from __future__ import annotations

import json
import math
import sys
from pathlib import Path
from typing import Any

GRID = 0.0001


def normalize(value: Any) -> Any:
    if isinstance(value, dict):
        return {str(key): normalize(value[key]) for key in sorted(value)}
    if isinstance(value, list):
        return [normalize(item) for item in value]
    if isinstance(value, bool) or value is None or isinstance(value, str):
        return value
    if isinstance(value, (int, float)):
        number = float(value)
        if not math.isfinite(number):
            return "__NON_FINITE__"
        return round(number / GRID) * GRID
    return value


def first_difference(left: Any, right: Any, path: str = "$") -> dict[str, Any] | None:
    if type(left) is not type(right):
        return {"path": path, "reason": "type", "left": left, "right": right}
    if isinstance(left, dict):
        for key in sorted(set(left) | set(right)):
            child = f"{path}.{key}"
            if key not in left or key not in right:
                return {"path": child, "reason": "missing", "left": left.get(key), "right": right.get(key)}
            difference = first_difference(left[key], right[key], child)
            if difference:
                return difference
        return None
    if isinstance(left, list):
        if len(left) != len(right):
            return {"path": path, "reason": "length", "left": len(left), "right": len(right)}
        for index, (left_item, right_item) in enumerate(zip(left, right)):
            difference = first_difference(left_item, right_item, f"{path}[{index}]")
            if difference:
                return difference
        return None
    if left != right:
        return {"path": path, "reason": "value", "left": left, "right": right}
    return None


def comparable(document: dict[str, Any]) -> dict[str, Any]:
    return {
        "status": document.get("status"),
        "case_count": document.get("case_count"),
        "coverage": document.get("coverage"),
        "cases": document.get("cases"),
        "failures": document.get("failures"),
    }


def main() -> int:
    if len(sys.argv) != 4:
        print("usage: compare_platform_replays.py WINDOWS_JSON LINUX_JSON OUTPUT_JSON", file=sys.stderr)
        return 2
    windows_path, linux_path, output_path = map(Path, sys.argv[1:])
    windows = normalize(comparable(json.loads(windows_path.read_text(encoding="utf-8"))))
    linux = normalize(comparable(json.loads(linux_path.read_text(encoding="utf-8"))))
    difference = first_difference(windows, linux)
    result = {
        "status": "passed" if difference is None else "failed",
        "windows": str(windows_path),
        "linux": str(linux_path),
        "difference": difference,
    }
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(json.dumps(result, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(result, ensure_ascii=False))
    return 0 if difference is None else 1


if __name__ == "__main__":
    raise SystemExit(main())
