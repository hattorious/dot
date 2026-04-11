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
    for line in content.splitlines():
        stripped = line.lstrip(" ")
        if stripped and line != stripped:
            return len(line) - len(stripped)
    return 2


def sort_file(path: str) -> None:
    try:
        with open(path, encoding="utf-8") as f:
            content = f.read()
    except OSError as e:
        print(f"Error reading {path}: {e}", file=sys.stderr)
        sys.exit(1)

    indent = detect_indent(content)
    has_trailing_newline = content.endswith("\n")

    try:
        data = commentjson.loads(content)
    except Exception as e:
        print(f"Error parsing {path}: {e}", file=sys.stderr)
        sys.exit(1)

    sorted_data = sort_recursive(data)
    result = json.dumps(sorted_data, indent=indent, ensure_ascii=False)

    if has_trailing_newline:
        result += "\n"

    with open(path, "w", encoding="utf-8") as f:
        f.write(result)


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: sort_json.py <file> [file ...]", file=sys.stderr)
        sys.exit(1)
    for path in sys.argv[1:]:
        sort_file(path)
