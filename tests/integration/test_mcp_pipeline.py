# ABOUTME: Integration tests for the full MCP pipeline: env parsing, config merge,
# ABOUTME: plist generation, tool config writing, and stale plist cleanup together.
import json
import plistlib
from unittest.mock import patch

import _mcp_core as mcp_core
import pytest
from _mcp_core import (
    LABEL_PREFIX,
    SOCKET_DIR,
    cleanup_stale_plists,
    generate_plist,
    merge_local,
    parse_env,
    update_tool_configs,
)

BASE_SERVERS = {
    "shortcut": {
        "command": "npx",
        "args": ["-y", "@shortcut/mcp@latest"],
        "env": {"SHORTCUT_API_TOKEN": "SHORTCUT_API_TOKEN"},
        "tools": ["claude-desktop", "cursor"],
    },
    "terraform": {
        "command": "docker",
        "args": ["run", "-i", "--rm", "hashicorp/terraform-mcp-server:0.4.0"],
        "tools": ["claude-desktop"],
    },
}


@pytest.fixture
def workspace(tmp_path, monkeypatch):
    (tmp_path / "mcp").mkdir()
    (tmp_path / "mcp" / "bridge.sh").write_text('#!/usr/bin/env bash\nexec nc -U "$1"\n')

    launch_agents = tmp_path / "LaunchAgents"
    launch_agents.mkdir()
    claude_config = tmp_path / "claude_desktop_config.json"
    cursor_config = tmp_path / "cursor_mcp.json"

    monkeypatch.setattr(mcp_core, "LAUNCH_AGENTS_DIR", str(launch_agents))
    monkeypatch.setitem(mcp_core.TOOL_CONFIG_PATHS, "claude-desktop", str(claude_config))
    monkeypatch.setitem(mcp_core.TOOL_CONFIG_PATHS, "cursor", str(cursor_config))

    return {
        "base_dir": tmp_path,
        "launch_agents": launch_agents,
        "claude_config": claude_config,
        "cursor_config": cursor_config,
    }


def test_env_values_reach_generated_plist(workspace, tmp_path):
    env_file = tmp_path / ".env"
    env_file.write_text("SHORTCUT_API_TOKEN=sct_real_secret\n")
    env_values = parse_env(str(env_file))

    enabled = merge_local(BASE_SERVERS, {"shortcut": {}})
    plist_bytes = generate_plist("shortcut", enabled["shortcut"], env_values)

    data = plistlib.loads(plist_bytes)
    assert data["EnvironmentVariables"]["SHORTCUT_API_TOKEN"] == "sct_real_secret"


def test_plist_written_to_launch_agents(workspace):
    enabled = merge_local(BASE_SERVERS, {"shortcut": {}})
    plist_bytes = generate_plist("shortcut", enabled["shortcut"], {})

    plist_path = workspace["launch_agents"] / f"{LABEL_PREFIX}.shortcut.plist"
    plist_path.write_bytes(plist_bytes)

    data = plistlib.loads(plist_path.read_bytes())
    assert data["Label"] == f"{LABEL_PREFIX}.shortcut"
    assert data["inetdCompatibility"] == {"Wait": False}
    assert data["Sockets"]["MCP"]["SockPathName"] == f"{SOCKET_DIR}/{LABEL_PREFIX}.shortcut.sock"


def test_tool_config_written_with_bridge_command(workspace):
    enabled = merge_local(BASE_SERVERS, {"shortcut": {}})
    update_tool_configs(enabled, str(workspace["base_dir"]))

    data = json.loads(workspace["claude_config"].read_text())
    assert "shortcut" in data["mcpServers"]
    entry = data["mcpServers"]["shortcut"]
    assert entry["command"] == str(workspace["base_dir"] / "mcp" / "bridge.sh")
    assert entry["args"] == [f"{SOCKET_DIR}/{LABEL_PREFIX}.shortcut.sock"]


def test_tool_config_written_for_multiple_tools(workspace):
    enabled = merge_local(BASE_SERVERS, {"shortcut": {}})
    update_tool_configs(enabled, str(workspace["base_dir"]))

    claude_data = json.loads(workspace["claude_config"].read_text())
    cursor_data = json.loads(workspace["cursor_config"].read_text())

    assert "shortcut" in claude_data["mcpServers"]
    assert "shortcut" in cursor_data["mcpServers"]


def test_local_arg_override_reaches_plist(workspace):
    local = {"shortcut": {"args": ["-y", "@shortcut/mcp@0.1.0"]}}
    enabled = merge_local(BASE_SERVERS, local)

    plist_bytes = generate_plist("shortcut", enabled["shortcut"], {})
    data = plistlib.loads(plist_bytes)

    assert data["ProgramArguments"] == ["npx", "-y", "@shortcut/mcp@0.1.0"]


def test_stale_plist_removed_during_cleanup(workspace):
    stale = workspace["launch_agents"] / f"{LABEL_PREFIX}.removed-server.plist"
    stale.write_text("<plist/>")

    with patch("subprocess.run"):
        removed = cleanup_stale_plists({}, str(workspace["launch_agents"]))

    assert "removed-server" in removed
    assert not stale.exists()
