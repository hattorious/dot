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
