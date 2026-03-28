# Dotfiles

Clone then run `install` to set up. It's idempotent, re-run it anytime.

Uses [Dotbot](https://github.com/anishathalye/dotbot) to manage symlinks — see `install.conf.yaml` for the full mapping.

## Machine-specific config

Drop anything that shouldn't be in the repo into `~/.zshrc.local`. It's sourced at the end of `.zshrc` and won't be touched by the installer. Good for work-specific env vars, aliases, etc.
