# ABOUTME: Unit tests for McpPlugin — the dotbot plugin class.
# ABOUTME: Verifies directive matching and that handle returns True on missing local config.
from unittest.mock import MagicMock, patch


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

    result = plugin.handle(
        "mcp",
        {
            "env": "mcp/.env",
            "local": "mcp/mcp.local.yaml",
            "servers": {},
        },
    )

    assert result is True
    log.warning.assert_called_once()


def test_handle_runs_full_pipeline_when_local_config_present(tmp_path):
    import yaml
    from mcp_plugin import McpPlugin

    # Write a minimal local config with one server
    mcp_dir = tmp_path / "mcp"
    mcp_dir.mkdir()
    local_yaml = mcp_dir / "mcp.local.yaml"
    local_yaml.write_text(yaml.dump({"servers": {"shortcut": {}}}))

    ctx = MagicMock()
    ctx.base_directory.return_value = str(tmp_path)
    log = MagicMock()
    plugin = McpPlugin(ctx, log)

    base_servers = {
        "shortcut": {
            "command": "npx",
            "args": ["-y", "@shortcut/mcp@latest"],
            "tools": ["claude-desktop"],
        }
    }

    with (
        patch("mcp_plugin.subprocess.run"),
        patch("mcp_plugin.update_tool_configs") as mock_update,
        patch("mcp_plugin.cleanup_stale_plists") as mock_cleanup,
        patch("mcp_plugin.LAUNCH_AGENTS_DIR", str(tmp_path / "LaunchAgents")),
    ):
        (tmp_path / "LaunchAgents").mkdir()
        result = plugin.handle(
            "mcp",
            {
                "env": "mcp/.env",
                "local": "mcp/mcp.local.yaml",
                "servers": base_servers,
            },
        )

    assert result is True
    mock_cleanup.assert_called_once()
    mock_update.assert_called_once()
