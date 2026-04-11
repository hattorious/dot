# ABOUTME: Unit tests for McpPlugin — the dotbot plugin class.
# ABOUTME: Verifies directive matching and that handle returns True on missing local config.
from unittest.mock import MagicMock


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
