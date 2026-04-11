# ABOUTME: Pure functions for MCP server config management (no dotbot dependency).
# ABOUTME: Used by the dotbot mcp plugin and directly by unit and integration tests.
import glob  # noqa: F401
import json  # noqa: F401
import os  # noqa: F401
import plistlib  # noqa: F401
import subprocess  # noqa: F401

LABEL_PREFIX = "me.hattori.dotbot.mcp"
SOCKET_DIR = "/tmp"
LAUNCH_AGENTS_DIR = os.path.expanduser("~/Library/LaunchAgents")


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
