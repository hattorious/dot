#!/usr/bin/env bash
# ABOUTME: Ghostty startup script — attaches to an existing tmux session or creates one.
# ABOUTME: Set as the `command` in ghostty/config.ghostty so every window lands in tmux.

SESSION="ghostty"

# Cover common tmux install locations across platforms (Homebrew, Linux system paths)
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

# Locate tmux, fall back to a plain shell if not found
TMUX_BIN="$(command -v tmux)"
if [[ -z "$TMUX_BIN" ]]; then
  echo "tmux not found — falling back to shell" >&2
  exec "${SHELL:-/bin/zsh}"
fi

if "$TMUX_BIN" has-session -t "$SESSION" 2>/dev/null; then
  exec "$TMUX_BIN" attach-session -t "$SESSION"
else
  exec "$TMUX_BIN" new-session -s "$SESSION"
fi
