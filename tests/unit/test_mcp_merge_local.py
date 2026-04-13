# ABOUTME: Unit tests for merge_local — merges machine-local server overrides into base config.
# ABOUTME: Only servers present in local are enabled; local keys replace base keys entirely.
import sys
from pathlib import Path

# Add parent dirs to path for imports
sys.path.insert(0, str(Path(__file__).parent.parent.parent))

from dotbot_plugins._mcp_core import merge_local

BASE = {
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


def test_only_local_servers_are_enabled():
    result = merge_local(BASE, {"shortcut": {}})
    assert set(result.keys()) == {"shortcut"}


def test_empty_override_uses_base_config():
    result = merge_local(BASE, {"shortcut": {}})
    assert result["shortcut"]["command"] == "npx"
    assert result["shortcut"]["args"] == ["-y", "@shortcut/mcp@latest"]


def test_local_key_replaces_base_key():
    result = merge_local(BASE, {"shortcut": {"args": ["-y", "@shortcut/mcp@0.1.0"]}})
    assert result["shortcut"]["args"] == ["-y", "@shortcut/mcp@0.1.0"]
    assert result["shortcut"]["command"] == "npx"  # untouched key preserved


def test_local_key_replaces_entire_env_map():
    result = merge_local(BASE, {"shortcut": {"env": {"NEW_KEY": "NEW_KEY"}}})
    assert result["shortcut"]["env"] == {"NEW_KEY": "NEW_KEY"}
    assert "SHORTCUT_API_TOKEN" not in result["shortcut"]["env"]


def test_unknown_local_server_is_skipped():
    result = merge_local(BASE, {"unknown-server": {}})
    assert result == {}


def test_empty_local_returns_empty():
    assert merge_local(BASE, {}) == {}


def test_does_not_mutate_base_servers():
    merge_local(BASE, {"shortcut": {"args": ["new"]}})
    assert BASE["shortcut"]["args"] == ["-y", "@shortcut/mcp@latest"]
