# MCP server management via launchd

## Goal

Manage MCP servers as launchd agents on macOS. Single source of truth in dotfiles drives launchd service installation and per-tool config generation. Machine-specific selection and argument overrides via a gitignored local file.

## Architecture

Each MCP server runs as a launchd agent with inetd-style socket activation. launchd holds a Unix domain socket per server. When a tool connects, launchd spawns a fresh server process with its stdin/stdout wired directly to the socket — no proxy layer needed, existing stdio servers work unchanged.

Tools are configured to connect via a generic bridge script (`mcp/bridge.sh`) that speaks to the socket. From the tool's perspective it's just a command that reads stdin and writes stdout.

```
tool (Claude Desktop, Cursor)
  → spawns bridge.sh /tmp/me.hattori.dotbot.mcp.shortcut.sock
  → bridge.sh connects to socket via nc
  → launchd sees connection, spawns: npx -y @shortcut/mcp@latest
  → server's stdio is the socket connection
```

Each connection gets its own process. No multiplexing, no session sharing.

## File structure

```
mcp/
├── .env              # secrets — gitignored
├── .env.example      # committed, lists required keys with empty values
└── bridge.sh         # generic stdio↔socket bridge (committed)

dotbot_plugins/
└── mcp.py            # dotbot plugin
```

Server definitions live in `install.conf.yaml` under the `mcp:` directive. Machine-specific config goes in `mcp/mcp.local.yaml` (gitignored).

## Server definitions in install.conf.yaml

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

The `env` map under each server maps `.env` key names to the environment variable the server process expects. In most cases these are the same name.

## Machine-local config (mcp/mcp.local.yaml)

Gitignored. Controls which servers are installed on this machine and overrides any base config values.

```yaml
# Example: work machine
servers:
  shortcut: {}
  github: {}
  circleci: {}
  google-cloud-toolbox: {}

# Example: personal machine
servers:
  github: {}
  basic-memory: {}
  google-cloud-toolbox:
    args: ["--prebuilt", "bigquery", "--stdio"]
```

Servers absent from `mcp.local.yaml` are not installed. A server listed with `{}` uses the base config unchanged. Any key present in a local entry (args, env, tools, command) replaces the base value for that key — no deep merge within a key, full replacement.

If `mcp.local.yaml` is missing the plugin warns and exits cleanly without installing anything.

## Secrets (.env)

```
SHORTCUT_API_TOKEN=sct_...
GITHUB_PERSONAL_ACCESS_TOKEN=github_pat_...
CIRCLECI_TOKEN=CCIPAT_...
BIGQUERY_PROJECT=financial-operations-...
DATAPLEX_PROJECT=data-production-...
```

The plugin reads this file and expands referenced values into launchd plist `EnvironmentVariables`. Secrets never appear in committed files.

## launchd plists

Generated to `~/Library/LaunchAgents/` with label `me.hattori.dotbot.mcp.<name>`.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>me.hattori.dotbot.mcp.shortcut</string>

  <key>ProgramArguments</key>
  <array>
    <string>npx</string>
    <string>-y</string>
    <string>@shortcut/mcp@latest</string>
  </array>

  <key>Sockets</key>
  <dict>
    <key>MCP</key>
    <dict>
      <key>SockPathName</key>
      <string>/tmp/me.hattori.dotbot.mcp.shortcut.sock</string>
      <key>SockType</key>
      <string>stream</string>
    </dict>
  </dict>

  <key>inetdCompatibility</key>
  <dict>
    <key>Wait</key>
    <false/>
  </dict>

  <key>EnvironmentVariables</key>
  <dict>
    <key>SHORTCUT_API_TOKEN</key>
    <string>sct_actual_value_from_env</string>
  </dict>
</dict>
</plist>
```

`inetdCompatibility` with `Wait: false` means launchd spawns a new process per connection with stdio wired to the socket. No `KeepAlive` — server only runs while a connection is open.

## bridge.sh

A generic script committed to the repo. Tool configs reference it by absolute path.

```bash
#!/usr/bin/env bash
# ABOUTME: Bridges stdio to a Unix domain socket for MCP server connections.
# ABOUTME: Takes socket path as first argument.
exec nc -U "$1"
```

Uses macOS system `nc` (netcat), no additional dependencies.

## Tool config generation

The plugin writes the `mcpServers` key (Claude Desktop, Cursor) or `context_servers` key (Zed) in each tool's config file. It reads the existing config, replaces only the MCP-managed key, and writes it back — other settings in those files are untouched.

**Claude Desktop** (`~/Library/Application Support/Claude/claude_desktop_config.json`):
```json
{
  "mcpServers": {
    "shortcut": {
      "command": "/Users/rhattori/dot/mcp/bridge.sh",
      "args": ["/tmp/me.hattori.dotbot.mcp.shortcut.sock"]
    }
  }
}
```

**Cursor** (`~/.cursor/mcp.json`):
```json
{
  "mcpServers": {
    "shortcut": {
      "command": "/Users/rhattori/dot/mcp/bridge.sh",
      "args": ["/tmp/me.hattori.dotbot.mcp.shortcut.sock"]
    }
  }
}
```

## Dotbot plugin behavior

On each `./install` run:

1. Read base server config from directive data in `install.conf.yaml`
2. Read `mcp/mcp.local.yaml` — warn and exit if missing
3. Merge: local entries override base entries key-by-key
4. Read `mcp/.env`
5. For each enabled server:
   - Generate plist to `~/Library/LaunchAgents/me.hattori.dotbot.mcp.<name>.plist`
   - Unload if already loaded (`launchctl unload`), then load (`launchctl load`)
6. Cleanup: find all `me.hattori.dotbot.mcp.*.plist` files in LaunchAgents not matching an enabled server — unload and delete them
7. For each tool with at least one enabled server: generate tool config

## install script change

```bash
"${BASEDIR}/${DOTBOT_DIR}/${DOTBOT_BIN}" -d "${BASEDIR}" -c "${CONFIG}" --plugin-dir dotbot_plugins "${@}"
```

## Future: streamable HTTP support

This design covers stdio servers only. MCP's streamable HTTP transport (spec version 2025-03-26) is a natural follow-on. HTTP servers need no launchd management — the plugin would write URL and headers directly to tool configs, with secrets still sourced from `.env`. The config distinction would be `command` (stdio) vs `url` (HTTP). Remote HTTP servers like the GitHub Copilot MCP endpoint already work this way.

## Testing

- Unit tests for config merge logic (base + local override)
- Unit tests for plist generation (correct XML, secrets expanded, correct label format)
- Unit tests for tool config generation (only MCP key replaced, other keys preserved)
- Integration test: full plugin run against a temp directory, verify generated files
- No e2e tests against real launchd — too environment-dependent
