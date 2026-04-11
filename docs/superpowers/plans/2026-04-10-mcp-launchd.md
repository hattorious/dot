# MCP launchd management implementation plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Manage MCP servers as launchd agents with inetd-style socket activation via a dotbot plugin driven by `install.conf.yaml`.

**Architecture:** Pure functions in `dotbot_plugins/_mcp_core.py` handle config merging, plist generation, tool config writing, and stale plist cleanup. A thin dotbot plugin class in `dotbot_plugins/mcp_plugin.py` wires them together and is invoked by `./install`. Tool configs are replaced with bridge script entries pointing at Unix domain sockets; launchd spawns a fresh server process per connection.

**Tech Stack:** Python 3.11+, plistlib (stdlib), PyYAML, dotbot, macOS launchctl

---

## File structure

```
mcp/
├── bridge.sh              # stdio↔socket bridge used in tool configs
└── .env.example           # committed template listing required secret keys

dotbot_plugins/
├── _mcp_core.py           # pure functions: parse_env, merge_local, generate_plist,
│                          #   generate_tool_entry, update_tool_configs, cleanup_stale_plists
└── mcp_plugin.py          # McpPlugin(dotbot.Plugin) — thin orchestrator

tests/
├── unit/
│   ├── test_mcp_parse_env.py
│   ├── test_mcp_merge_local.py
│   ├── test_mcp_generate_plist.py
│   ├── test_mcp_tool_config.py
│   └── test_mcp_cleanup.py
└── integration/
    └── test_mcp_pipeline.py
```

**Modified files:**
- `tests/conftest.py` — add `dotbot_plugins/` to sys.path
- `pyproject.toml` — add pyyaml, dotbot dev deps
- `.gitignore` — add `mcp/.env` and `mcp/mcp.local.yaml`
- `install` — add `--plugin-dir dotbot_plugins`
- `install.conf.yaml` — add `mcp:` directive with all server definitions

---

### Task 1: Scaffolding

**Files:**
- Create: `mcp/bridge.sh`
- Create: `mcp/.env.example`
- Modify: `.gitignore`
- Modify: `tests/conftest.py`
- Modify: `pyproject.toml`

- [ ] **Step 1: Write the failing test**

```python
# tests/unit/test_mcp_parse_env.py
import os
import sys
# verify dotbot_plugins/ is on path (conftest should add it)
def test_dotbot_plugins_on_path():
    from _mcp_core import parse_env  # noqa: F401
```

- [ ] **Step 2: Run test to verify it fails**

```
uv run pytest tests/unit/test_mcp_parse_env.py::test_dotbot_plugins_on_path -v
```

Expected: FAIL with `ModuleNotFoundError: No module named '_mcp_core'`

- [ ] **Step 3: Create bridge.sh**

```bash
#!/usr/bin/env bash
# ABOUTME: Bridges stdio to a Unix domain socket for MCP server connections.
# ABOUTME: Takes the socket path as its first argument.
exec nc -U "$1"
```

```bash
chmod +x mcp/bridge.sh
```

- [ ] **Step 4: Create mcp/.env.example**

```
SHORTCUT_API_TOKEN=
GITHUB_PERSONAL_ACCESS_TOKEN=
CIRCLECI_TOKEN=
BIGQUERY_PROJECT=
DATAPLEX_PROJECT=
```

- [ ] **Step 5: Update .gitignore**

Add to the end of `.gitignore`:

```
mcp/.env
mcp/mcp.local.yaml
```

- [ ] **Step 6: Add dotbot_plugins/ to conftest.py**

Replace the entire `tests/conftest.py` with:

```python
# ABOUTME: Pytest configuration — adds scripts/ and dotbot_plugins/ to sys.path.
# ABOUTME: Required because neither directory is a Python package.
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "scripts"))
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "dotbot_plugins"))
```

- [ ] **Step 7: Add dev deps to pyproject.toml**

