# ABOUTME: Unit tests for parse_env — reads .env files into key-value dicts.
# ABOUTME: Covers normal parsing, comments, blanks, missing files, and edge cases.
from _mcp_core import parse_env


def test_parses_key_value_pairs(tmp_path):
    env = tmp_path / ".env"
    env.write_text("FOO=bar\nBAZ=qux\n")
    assert parse_env(str(env)) == {"FOO": "bar", "BAZ": "qux"}


def test_skips_comment_lines(tmp_path):
    env = tmp_path / ".env"
    env.write_text("# comment\nFOO=bar\n")
    assert parse_env(str(env)) == {"FOO": "bar"}


def test_skips_blank_lines(tmp_path):
    env = tmp_path / ".env"
    env.write_text("\nFOO=bar\n\n")
    assert parse_env(str(env)) == {"FOO": "bar"}


def test_missing_file_returns_empty_dict(tmp_path):
    assert parse_env(str(tmp_path / "nonexistent.env")) == {}


def test_strips_whitespace_from_keys(tmp_path):
    env = tmp_path / ".env"
    env.write_text("  FOO  =bar\n")
    assert parse_env(str(env)) == {"FOO": "bar"}


def test_value_with_equals_sign_preserved(tmp_path):
    env = tmp_path / ".env"
    env.write_text("TOKEN=abc=def\n")
    assert parse_env(str(env)) == {"TOKEN": "abc=def"}
