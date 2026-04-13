# ABOUTME: Unit tests for generate_tool_entry and update_tool_configs.
# ABOUTME: Verifies bridge.sh path, socket path, key replacement, and preservation of other config.
import json

import _mcp_core as mcp_core
from _mcp_core import LABEL_PREFIX, SOCKET_DIR, generate_tool_entry, update_tool_configs


def test_generate_tool_entry_command_is_bridge_sh(tmp_path):
    entry = generate_tool_entry("shortcut", str(tmp_path))
    assert entry["command"] == str(tmp_path / "mcp" / "bridge.sh")


def test_generate_tool_entry_args_is_socket_path(tmp_path):
    entry = generate_tool_entry("shortcut", str(tmp_path))
    assert entry["args"] == [f"{SOCKET_DIR}/{LABEL_PREFIX}.shortcut.sock"]


def test_generate_tool_entry_type_is_stdio(tmp_path):
    entry = generate_tool_entry("shortcut", str(tmp_path))
    assert entry["type"] == "stdio"


def test_update_tool_configs_writes_mcp_servers_key(tmp_path, monkeypatch):
    config_path = tmp_path / "claude_desktop_config.json"
    monkeypatch.setitem(mcp_core.TOOL_CONFIG_PATHS, "claude-desktop", str(config_path))

    enabled = {
        "shortcut": {
            "command": "npx",
            "args": ["-y", "@shortcut/mcp@latest"],
            "tools": ["claude-desktop"],
        }
    }
    update_tool_configs(enabled, str(tmp_path))

    data = json.loads(config_path.read_text())
    assert "shortcut" in data["mcpServers"]
    assert data["mcpServers"]["shortcut"]["command"] == str(tmp_path / "mcp" / "bridge.sh")


def test_update_tool_configs_preserves_other_config_keys(tmp_path, monkeypatch):
    config_path = tmp_path / "claude_desktop_config.json"
    config_path.write_text(json.dumps({"globalShortcut": "Cmd+Shift+.", "mcpServers": {}}))
    monkeypatch.setitem(mcp_core.TOOL_CONFIG_PATHS, "claude-desktop", str(config_path))

    enabled = {
        "shortcut": {
            "command": "npx",
            "args": [],
            "tools": ["claude-desktop"],
        }
    }
    update_tool_configs(enabled, str(tmp_path))

    data = json.loads(config_path.read_text())
    assert data["globalShortcut"] == "Cmd+Shift+."


def test_update_tool_configs_replaces_entire_mcp_servers_key(tmp_path, monkeypatch):
    config_path = tmp_path / "claude_desktop_config.json"
    config_path.write_text(json.dumps({"mcpServers": {"old-server": {"command": "old"}}}))
    monkeypatch.setitem(mcp_core.TOOL_CONFIG_PATHS, "claude-desktop", str(config_path))

    enabled = {
        "shortcut": {
            "command": "npx",
            "args": [],
            "tools": ["claude-desktop"],
        }
    }
    update_tool_configs(enabled, str(tmp_path))

    data = json.loads(config_path.read_text())
    assert "old-server" not in data["mcpServers"]
    assert "shortcut" in data["mcpServers"]


def test_update_tool_configs_skips_unknown_tools(tmp_path):
    enabled = {
        "my-server": {
            "command": "npx",
            "args": [],
            "tools": ["not-a-real-tool"],
        }
    }
    # Should not raise
    update_tool_configs(enabled, str(tmp_path))


def test_update_tool_configs_creates_config_dir_if_missing(tmp_path, monkeypatch):
    config_path = tmp_path / "nested" / "dir" / "config.json"
    monkeypatch.setitem(mcp_core.TOOL_CONFIG_PATHS, "cursor", str(config_path))

    enabled = {
        "shortcut": {
            "command": "npx",
            "args": [],
            "tools": ["cursor"],
        }
    }
    update_tool_configs(enabled, str(tmp_path))

    assert config_path.exists()
