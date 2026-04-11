# JSON Sorting Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a `make sort-json` target and pre-commit hook that recursively sorts all JSON/JSONC file keys to reduce git diff noise.

**Architecture:** A PEP 723 Python script (`scripts/sort_json.py`) is the single sorting engine — both the Makefile target (via `fd`) and the pre-commit hook invoke it directly. `commentjson` handles JSONC parsing; note that comments are stripped on output (this is acceptable since tools like Zed rewrite their config files anyway).

**Tech Stack:** Python 3.11+, uv (PEP 723 inline deps), commentjson, fd, pre-commit

---

## File Map

| Action | Path | Purpose |
|--------|------|---------|
| Create | `scripts/sort_json.py` | Sorting engine: parse, sort, write in-place |
| Create | `pyproject.toml` | Enables `uv run pytest` for test suite |
| Create | `tests/conftest.py` | Adds `scripts/` to sys.path for unit tests |
| Create | `tests/unit/test_sort_recursive.py` | Unit tests for recursive sort logic |
| Create | `tests/unit/test_detect_indent.py` | Unit tests for indent detection |
| Create | `tests/integration/test_sort_file.py` | Integration tests for file I/O + parsing |
| Create | `tests/e2e/test_cli.py` | End-to-end CLI tests via subprocess |
| Modify | `Makefile` | Add `sort-json` target |
| Modify | `Brewfile` | Add `fd` |
| Create | `.pre-commit-config.yaml` | Local pre-commit hook |

---

### Task 1: Create test infrastructure

**Files:**
- Create: `pyproject.toml`
- Create: `tests/conftest.py`
- Create: `tests/unit/__init__.py`
- Create: `tests/integration/__init__.py`
- Create: `tests/e2e/__init__.py`

- [ ] **Step 1: Create `pyproject.toml`**

```toml
[project]
name = "dot-scripts"
version = "0.1.0"
requires-python = ">=3.11"

[dependency-groups]
dev = [
    "pytest>=8",
    "commentjson>=1.9",
]
```

- [ ] **Step 2: Create `tests/conftest.py`**

```python
# ABOUTME: Pytest configuration — adds scripts/ to sys.path so unit tests can import sort_json.
# ABOUTME: Required because sort_json.py is not in a package.
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "scripts"))
```

- [ ] **Step 3: Create `__init__.py` files**

```bash
touch tests/__init__.py tests/unit/__init__.py tests/integration/__init__.py tests/e2e/__init__.py
```

- [ ] **Step 4: Verify test runner works**

```bash
uv run pytest --collect-only
```

Expected: `no tests ran` (0 errors, no files collected yet)

- [ ] **Step 5: Commit**

```bash
git add pyproject.toml tests/
git commit -m "chore(tests): add pytest infrastructure for json sorting"
```

---

### Task 2: Implement `sort_recursive` (TDD)

**Files:**
- Create: `scripts/sort_json.py` (stub)
- Create: `tests/unit/test_sort_recursive.py`

- [ ] **Step 1: Create stub `scripts/sort_json.py`**

```python
# ABOUTME: Recursively sorts JSON/JSONC file keys in-place to reduce git diff noise.
# ABOUTME: Accepts one or more file paths as arguments. Exits 1 on parse errors.
# /// script
# dependencies = ["commentjson"]
# ///

import sys
import json
import commentjson


def sort_recursive(obj):
    raise NotImplementedError


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
```

- [ ] **Step 2: Write failing tests for `sort_recursive`**

Create `tests/unit/test_sort_recursive.py`:

```python
# ABOUTME: Unit tests for the sort_recursive function in sort_json.py.
# ABOUTME: Covers dicts, nested dicts, arrays, and primitive values.
import pytest
from sort_json import sort_recursive


def test_sorts_top_level_keys():
    assert sort_recursive({"b": 1, "a": 2}) == {"a": 2, "b": 1}


def test_sorts_nested_dict_keys():
    result = sort_recursive({"b": {"d": 1, "c": 2}, "a": 3})
    assert result == {"a": 3, "b": {"c": 2, "d": 1}}


def test_preserves_array_order():
    assert sort_recursive({"a": [3, 1, 2]}) == {"a": [3, 1, 2]}


def test_sorts_dicts_nested_inside_arrays():
    result = sort_recursive([{"b": 1, "a": 2}])
    assert result == [{"a": 2, "b": 1}]


def test_leaves_strings_unchanged():
    assert sort_recursive("hello") == "hello"


def test_leaves_numbers_unchanged():
    assert sort_recursive(42) == 42


def test_leaves_none_unchanged():
    assert sort_recursive(None) is None


def test_leaves_booleans_unchanged():
    assert sort_recursive(True) is True


def test_empty_dict():
    assert sort_recursive({}) == {}


def test_empty_list():
    assert sort_recursive([]) == []
```