Add `pyyaml>=6` and `dotbot` to the dev dependency group:

```toml
[dependency-groups]
dev = [
    "commentjson>=0.9",
    "dotbot",
    "pytest>=8",
    "pyyaml>=6",
    "ruff>=0.9",
]
```

- [ ] **Step 8: Sync deps**

```bash
uv sync --dev
```

- [ ] **Step 9: Create dotbot_plugins/_mcp_core.py stub**

```python
# ABOUTME: Pure functions for MCP server config management (no dotbot dependency).
# ABOUTME: Used by the dotbot mcp plugin and directly by unit and integration tests.
```

- [ ] **Step 10: Run test to verify it passes**

```
uv run pytest tests/unit/test_mcp_parse_env.py::test_dotbot_plugins_on_path -v
```

Expected: PASS

- [ ] **Step 11: Commit**

```bash
git add mcp/bridge.sh mcp/.env.example .gitignore tests/conftest.py pyproject.toml uv.lock dotbot_plugins/_mcp_core.py
git commit -m "chore(mcp): scaffold mcp directory, bridge.sh, and dotbot_plugins"
```

---

### Task 2: parse_env

**Files:**
- Modify: `dotbot_plugins/_mcp_core.py`
- Create: `tests/unit/test_mcp_parse_env.py`

- [ ] **Step 1: Write failing tests**

```python
# tests/unit/test_mcp_parse_env.py
# ABOUTME: Unit tests for parse_env — reads .env files into key-value dicts.
# ABOUTME: Covers normal parsing, comments, blanks, missing files, and edge cases.
import pytest
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
```

- [ ] **Step 2: Run tests to verify they fail**

```
uv run pytest tests/unit/test_mcp_parse_env.py -v
```

Expected: FAIL with `ImportError` (function not defined yet)

- [ ] **Step 3: Implement parse_env in _mcp_core.py**

```python
# ABOUTME: Pure functions for MCP server config management (no dotbot dependency).
# ABOUTME: Used by the dotbot mcp plugin and directly by unit and integration tests.
import glob
import json
import os
import plistlib
import subprocess


def parse_env(path: str) -> dict[str, str]:
    """Read a .env file and return key-value pairs. Missing file returns empty dict."""
    result = {}
    try:
        with open(path) as f:
            for line in f:
                line = line.strip()
                if not line or line.startswith("#"):
                    continue
                key, _, value = line.partition("=")
                result[key.strip()] = value
    except FileNotFoundError:
        pass
    return result
```

- [ ] **Step 4: Run tests to verify they pass**

```
uv run pytest tests/unit/test_mcp_parse_env.py -v
```

Expected: 6 passed

- [ ] **Step 5: Commit**

```bash
git add dotbot_plugins/_mcp_core.py tests/unit/test_mcp_parse_env.py
git commit -m "feat(mcp): implement parse_env"
```

---

### Task 3: merge_local

**Files:**
- Modify: `dotbot_plugins/_mcp_core.py`
- Create: `tests/unit/test_mcp_merge_local.py`

- [ ] **Step 1: Write failing tests**

```python
# tests/unit/test_mcp_merge_local.py
# ABOUTME: Unit tests for merge_local — merges machine-local server overrides into base config.
# ABOUTME: Only servers present in local are enabled; local keys replace base keys.
from _mcp_core import merge_local

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
```

- [ ] **Step 2: Run tests to verify they fail**

```
uv run pytest tests/unit/test_mcp_merge_local.py -v
```

Expected: FAIL with `ImportError`

- [ ] **Step 3: Implement merge_local**

Add to `dotbot_plugins/_mcp_core.py` after `parse_env`:

```python
def merge_local(base_servers: dict, local_servers: dict) -> dict:
    """
    Merge local server overrides into base server definitions.

    Only servers present in local_servers are enabled. For each enabled server,
    local keys replace base keys entirely (no deep merge within a key).
    Servers in local_servers not found in base_servers are silently skipped.
    """
    result = {}
    for name, local_override in local_servers.items():
        if name not in base_servers:
            continue
        merged = dict(base_servers[name])
        if local_override:
            merged.update(local_override)
        result[name] = merged
    return result
```

