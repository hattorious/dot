# ABOUTME: Common shell aliases, sourced on all platforms.
# ABOUTME: Add aliases here that should work on macOS and Linux alike.

alias lg='lazygit'

# ag → sg migration reminder
function ag {
  echo "⚠ 'ag' is retired — use 'sg' (ast-grep) instead." >&2
  echo "  Your command: sg $*" >&2
  sg "$@"
}