- [ ] **Step 3: Run tests to confirm they fail**

```bash
uv run pytest tests/unit/test_sort_recursive.py -v
```

Expected: `FAILED` — `NotImplementedError`

- [ ] **Step 4: Implement `sort_recursive` in `scripts/sort_json.py`**

Replace the stub:

```python
def sort_recursive(obj):
    if isinstance(obj, dict):
        return {k: sort_recursive(obj[k]) for k in sorted(obj)}
    if isinstance(obj, list):
        return [sort_recursive(item) for item in obj]
    return obj
```

- [ ] **Step 5: Run tests to confirm they pass**

```bash
uv run pytest tests/unit/test_sort_recursive.py -v
```

Expected: all `PASSED`

- [ ] **Step 6: Commit**

```bash
git add scripts/sort_json.py tests/unit/test_sort_recursive.py
git commit -m "feat(scripts): implement sort_recursive for json key sorting"
```

---

### Task 3: Implement `detect_indent` (TDD)

**Files:**
- Modify: `scripts/sort_json.py`
- Create: `tests/unit/test_detect_indent.py`

- [ ] **Step 1: Write failing tests**

Create `tests/unit/test_detect_indent.py`:

```python
# ABOUTME: Unit tests for detect_indent function in sort_json.py.
# ABOUTME: Covers 2-space, 4-space indent detection and the default fallback.
from sort_json import detect_indent


def test_detects_two_space_indent():
    content = '{\n  "key": "value"\n}'
    assert detect_indent(content) == 2


def test_detects_four_space_indent():
    content = '{\n    "key": "value"\n}'
    assert detect_indent(content) == 4


def test_defaults_to_two_spaces_when_no_indent():
    content = '{"key": "value"}'
    assert detect_indent(content) == 2


def test_ignores_blank_lines():
    content = '{\n\n  "key": "value"\n}'
    assert detect_indent(content) == 2


def test_detects_indent_from_first_indented_line():
    content = '{\n  "a": {\n    "b": 1\n  }\n}'
    assert detect_indent(content) == 2
```

- [ ] **Step 2: Run tests to confirm they fail**

```bash
uv run pytest tests/unit/test_detect_indent.py -v
```

Expected: `FAILED` — `NotImplementedError`

- [ ] **Step 3: Implement `detect_indent` in `scripts/sort_json.py`**

Replace the stub:

```python
def detect_indent(content: str) -> int:
    for line in content.splitlines():
        stripped = line.lstrip(" ")
        if stripped and line != stripped:
            return len(line) - len(stripped)
    return 2
```

- [ ] **Step 4: Run tests to confirm they pass**

```bash
uv run pytest tests/unit/test_detect_indent.py -v
```

Expected: all `PASSED`

- [ ] **Step 5: Commit**

```bash
git add scripts/sort_json.py tests/unit/test_detect_indent.py
git commit -m "feat(scripts): implement detect_indent for json serialization"
```

---

### Task 4: Implement `sort_file` (TDD)

**Files:**
- Modify: `scripts/sort_json.py`
- Create: `tests/integration/test_sort_file.py`

- [ ] **Step 1: Write failing tests**

Create `tests/integration/test_sort_file.py`:

