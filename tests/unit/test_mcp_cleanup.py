# ABOUTME: Unit tests for cleanup_stale_plists — removes launchd plists for disabled servers.
# ABOUTME: Verifies launchctl is called before deletion and enabled plists are untouched.
from unittest.mock import patch

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

    mock_run.assert_called_once_with(["launchctl", "unload", str(stale)], capture_output=True)


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
