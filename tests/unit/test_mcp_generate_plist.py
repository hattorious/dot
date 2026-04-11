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
