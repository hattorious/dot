# ABOUTME: Pure functions for MCP server config management (no dotbot dependency).
# ABOUTME: Used by the dotbot mcp plugin and directly by unit and integration tests.
import glob  # noqa: F401
import json  # noqa: F401
import os  # noqa: F401
import plistlib  # noqa: F401
import subprocess  # noqa: F401


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
