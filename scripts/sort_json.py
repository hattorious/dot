# ABOUTME: Recursively sorts JSON/JSONC file keys in-place to reduce git diff noise.
# ABOUTME: Accepts one or more file paths as arguments. Exits 1 on parse errors.
# /// script
# dependencies = ["commentjson"]
# ///

import sys
import json
import commentjson


def sort_recursive(obj):
    if isinstance(obj, dict):
        return {k: sort_recursive(obj[k]) for k in sorted(obj)}
    if isinstance(obj, list):
        return [sort_recursive(item) for item in obj]
    return obj


def detect_indent(content: str) -> int:
    raise NotImplementedError


def sort_file(path: str) -> None:
    raise NotImplementedError


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: sort_json.py <file> [file ...]", file=sys.stderr)
        sys.exit(1)
    for path in sys.argv[1:]:
        sort_file(path)