- [ ] **Step 4: Run tests to verify they pass**

```
uv run pytest tests/unit/test_mcp_merge_local.py -v
```

Expected: 7 passed

- [ ] **Step 5: Commit**

```bash
git add dotbot_plugins/_mcp_core.py tests/unit/test_mcp_merge_local.py
git commit -m "feat(mcp): implement merge_local"
```

---

### Task 4: generate_plist

**Files:**
- Modify: `dotbot_plugins/_mcp_core.py`
- Create: `tests/unit/test_mcp_generate_plist.py`

- [ ] **Step 1: Write failing tests**

```python
# tests/unit/test_mcp_generate_plist.py
# ABOUTME: Unit tests for generate_plist — produces launchd plist XML for an MCP server.
# ABOUTME: Verifies label format, socket path, inetd mode, and env var expansion.
import plistlib

from _mcp_core import LABEL_PREFIX, SOCKET_DIR, generate_plist

SERVER_NO_ENV = {
    "command": "docker",
    "args": ["run", "-i", "--rm", "hashicorp/terraform-mcp-server:0.4.0"],
    "tools": ["claude-desktop"],
}

SERVER_WITH_ENV = {
    "command": "npx",
    "args": ["-y", "@shortcut/mcp@latest"],
    "env": {"SHORTCUT_API_TOKEN": "SHORTCUT_API_TOKEN"},
    "tools": ["claude-desktop"],
}


def _parse(plist_bytes: bytes) -> dict:
    return plistlib.loads(plist_bytes)


def test_label_format():
    data = _parse(generate_plist("shortcut", SERVER_WITH_ENV, {}))
    assert data["Label"] == f"{LABEL_PREFIX}.shortcut"


def test_program_arguments_includes_command_and_args():
    data = _parse(generate_plist("shortcut", SERVER_WITH_ENV, {}))
    assert data["ProgramArguments"] == ["npx", "-y", "@shortcut/mcp@latest"]


def test_socket_path_uses_label():
    data = _parse(generate_plist("shortcut", SERVER_WITH_ENV, {}))
    assert data["Sockets"]["MCP"]["SockPathName"] == f"{SOCKET_DIR}/{LABEL_PREFIX}.shortcut.sock"


def test_socket_type_is_stream():
    data = _parse(generate_plist("shortcut", SERVER_WITH_ENV, {}))
    assert data["Sockets"]["MCP"]["SockType"] == "stream"


def test_inetd_compatibility_wait_false():
    data = _parse(generate_plist("shortcut", SERVER_WITH_ENV, {}))
    assert data["inetdCompatibility"] == {"Wait": False}


def test_env_var_expanded_from_env_values():
    env_values = {"SHORTCUT_API_TOKEN": "sct_secret_value"}
    data = _parse(generate_plist("shortcut", SERVER_WITH_ENV, env_values))
    assert data["EnvironmentVariables"]["SHORTCUT_API_TOKEN"] == "sct_secret_value"


def test_missing_env_var_omits_key_from_plist():
    data = _parse(generate_plist("shortcut", SERVER_WITH_ENV, {}))
    assert "EnvironmentVariables" not in data


def test_server_with_no_env_section_has_no_env_vars():
    data = _parse(generate_plist("terraform", SERVER_NO_ENV, {}))
    assert "EnvironmentVariables" not in data


def test_server_name_used_in_socket_path():
    data = _parse(generate_plist("my-server", SERVER_NO_ENV, {}))
    assert "my-server" in data["Sockets"]["MCP"]["SockPathName"]


def test_empty_args_list_produces_only_command():
    server = {"command": "uvx", "args": [], "tools": ["claude-desktop"]}
    data = _parse(generate_plist("basic-memory", server, {}))
    assert data["ProgramArguments"] == ["uvx"]
```