```python
# ABOUTME: Integration tests for sort_file — tests file I/O, JSONC parsing, and error handling.
# ABOUTME: Uses tmp_path fixture to avoid touching real files.
import json
import pytest
from sort_json import sort_file


def test_sorts_json_file_in_place(tmp_path):
    f = tmp_path / "test.json"
    f.write_text('{\n  "b": 1,\n  "a": 2\n}\n', encoding="utf-8")
    sort_file(str(f))
    data = json.loads(f.read_text(encoding="utf-8"))
    assert list(data.keys()) == ["a", "b"]


def test_preserves_trailing_newline(tmp_path):
    f = tmp_path / "test.json"
    f.write_text('{"b": 1, "a": 2}\n', encoding="utf-8")
    sort_file(str(f))
    assert f.read_text(encoding="utf-8").endswith("\n")


def test_does_not_add_trailing_newline_if_absent(tmp_path):
    f = tmp_path / "test.json"
    f.write_text('{"b": 1, "a": 2}', encoding="utf-8")
    sort_file(str(f))
    assert not f.read_text(encoding="utf-8").endswith("\n")


def test_handles_jsonc_file(tmp_path):
    f = tmp_path / "test.json"
    f.write_text('// header comment\n{\n  "b": 1,\n  "a": 2\n}\n', encoding="utf-8")
    sort_file(str(f))
    data = json.loads(f.read_text(encoding="utf-8"))
    assert list(data.keys()) == ["a", "b"]


def test_sorts_recursively(tmp_path):
    f = tmp_path / "test.json"
    f.write_text('{"z": {"b": 1, "a": 2}, "a": 3}\n', encoding="utf-8")
    sort_file(str(f))
    data = json.loads(f.read_text(encoding="utf-8"))
    assert list(data.keys()) == ["a", "z"]
    assert list(data["z"].keys()) == ["a", "b"]


def test_preserves_indent(tmp_path):
    f = tmp_path / "test.json"
    f.write_text('{\n    "b": 1,\n    "a": 2\n}\n', encoding="utf-8")
    sort_file(str(f))
    content = f.read_text(encoding="utf-8")
    assert '    "a"' in content


def test_exits_on_parse_error(tmp_path):
    f = tmp_path / "bad.json"
    f.write_text("not json at all", encoding="utf-8")
    with pytest.raises(SystemExit) as exc_info:
        sort_file(str(f))
    assert exc_info.value.code == 1


def test_exits_on_missing_file():
    with pytest.raises(SystemExit) as exc_info:
        sort_file("/nonexistent/path/file.json")
    assert exc_info.value.code == 1
```

- [ ] **Step 2: Run tests to confirm they fail**

```bash
uv run pytest tests/integration/test_sort_file.py -v
```

Expected: `FAILED` — `NotImplementedError`

- [ ] **Step 3: Implement `sort_file` in `scripts/sort_json.py`**

Replace the stub:

```python
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
```

- [ ] **Step 4: Run tests to confirm they pass**

```bash
uv run pytest tests/integration/test_sort_file.py -v
```

Expected: all `PASSED`

- [ ] **Step 5: Run full test suite**

```bash
uv run pytest -v
```

Expected: all `PASSED`

- [ ] **Step 6: Commit**

```bash
git add scripts/sort_json.py tests/integration/test_sort_file.py
git commit -m "feat(scripts): implement sort_file with jsonc support"
```

---

### Task 5: End-to-end CLI tests

**Files:**
- Create: `tests/e2e/test_cli.py`

- [ ] **Step 1: Write e2e tests**

Create `tests/e2e/test_cli.py`:

```python
# ABOUTME: End-to-end tests for the sort_json.py CLI via subprocess.
# ABOUTME: Verifies the uv run entry point, multi-file handling, and error exit codes.
import json
import subprocess
import pytest


def run_cli(*paths: str) -> subprocess.CompletedProcess:
    return subprocess.run(
        ["uv", "run", "scripts/sort_json.py", *paths],
        capture_output=True,
        text=True,
    )


def test_sorts_single_file(tmp_path):
    f = tmp_path / "test.json"
    f.write_text('{"b": 1, "a": 2}\n', encoding="utf-8")
    result = run_cli(str(f))
    assert result.returncode == 0
    assert list(json.loads(f.read_text()).keys()) == ["a", "b"]


def test_sorts_multiple_files(tmp_path):
    f1 = tmp_path / "a.json"
    f2 = tmp_path / "b.json"
    f1.write_text('{"b": 1, "a": 2}\n', encoding="utf-8")
    f2.write_text('{"d": 3, "c": 4}\n', encoding="utf-8")
    result = run_cli(str(f1), str(f2))
    assert result.returncode == 0
    assert list(json.loads(f1.read_text()).keys()) == ["a", "b"]
    assert list(json.loads(f2.read_text()).keys()) == ["c", "d"]


def test_exits_nonzero_with_no_args():
    result = run_cli()
    assert result.returncode == 1
    assert "Usage" in result.stderr


def test_exits_nonzero_on_invalid_json(tmp_path):
    f = tmp_path / "bad.json"
    f.write_text("not json", encoding="utf-8")
    result = run_cli(str(f))
    assert result.returncode == 1
    assert "Error parsing" in result.stderr


def test_handles_jsonc_via_cli(tmp_path):
    f = tmp_path / "settings.json"
    f.write_text('// comment\n{\n  "b": 1,\n  "a": 2\n}\n', encoding="utf-8")
    result = run_cli(str(f))
    assert result.returncode == 0
    data = json.loads(f.read_text())
    assert list(data.keys()) == ["a", "b"]
```

