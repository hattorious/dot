# ABOUTME: Unit tests for MCP wrapper script generation and lifecycle management.
# ABOUTME: Covers wrapper content, executable bit, path mapping, and stale cleanup.
import os

from _mcp_core import cleanup_stale_wrappers, generate_wrapper_script, write_wrapper_scripts

SERVER = {
    "command": "uvx",
    "args": ["basic-memory", "mcp"],
    "tools": ["claude-desktop"],
}

SERVER_WITH_SPACES = {
    "command": "npx",
    "args": ["-y", "@shortcut/mcp@latest"],
    "tools": ["claude-desktop"],
}


def test_generate_wrapper_script_has_shebang():
    script = generate_wrapper_script("basic-memory", SERVER)
    assert script.startswith("#!/usr/bin/env bash\n")


def test_generate_wrapper_script_exec_line():
    script = generate_wrapper_script("basic-memory", SERVER)
    assert "exec uvx basic-memory mcp" in script


def test_generate_wrapper_script_exports_path():
    script = generate_wrapper_script("basic-memory", SERVER)
    assert 'export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"' in script


def test_generate_wrapper_script_redirects_stderr():
    script = generate_wrapper_script("basic-memory", SERVER)
    assert "2>>" in script
    assert "me.hattori.dotbot.mcp.basic-memory.stderr.log" in script


def test_generate_wrapper_script_quotes_args():
    script = generate_wrapper_script("shortcut", SERVER_WITH_SPACES)
    assert "exec npx -y @shortcut/mcp@latest" in script


def test_generate_wrapper_script_contains_server_name():
    script = generate_wrapper_script("basic-memory", SERVER)
    assert "basic-memory" in script


def test_write_wrapper_scripts_creates_files(tmp_path):
    enabled = {"basic-memory": SERVER}
    paths = write_wrapper_scripts(enabled, str(tmp_path))
    assert (tmp_path / "mcp" / "agents" / "basic-memory").exists()
    assert paths["basic-memory"] == str(tmp_path / "mcp" / "agents" / "basic-memory")


def test_write_wrapper_scripts_sets_executable(tmp_path):
    enabled = {"basic-memory": SERVER}
    write_wrapper_scripts(enabled, str(tmp_path))
    script_path = tmp_path / "mcp" / "agents" / "basic-memory"
    assert os.access(str(script_path), os.X_OK)


def test_cleanup_stale_wrappers_removes_stale(tmp_path):
    agents_dir = tmp_path / "mcp" / "agents"
    agents_dir.mkdir(parents=True)
    (agents_dir / "old-server").write_text("#!/usr/bin/env bash\n")

    removed = cleanup_stale_wrappers({}, str(tmp_path))

    assert "old-server" in removed
    assert not (agents_dir / "old-server").exists()


def test_cleanup_stale_wrappers_keeps_enabled(tmp_path):
    agents_dir = tmp_path / "mcp" / "agents"
    agents_dir.mkdir(parents=True)
    (agents_dir / "basic-memory").write_text("#!/usr/bin/env bash\n")

    removed = cleanup_stale_wrappers({"basic-memory": SERVER}, str(tmp_path))

    assert "basic-memory" not in removed
    assert (agents_dir / "basic-memory").exists()


def test_cleanup_stale_wrappers_no_agents_dir(tmp_path):
    # Should not raise if mcp/agents/ doesn't exist yet
    removed = cleanup_stale_wrappers({}, str(tmp_path))
    assert removed == []
