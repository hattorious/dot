# ABOUTME: End-to-end tests for the sort_json.py CLI via subprocess.
# ABOUTME: Verifies the uv run entry point, multi-file handling, and error exit codes.
import json
import subprocess


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