- [ ] **Step 2: Run e2e tests**

```bash
uv run pytest tests/e2e/test_cli.py -v
```

Expected: all `PASSED`

- [ ] **Step 3: Commit**

```bash
git add tests/e2e/test_cli.py
git commit -m "test(e2e): add cli tests for sort_json.py"
```

---

### Task 6: Add `fd` to Brewfile and `sort-json` Makefile target

**Files:**
- Modify: `Brewfile`
- Modify: `Makefile`

- [ ] **Step 1: Add `fd` to Brewfile**

In `Brewfile`, add after the `fzf` line (line 47):

```
# Simple, fast and user-friendly alternative to find
brew "fd"
```

- [ ] **Step 2: Add `sort-json` target to `Makefile`**

Add after the existing `.PHONY` line at the end of `Makefile`:

```makefile
sort-json:
	fd --extension json \
	    --exclude "vim/vim_runtime/plugins" \
	    --exclude "tmp" \
	    --exclude "dotbot" \
	    --exec-batch uv run scripts/sort_json.py

.PHONY: sort-json
```

Note: the indentation must use a real tab character, not spaces.

- [ ] **Step 3: Verify `fd` is installed (install if needed)**

```bash
brew install fd
```

- [ ] **Step 4: Test the Makefile target dry-run**

```bash
fd --extension json \
    --exclude "vim/vim_runtime/plugins" \
    --exclude "tmp" \
    --exclude "dotbot" \
    --no-exec-batch
```

Review the file list — confirm vendor dirs are excluded and target files (`claude/settings.json`, `zed/settings.json`, etc.) are present.

- [ ] **Step 5: Commit**

```bash
git add Brewfile Makefile
git commit -m "feat(make): add sort-json target using fd"
```

---

### Task 7: Add pre-commit config

**Files:**
- Create: `.pre-commit-config.yaml`

- [ ] **Step 1: Create `.pre-commit-config.yaml`**

```yaml
repos:
  - repo: local
    hooks:
      - id: sort-json
        name: Sort JSON keys
        language: system
        entry: uv run scripts/sort_json.py
        types: [json]
        exclude: |
          (?x)^(
            vim/vim_runtime/plugins/|
            tmp/|
            dotbot/
          )
```

- [ ] **Step 2: Install the hook**

```bash
pre-commit install
```

Expected output: `pre-commit installed at .git/hooks/pre-commit`

- [ ] **Step 3: Run hook against all files manually to verify it works**

```bash
pre-commit run sort-json --all-files
```

Expected: `Sort JSON keys...Passed` (or `Fixed` if any files changed)

- [ ] **Step 4: Commit**

```bash
git add .pre-commit-config.yaml
git commit -m "feat(pre-commit): add sort-json hook for staged json files"
```

---

### Task 8: Bootstrap — normalize all existing JSON files

- [ ] **Step 1: Run sort on all files**

```bash
make sort-json
```

- [ ] **Step 2: Review the diff**

```bash
git diff
```

Verify: only key ordering and formatting changed, no values altered.

- [ ] **Step 3: Run the full test suite one final time**

```bash
uv run pytest -v
```

Expected: all `PASSED`

- [ ] **Step 4: Commit normalized files**

```bash
git add -u
git commit -m "chore: normalize json key ordering across dotfiles"
```

---

## Notes

- **JSONC comment stripping:** `commentjson` strips comments on output. This is acceptable because tools like Zed rewrite their config files on save anyway, overriding any preserved comments.
- **Apple-style JSON formatting:** `claude/settings.json` uses Apple-style formatting (spaces around `:`, capitalized sort). After normalization it will use standard `json.dumps` formatting. This is a one-time change.
- **`fd` required:** The Makefile target requires `fd`. On a new machine, `brew bundle` installs it before `./install` is run.
