# ABOUTME: Pure functions for MCP server config management (no dotbot dependency).
# ABOUTME: Used by the dotbot mcp plugin and directly by unit and integration tests.
import glob
import json
import os
import plistlib
import shlex
import subprocess

LABEL_PREFIX = "me.hattori.dotbot.mcp"
SOCKET_DIR = "/tmp"
LAUNCH_AGENTS_DIR = os.path.expanduser("~/Library/LaunchAgents")

TOOL_CONFIG_PATHS: dict[str, str] = {
    "claude-desktop": os.path.expanduser(
        "~/Library/Application Support/Claude/claude_desktop_config.json"
    ),
    "cursor": os.path.expanduser("~/.cursor/mcp.json"),
    "claude-code": os.path.expanduser("~/.claude.json"),
    "gemini": os.path.expanduser("~/.gemini/settings.json"),
}

TOOL_MCP_KEY: dict[str, str] = {
    "claude-desktop": "mcpServers",
    "cursor": "mcpServers",
    "claude-code": "mcpServers",
    "gemini": "mcpServers",
}


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
                result[key.strip()] = value.strip()
    except FileNotFoundError:
        pass
    return result


def merge_local(base_servers: dict, local_servers: dict) -> dict:
    """Merge local server overrides into base server definitions.

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


def generate_plist(name: str, server: dict, env_values: dict) -> bytes:
    """Generate launchd plist XML bytes for an MCP server."""
    label = f"{LABEL_PREFIX}.{name}"
    sock_path = f"{SOCKET_DIR}/{label}.sock"

    args = [server["command"]] + server.get("args", [])

    # Keys absent from env_values are intentionally omitted (secret not configured on this machine).
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


def generate_tool_entry(name: str, base_dir: str) -> dict:
    """Generate the mcpServers entry for a single server (command + socket path)."""
    label = f"{LABEL_PREFIX}.{name}"
    sock_path = f"{SOCKET_DIR}/{label}.sock"
    bridge = os.path.join(base_dir, "mcp", "bridge.sh")
    return {"type": "stdio", "command": bridge, "args": [sock_path]}


def update_tool_configs(enabled: dict, base_dir: str) -> None:
    """Write mcpServers entries into each tool's config file.

    Reads the existing config, replaces the entire MCP servers key
    (removing any manually added entries), writes back.
    Other keys in the tool config are untouched.
    """
    tool_servers: dict[str, dict] = {}
    for name, server in enabled.items():
        # Servers with no 'tools' key are intentionally registered nowhere.
        for tool in server.get("tools", []):
            tool_servers.setdefault(tool, {})[name] = server

    for tool, servers in tool_servers.items():
        config_path = TOOL_CONFIG_PATHS.get(tool)
        if not config_path:
            continue
        mcp_key = TOOL_MCP_KEY.get(tool, "mcpServers")

        existing: dict = {}
        if os.path.exists(config_path):
            with open(config_path) as f:
                existing = json.load(f)

        existing[mcp_key] = {name: generate_tool_entry(name, base_dir) for name in servers}

        os.makedirs(os.path.dirname(config_path), exist_ok=True)
        with open(config_path, "w") as f:
            json.dump(existing, f, indent=2)
            f.write("\n")


def generate_wrapper_script(name: str, server: dict) -> str:
    """Return bash wrapper script content for an MCP server.

    The wrapper exec's into the real command so macOS Login Items shows the server name.
    """
    label = f"{LABEL_PREFIX}.{name}"
    log_path = f"/tmp/{label}.stderr.log"
    parts = [server["command"]] + server.get("args", [])
    quoted = " ".join(shlex.quote(p) for p in parts)
    return (
        "#!/usr/bin/env bash\n"
        f"# ABOUTME: Wrapper for MCP server '{name}' — sets process name for macOS Login Items.\n"
        'export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"\n'
        f"exec {quoted} 2>>{shlex.quote(log_path)}\n"
    )


def write_wrapper_scripts(enabled: dict, base_dir: str) -> dict[str, str]:
    """Write wrapper scripts to mcp/agents/ under base_dir.

    Creates the directory if needed. Sets each script executable.
    Returns a mapping of server name to absolute script path.
    """
    agents_dir = os.path.join(base_dir, "mcp", "agents")
    os.makedirs(agents_dir, exist_ok=True)
    paths: dict[str, str] = {}
    for name, server in enabled.items():
        script_path = os.path.join(agents_dir, f"mcp-{name}")
        content = generate_wrapper_script(name, server)
        with open(script_path, "w") as f:
            f.write(content)
        os.chmod(script_path, 0o755)
        paths[name] = script_path
    return paths


def cleanup_stale_wrappers(enabled: dict, base_dir: str) -> list[str]:
    """Remove wrapper scripts in mcp/agents/ whose name is not in enabled.

    Returns the list of removed server names.
    """
    agents_dir = os.path.join(base_dir, "mcp", "agents")
    if not os.path.isdir(agents_dir):
        return []
    removed = []
    expected = {f"mcp-{name}" for name in enabled}
    for entry in os.listdir(agents_dir):
        if entry not in expected:
            os.remove(os.path.join(agents_dir, entry))
            removed.append(entry)
    return removed


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