- [ ] **Step 2: Run tests to verify they fail**

```
uv run pytest tests/unit/test_mcp_generate_plist.py -v
```

Expected: FAIL with `ImportError`

- [ ] **Step 3: Implement generate_plist and constants**

Add to `dotbot_plugins/_mcp_core.py` after the imports, before `parse_env`:

```python
LABEL_PREFIX = "me.hattori.dotbot.mcp"
SOCKET_DIR = "/tmp"
LAUNCH_AGENTS_DIR = os.path.expanduser("~/Library/LaunchAgents")
```

Then add after `merge_local`:

```python
def generate_plist(name: str, server: dict, env_values: dict) -> bytes:
    """Generate launchd plist XML bytes for an MCP server."""
    label = f"{LABEL_PREFIX}.{name}"
    sock_path = f"{SOCKET_DIR}/{label}.sock"

    args = [server["command"]] + server.get("args", [])

    env_vars = {}
    for env_key, env_source in server.get("env", {}).items():
        if env_source in env_values:
            env_vars[env_key] = env_values[env_source]

    plist: dict = {
        "Label": label,
        "ProgramArguments": args,
        "Sockets": {
            "MCP": {
                "SockPathName": sock_path,
                "SockType": "stream",
            }
        },
        "inetdCompatibility": {"Wait": False},
    }
    if env_vars:
        plist["EnvironmentVariables"] = env_vars

    return plistlib.dumps(plist, fmt=plistlib.FMT_XML)
```

- [ ] **Step 4: Run tests to verify they pass**

```
uv run pytest tests/unit/test_mcp_generate_plist.py -v
```

Expected: 10 passed

- [ ] **Step 5: Commit**

```bash
git add dotbot_plugins/_mcp_core.py tests/unit/test_mcp_generate_plist.py
git commit -m "feat(mcp): implement generate_plist"
```

---

### Task 5: generate_tool_entry and update_tool_configs

**Files:**
- Modify: `dotbot_plugins/_mcp_core.py`
- Create: `tests/unit/test_mcp_tool_config.py`

- [ ] **Step 1: Write failing tests**

```python
# tests/unit/test_mcp_tool_config.py
# ABOUTME: Unit tests for generate_tool_entry and update_tool_configs.
# ABOUTME: Verifies bridge.sh path, socket path, key replacement, and preservation of other config.
import json
import os

import pytest

import _mcp_core as mcp_core
from _mcp_core import LABEL_PREFIX, SOCKET_DIR, generate_tool_entry, update_tool_configs


def test_generate_tool_entry_command_is_bridge_sh(tmp_path):
    entry = generate_tool_entry("shortcut", str(tmp_path))
    assert entry["command"] == str(tmp_path / "mcp" / "bridge.sh")


def test_generate_tool_entry_args_is_socket_path(tmp_path):
    entry = generate_tool_entry("shortcut", str(tmp_path))
    assert entry["args"] == [f"{SOCKET_DIR}/{LABEL_PREFIX}.shortcut.sock"]


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
```

- [ ] **Step 2: Run tests to verify they fail**

```
uv run pytest tests/unit/test_mcp_tool_config.py -v
```

Expected: FAIL with `ImportError`

- [ ] **Step 3: Implement generate_tool_entry and update_tool_configs**

Add after `LAUNCH_AGENTS_DIR` constant in `dotbot_plugins/_mcp_core.py`:

```python
TOOL_CONFIG_PATHS: dict[str, str] = {
    "claude-desktop": os.path.expanduser(
        "~/Library/Application Support/Claude/claude_desktop_config.json"
    ),
    "cursor": os.path.expanduser("~/.cursor/mcp.json"),
}

TOOL_MCP_KEY: dict[str, str] = {
    "claude-desktop": "mcpServers",
    "cursor": "mcpServers",
}
```

Then add after `generate_plist`:

