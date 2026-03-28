# ABOUTME: Common shell aliases, sourced on all platforms.
# ABOUTME: Add aliases here that should work on macOS and Linux alike.

alias lg='lazygit'

# ag → rg migration reminder
function ag {
  echo "⚠ 'ag' is retired — use 'rg' (ripgrep) instead." >&2
  echo "  Your command: rg $*" >&2
  rg "$@"
}
