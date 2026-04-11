# ABOUTME: Dotbot plugin that manages MCP servers as launchd agents with socket activation.
# ABOUTME: Reads server definitions from install.conf.yaml and mcp/mcp.local.yaml.
import os
import subprocess

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

import dotbot


class McpPlugin(dotbot.Plugin):
    def __init__(self, context, log=None):
        super().__init__(context)
        if log is not None:
            self._log = log

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
                self._log.warning(f"MCP: failed to load {name}: {result.stderr.strip()}")

        cleanup_stale_plists(enabled)
        update_tool_configs(enabled, base_dir)

        return True