```python
def generate_tool_entry(name: str, base_dir: str) -> dict:
    """Generate the mcpServers entry for a single server (command + socket path)."""
    label = f"{LABEL_PREFIX}.{name}"
    sock_path = f"{SOCKET_DIR}/{label}.sock"
    bridge = os.path.join(base_dir, "mcp", "bridge.sh")
    return {"command": bridge, "args": [sock_path]}


def update_tool_configs(enabled: dict, base_dir: str) -> None:
    """Write mcpServers entries into each tool's config file.

    Reads the existing config, replaces only the MCP-managed key, writes back.
    Other keys in the tool config are untouched.
    """
    tool_servers: dict[str, dict] = {}
    for name, server in enabled.items():
        for tool in server.get("tools", []):
            tool_servers.setdefault(tool, {})[name] = server

    for tool, servers in tool_servers.items():
        config_path = TOOL_CONFIG_PATHS.get(tool)
        if not config_path:
            continue
        mcp_key = TOOL_MCP_KEY[tool]

        existing: dict = {}
        if os.path.exists(config_path):
            with open(config_path) as f:
                existing = json.load(f)

        existing[mcp_key] = {name: generate_tool_entry(name, base_dir) for name in servers}

        os.makedirs(os.path.dirname(config_path), exist_ok=True)
        with open(config_path, "w") as f:
            json.dump(existing, f, indent=2)
            f.write("\n")
```

- [ ] **Step 4: Run tests to verify they pass**

```
uv run pytest tests/unit/test_mcp_tool_config.py -v
```

Expected: 6 passed

- [ ] **Step 5: Commit**

```bash
git add dotbot_plugins/_mcp_core.py tests/unit/test_mcp_tool_config.py
git commit -m "feat(mcp): implement generate_tool_entry and update_tool_configs"
```

---

### Task 6: cleanup_stale_plists

**Files:**
- Modify: `dotbot_plugins/_mcp_core.py`
- Create: `tests/unit/test_mcp_cleanup.py`

- [ ] **Step 1: Write failing tests**

```python
# tests/unit/test_mcp_cleanup.py
# ABOUTME: Unit tests for cleanup_stale_plists — removes launchd plists for disabled servers.
# ABOUTME: Verifies launchctl is called before deletion and enabled plists are untouched.
from unittest.mock import call, patch

from _mcp_core import LABEL_PREFIX, cleanup_stale_plists


def test_removes_stale_plist(tmp_path):
    stale = tmp_path / f"{LABEL_PREFIX}.old-server.plist"
    stale.write_text("<plist/>")

    with patch("subprocess.run"):
        removed = cleanup_stale_plists({}, str(tmp_path))

    assert "old-server" in removed
    assert not stale.exists()


def test_keeps_enabled_plist(tmp_path):
    active = tmp_path / f"{LABEL_PREFIX}.shortcut.plist"
    active.write_text("<plist/>")

    with patch("subprocess.run"):
        removed = cleanup_stale_plists({"shortcut": {}}, str(tmp_path))

    assert "shortcut" not in removed
    assert active.exists()


def test_calls_launchctl_unload_before_deleting(tmp_path):
    stale = tmp_path / f"{LABEL_PREFIX}.old-server.plist"
    stale.write_text("<plist/>")

    with patch("subprocess.run") as mock_run:
        cleanup_stale_plists({}, str(tmp_path))

    mock_run.assert_called_once_with(
        ["launchctl", "unload", str(stale)], capture_output=True
    )


def test_empty_dir_returns_empty_list(tmp_path):
    with patch("subprocess.run"):
        removed = cleanup_stale_plists({}, str(tmp_path))
    assert removed == []


def test_non_mcp_plists_are_ignored(tmp_path):
    other = tmp_path / "com.apple.something.plist"
    other.write_text("<plist/>")

    with patch("subprocess.run"):
        removed = cleanup_stale_plists({}, str(tmp_path))

    assert removed == []
    assert other.exists()
```

