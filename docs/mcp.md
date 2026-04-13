# MCP Server Management

MCP servers are managed as macOS launchd agents via a dotbot plugin. Each server gets a
Unix socket held by launchd (inetd-style activation); MCP clients connect through `mcp/bridge.sh`.

## Quick Start

1. Copy the env template and fill in API keys:
   ```bash
   cp mcp/.env.example mcp/.env
   # edit mcp/.env with your tokens
   ```

2. Create `mcp/mcp.local.yaml` listing the servers to enable on this machine:
   ```yaml
   servers:
     basic-memory: {}
     shortcut: {}
   ```

3. Run `./install` — generates wrapper scripts, launchd plists, and updates all tool configs.

## File Layout

| Path | Purpose |
|------|---------|
| `install.conf.yaml` → `mcp:` | Master server definitions (committed) |
| `mcp/mcp.local.yaml` | Which servers to enable locally (gitignored) |
| `mcp/.env` | API token values (gitignored) |
| `mcp/.env.example` | Token key names with empty values (committed) |
| `mcp/bridge.sh` | Thin nc wrapper — tools exec this as the MCP command |
| `mcp/agents/mcp-<name>` | Generated wrapper scripts (gitignored) |
| `dotbot_plugins/_mcp_core.py` | Pure functions: plist/wrapper/config generation |
| `dotbot_plugins/mcp_plugin.py` | Dotbot plugin that calls _mcp_core |

## Servers

| Name | Command | Env required |
|------|---------|-------------|
| `basic-memory` | `uvx basic-memory mcp` | — |
| `shortcut` | `npx @shortcut/mcp@latest` | `SHORTCUT_API_TOKEN` |
| `terraform` | `docker run hashicorp/terraform-mcp-server` | — |
| `github` | `docker run ghcr.io/github/github-mcp-server` | `GITHUB_PERSONAL_ACCESS_TOKEN` |
| `google-cloud-toolbox` | `/opt/homebrew/bin/toolbox --stdio` | `BIGQUERY_PROJECT`, `DATAPLEX_PROJECT` |
| `private-journal` | `npx github:2389-research/journal-mcp` | — |
| `circleci` | `npx @circleci/mcp-server-circleci` | `CIRCLECI_TOKEN` |
| `prefect` | `uvx --from prefect-mcp prefect-mcp-server` | — |

## Debugging

```bash
# Check agent status
launchctl list | grep me.hattori.dotbot.mcp

# View stderr from a server (download noise, errors)
tail -f /tmp/me.hattori.dotbot.mcp.<name>.stderr.log

# Manually trigger a connection test
nc -U /tmp/me.hattori.dotbot.mcp.<name>.sock
```

## Tool Config Targets

`./install` writes `mcpServers` into each enabled tool's config file:

| Tool | Config file |
|------|------------|
| Claude Desktop | `~/Library/Application Support/Claude/claude_desktop_config.json` |
| Cursor | `~/.cursor/mcp.json` |
| Claude Code | `~/.claude.json` |
| Gemini | `~/.gemini/settings.json` |

**Note**: `./install` replaces the entire `mcpServers` key — any manually added entries
in those files will be removed on the next run.

## Adding a New Server

1. Add entry under `mcp:` → `servers:` in `install.conf.yaml`
2. Add token key to `mcp/.env.example` if needed
3. Add server name to `mcp/mcp.local.yaml` on machines where it should run
4. Run `./install`
