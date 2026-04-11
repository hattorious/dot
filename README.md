# Dotfiles

## Install

```bash
./install    # set up symlinks (idempotent, re-run anytime)
```

Uses [Dotbot](https://github.com/anishathalye/dotbot). See `install.conf.yaml` for the full symlink map.

## Dev setup

Needs Homebrew. Everything else installs via:

```bash
make init    # brew deps, Python deps, git hooks
make test    # run the test suite
make lint    # check for issues
make fmt     # auto-fix
```

See [AGENTS.md](AGENTS.md) for tool ownership, config paths, theme values, and known gotchas.

## Machine-specific config

Anything that shouldn't live in the repo goes in `~/.zshrc.local`. It's sourced at the end of `.zshrc` and ignored by the installer.