- [ ] **Step 2: Run tests to verify they fail**

```
uv run pytest tests/unit/test_mcp_cleanup.py -v
```

Expected: FAIL with `ImportError`

- [ ] **Step 3: Implement cleanup_stale_plists**

Add at the end of `dotbot_plugins/_mcp_core.py`:

```python
def cleanup_stale_plists(enabled: dict, launch_agents_dir: str = LAUNCH_AGENTS_DIR) -> list[str]:
    """Remove launchd plists for servers no longer in enabled.

    Calls `launchctl unload` before deleting each plist.
    Returns the list of removed server names.
    """
    pattern = os.path.join(launch_agents_dir, f"{LABEL_PREFIX}.*.plist")
    prefix = f"{LABEL_PREFIX}."
    suffix = ".plist"
    removed = []
    for plist_path in glob.glob(pattern):
        filename = os.path.basename(plist_path)
        name = filename[len(prefix) : -len(suffix)]
        if name not in enabled:
            subprocess.run(["launchctl", "unload", plist_path], capture_output=True)
            os.remove(plist_path)
            removed.append(name)
    return removed
```

- [ ] **Step 4: Run all tests to verify they pass**

```
uv run pytest -v
```

Expected: all tests pass (existing 31 + new tests for mcp)

- [ ] **Step 5: Commit**

```bash
git add dotbot_plugins/_mcp_core.py tests/unit/test_mcp_cleanup.py
git commit -m "feat(mcp): implement cleanup_stale_plists"
```

---

### Task 7: Integration test

**Files:**
- Create: `tests/integration/test_mcp_pipeline.py`

- [ ] **Step 1: Write failing tests**

```python
# tests/integration/test_mcp_pipeline.py
# ABOUTME: Integration tests for the full MCP pipeline: env parsing, config merge,
# ABOUTME: plist generation, tool config writing, and stale plist cleanup together.
import json
import plistlib
from unittest.mock import patch

import pytest

import _mcp_core as mcp_core
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
    (tmp_path / "mcp" / "bridge.sh").write_text(
        '#!/usr/bin/env bash\nexec nc -U "$1"\n'
    )

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
```

- [ ] **Step 2: Run tests to verify they fail**

```
uv run pytest tests/integration/test_mcp_pipeline.py -v
```

Expected: FAIL (functions exist but test file is new — some may pass, verify none erroneously skip)

- [ ] **Step 3: Run all tests**

```
uv run pytest -v
```

Expected: all pass

- [ ] **Step 4: Commit**

```bash
git add tests/integration/test_mcp_pipeline.py
git commit -m "test(mcp): add integration tests for full pipeline"
```

---

### Task 8: McpPlugin class

**Files:**
- Create: `dotbot_plugins/mcp_plugin.py`
- Create: `tests/unit/test_mcp_plugin.py`
- Modify: `pyproject.toml` (dotbot already added in Task 1)

- [ ] **Step 1: Write failing tests**

```python
# tests/unit/test_mcp_plugin.py
# ABOUTME: Unit tests for McpPlugin — the dotbot plugin class.
# ABOUTME: Verifies directive matching and that handle returns True on missing local config.
from unittest.mock import MagicMock, patch
import pytest


def test_can_handle_mcp_directive():
    from mcp_plugin import McpPlugin
    ctx = MagicMock()
    log = MagicMock()
    plugin = McpPlugin(ctx, log)
    assert plugin.can_handle("mcp") is True


def test_cannot_handle_other_directives():
    from mcp_plugin import McpPlugin
    ctx = MagicMock()
    log = MagicMock()
    plugin = McpPlugin(ctx, log)
    assert plugin.can_handle("link") is False
    assert plugin.can_handle("shell") is False


def test_handle_returns_true_when_local_config_missing(tmp_path):
    from mcp_plugin import McpPlugin
    ctx = MagicMock()
    ctx.base_directory.return_value = str(tmp_path)
    log = MagicMock()
    plugin = McpPlugin(ctx, log)

    result = plugin.handle("mcp", {
        "env": "mcp/.env",
        "local": "mcp/mcp.local.yaml",
        "servers": {},
    })

    assert result is True
    log.warning.assert_called_once()
```

- [ ] **Step 2: Run tests to verify they fail**

```
uv run pytest tests/unit/test_mcp_plugin.py -v
```

Expected: FAIL with `ModuleNotFoundError: No module named 'mcp_plugin'`

- [ ] **Step 3: Implement McpPlugin**

Create `dotbot_plugins/mcp_plugin.py`:

```python
# ABOUTME: Dotbot plugin that manages MCP servers as launchd agents with socket activation.
# ABOUTME: Reads server definitions from install.conf.yaml and mcp/mcp.local.yaml.
import os
import subprocess

import dotbot
import yaml

from _mcp_core import (
    LABEL_PREFIX,
    LAUNCH_AGENTS_DIR,
    cleanup_stale_plists,
    generate_plist,
    merge_local,
    parse_env,
    update_tool_configs,
)


class McpPlugin(dotbot.Plugin):
    def can_handle(self, directive):
        return directive == "mcp"

    def handle(self, directive, data):
        base_dir = self._context.base_directory()

        local_path = os.path.join(base_dir, data.get("local", "mcp/mcp.local.yaml"))
        if not os.path.exists(local_path):
            self._log.warning(f"MCP: {local_path} not found — skipping MCP setup")
            return True

        with open(local_path) as f:
            local = yaml.safe_load(f) or {}
        local_servers = local.get("servers", {})

        base_servers = data.get("servers", {})
        enabled = merge_local(base_servers, local_servers)

        env_path = os.path.join(base_dir, data.get("env", "mcp/.env"))
        env_values = parse_env(env_path)

        os.makedirs(LAUNCH_AGENTS_DIR, exist_ok=True)
        for name, server in enabled.items():
            plist_bytes = generate_plist(name, server, env_values)
            plist_path = os.path.join(LAUNCH_AGENTS_DIR, f"{LABEL_PREFIX}.{name}.plist")

            subprocess.run(["launchctl", "unload", plist_path], capture_output=True)
            with open(plist_path, "wb") as f:
                f.write(plist_bytes)
            result = subprocess.run(
                ["launchctl", "load", plist_path], capture_output=True, text=True
            )
            if result.returncode != 0:
                self._log.warning(
                    f"MCP: failed to load {name}: {result.stderr.strip()}"
                )

        cleanup_stale_plists(enabled)
        update_tool_configs(enabled, base_dir)

        return True
```

- [ ] **Step 4: Run tests to verify they pass**

```
uv run pytest tests/unit/test_mcp_plugin.py -v
```

Expected: 3 passed

- [ ] **Step 5: Run full test suite**

```
uv run pytest -v
```

Expected: all pass

- [ ] **Step 6: Commit**

```bash
git add dotbot_plugins/mcp_plugin.py tests/unit/test_mcp_plugin.py
git commit -m "feat(mcp): implement McpPlugin dotbot plugin"
```

---

### Task 9: Wire install script and install.conf.yaml

**Files:**
- Modify: `install`
- Modify: `install.conf.yaml`

- [ ] **Step 1: Update install script**

In `install`, replace the last line:

```bash
"${BASEDIR}/${DOTBOT_DIR}/${DOTBOT_BIN}" -d "${BASEDIR}" -c "${CONFIG}" "${@}"
```

With:

```bash
"${BASEDIR}/${DOTBOT_DIR}/${DOTBOT_BIN}" -d "${BASEDIR}" -c "${CONFIG}" --plugin-dir dotbot_plugins "${@}"
```

- [ ] **Step 2: Verify install script runs without error (dry run)**

```bash
./install --help
```

Expected: dotbot help output, no errors

- [ ] **Step 3: Add mcp: directive to install.conf.yaml**

Add at the end of `install.conf.yaml`, after the `shell:` block:

```yaml
- mcp:
    env: mcp/.env
    local: mcp/mcp.local.yaml
    servers:
      shortcut:
        command: npx
        args: ["-y", "@shortcut/mcp@latest"]
        env:
          SHORTCUT_API_TOKEN: SHORTCUT_API_TOKEN
        tools: [claude-desktop, cursor]

      terraform:
        command: docker
        args: ["run", "-i", "--rm", "hashicorp/terraform-mcp-server:0.4.0"]
        tools: [claude-desktop, cursor]

      github:
        command: docker
        args: ["run", "-i", "--rm", "-e", "GITHUB_PERSONAL_ACCESS_TOKEN", "ghcr.io/github/github-mcp-server"]
        env:
          GITHUB_PERSONAL_ACCESS_TOKEN: GITHUB_PERSONAL_ACCESS_TOKEN
        tools: [claude-desktop]

      google-cloud-toolbox:
        command: /opt/homebrew/bin/toolbox
        args: ["--prebuilt", "bigquery,cloud-sql-postgres-admin,dataplex", "--stdio"]
        env:
          BIGQUERY_PROJECT: BIGQUERY_PROJECT
          DATAPLEX_PROJECT: DATAPLEX_PROJECT
        tools: [claude-desktop]

      private-journal:
        command: npx
        args: ["github:obra/private-journal-mcp"]
        tools: [claude-desktop]

      basic-memory:
        command: uvx
        args: ["basic-memory", "mcp"]
        tools: [claude-desktop]

      circleci:
        command: npx
        args: ["-y", "@circleci/mcp-server-circleci"]
        env:
          CIRCLECI_TOKEN: CIRCLECI_TOKEN
        tools: [cursor]

      prefect:
        command: uvx
        args: ["--from", "prefect-mcp", "prefect-mcp-server"]
        tools: [cursor]
```

- [ ] **Step 4: Create mcp/mcp.local.yaml for this machine**

```yaml
# Machine-local MCP server selection. Gitignored.
# List only the servers you want on this machine.
# Keys listed under a server name override the base config for that server.
servers:
  github: {}
  basic-memory: {}
  google-cloud-toolbox: {}
  private-journal: {}
```

- [ ] **Step 5: Create mcp/.env for this machine**

Copy from example and fill in real values:

```bash
cp mcp/.env.example mcp/.env
# then edit mcp/.env with real secret values
```

- [ ] **Step 6: Run full test suite**

```
uv run pytest -v
```

Expected: all pass

- [ ] **Step 7: Commit**

```bash
git add install install.conf.yaml mcp/.env.example mcp/bridge.sh
git commit -m "feat(mcp): wire dotbot plugin into install and install.conf.yaml"
```

---

## Self-review

**Spec coverage:**
- ✅ bridge.sh — Task 1
- ✅ parse_env — Task 2
- ✅ merge_local (key-level replacement, unknown servers skipped) — Task 3
- ✅ generate_plist (label format, socket path, inetd mode, env expansion) — Task 4
- ✅ generate_tool_entry + update_tool_configs (preserves other keys) — Task 5
- ✅ cleanup_stale_plists (calls launchctl unload, ignores non-mcp plists) — Task 6
- ✅ Integration test — Task 7
- ✅ McpPlugin class — Task 8
- ✅ install script + install.conf.yaml — Task 9
- ✅ .gitignore entries for mcp/.env and mcp/mcp.local.yaml — Task 1
- ✅ .env.example template — Task 1

**No placeholders found.**

**Type consistency:** All functions reference `LABEL_PREFIX`, `SOCKET_DIR`, `LAUNCH_AGENTS_DIR`, `TOOL_CONFIG_PATHS`, `TOOL_MCP_KEY` from the same module. `generate_tool_entry` is called by `update_tool_configs` consistently. `cleanup_stale_plists` signature matches all call sites.
