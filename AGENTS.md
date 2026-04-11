# Dotfiles — Agent Guide

## Overview

Personal dotfiles for Ross Hattori (Doctor Mario). Managed with
[dotbot](https://github.com/anishathalye/dotbot) via `install.conf.yaml`.
macOS primary, remote Ubuntu via SSH.

## Development

```bash
make init      # install brew deps, sync Python deps, install git hooks
make test      # run the test suite
make lint      # check for lint/format issues
make fmt       # auto-fix lint and format
make sort-json # normalize all JSON file keys in the repo
make help      # list all available targets
```

**Prerequisites:** Homebrew. Everything else is installed by `make init`.

**Tests** live in `tests/` (unit, integration, e2e). Written in pytest, run against `scripts/sort_json.py`.

**Pre-commit hooks** run automatically on `git commit`: ruff lint, ruff format, JSON key sort.

## Key Tools & Ownership

| Tool | Role | Config path |
|------|------|-------------|
| Ghostty | Terminal emulator | `ghostty/config.ghostty` |
| tmux | Session manager | `tmux/tmux.conf` |
| Zed | Primary IDE | `zed/settings.json`, `zed/keymap.json` |
| vim | Git commits, SSH editing | `vim/vim_runtime/vimrcs/` |
| zsh + zim | Shell | `zsh/runcom.zsh`, `zsh/zim/zimrc` |
| lazygit | Git TUI | `lazygit/config.yml` |
| git + delta | Version control | `git/gitconfig` |
| bat | Syntax-highlighted cat | `bat/themes/` |

## Theme: Rosé Pine Moon

All tools use Rosé Pine Moon. Key palette values:
- `base` #232136 · `surface` #2a273f · `overlay` #393552
- `text` #e0def4 · `subtle` #908caa · `muted` #6e6a86
- `pine` #3e8fb0 · `foam` #9ccfd8 · `iris` #c4a7e7
- `love` #eb6f92 · `gold` #f6c177 · `rose` #ea9a97

**Active tab / current window color is always `pine` (#3e8fb0)**, not `love`.

## File Structure

```
dot/
├── bash/               # Bash configs (legacy, mostly unused)
├── bat/themes/         # rose-pine.tmTheme for delta syntax highlighting
├── claude/             # Claude Code settings
├── ghostty/
│   ├── config.ghostty  # Theme, font, keybindings, initial-command
│   └── scripts/
│       └── tmux-startup.sh  # Auto-attach/create tmux session on launch
├── git/
│   └── gitconfig       # delta pager, diffconflicts mergetool, aliases
├── lazygit/
│   └── config.yml      # Rosé Pine Moon theme, fugitive-style keybindings
├── tmux/
│   └── tmux.conf       # Rosé Pine Moon palette, C-a prefix
├── vim/
│   └── vim_runtime/
│       ├── autoload/lightline/colorscheme/
│       │   └── rosepine_patched.vim  # Custom lightline colorscheme (pine tabs)
│       └── vimrcs/
│           └── plugins.vim  # vim-plug plugins + all plugin config
├── zed/
│   ├── keymap.json     # Vim keybindings (jk MUST be first entry)
│   ├── settings.json   # Editor settings, Rosé Pine Moon theme
│   └── themes/
│       └── solarized-dark.json  # Legacy (not active)
├── zsh/
│   ├── runcom.zsh      # Main zshrc — sources modular configs
│   ├── alias.common.zsh
│   ├── runcom.macos.zsh
│   └── zim/zimrc       # Zim module list (completion must be last group)
├── Brewfile
└── install.conf.yaml   # Dotbot symlink config
```

## Known Gotchas

### Zed — `jk` escape in insert mode
`jk` → normal mode binding **must be the first entry** in `keymap.json`.
Zed evaluates bindings top-down; any earlier binding shadowing `j` will
prevent `jk` from being recognized. Do not move it.

### Edit tool and unicode glyphs
The Edit tool strips unicode literals (powerline glyphs, nerd font icons)
from files like `plugins.vim` and `tmux.conf`. When editing lines that
contain these characters, use a Python script to patch the bytes directly:
```python
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()
content = content.replace('old', 'new\ue0b0')  # use \uXXXX escapes
with open(path, 'w', encoding='utf-8') as f:
    f.write(content)
```

### Ghostty keybinding syntax
- `|` is written as `shift+backslash` (not `pipe`)
- `cmd+minus` is hardcoded for font size — use `opt+minus` or `ctrl+minus`
- `ctrl+shift+\` sends escape sequences instead of intercepting — avoid

### tmux — true color
`default-terminal` must be `tmux-256color` (not `screen-256color`) and
`terminal-overrides` must include `",*256col*:Tc"` for 24-bit RGB in vim.

### XDG paths on macOS
`XDG_CONFIG_HOME=$HOME/.config` is set in `runcom.zsh`. Tools like
lazygit use `~/.config/lazygit/` instead of `~/Library/Application Support/`.
**Do not symlink into `~/Library/`** — use `~/.config/` and rely on XDG.

### compinit — double initialization
zim's `completion` module calls `compinit`. Do not call `compinit` manually
before `source ${ZIM_HOME}/init.zsh`. Setting `fpath` before zim is fine.

### lazygit keybinding system

**Context overrides don't work for universal keys.** Keys like `<space>` are
bound in `universal` and take precedence — you cannot override them per-context
(e.g. files). Setting `goInto: '<space>'` in `files` does nothing because
`universal.select: <space>` wins.

**Workflow for adding keybindings**: fetch the full defaults doc first, audit
what's taken in `universal` and the target context, then propose one change.
Reference: `lazygit/defaults-reference.md`

**Known conflicts to avoid**:
- `<space>` → `universal.select` (can't override per-context)
- `<enter>` → context-sensitive, do not remap
- `h` / `l` → panel navigation
- `f` in files → fetch
- `<tab>` → `universal.togglePanel`

**Confirmed free keys** (files context, verified 2026-03):
- `;` — in use as `goInto` (toggle directory open/close)
- `'` — free

**Agent instruction**: Before any lazygit keybinding work, read
`lazygit/defaults-reference.md` rather than fetching the upstream docs.

### vim lightline tab color
The active buffer tab uses a custom lightline colorscheme
(`rosepine_patched`) defined in `autoload/lightline/colorscheme/`. Editing
the lightline `colorscheme` key in `plugins.vim` without updating that file
will revert the tab to the upstream rosepine color (love/pink). The
`ColorScheme` autocmd approach does not work — the palette must be set in
the colorscheme file itself.

## Dotbot Symlinks

Run `./install` to apply. Key mappings:
- `~/.zshrc` → `zsh/runcom.zsh`
- `~/.tmux.conf` → `tmux/tmux.conf`
- `~/.gitconfig` → `git/gitconfig`
- `~/.vim_runtime/` → `vim/vim_runtime/`
- `~/.config/zed/` → `zed/**` (glob)
- `~/.config/ghostty/` → `ghostty/**` (glob)
- `~/.config/lazygit/config.yml` → `lazygit/config.yml`
- `~/.config/bat/themes/` → `bat/themes/`

## Adding a New Tool

1. Add to `Brewfile` if installable via brew
2. Create config in an appropriate subdirectory
3. Add symlink entry to `install.conf.yaml`
4. Run `./install`
5. Update this file

## lazygit Keybindings (fugitive-style)

| Key | Action | fugitive equiv |
|-----|--------|----------------|
| `s` | stage file | `s` |
| `u` | unstage file | `u` |
| `-` | toggle staged | `-` |
| `X` | discard (with confirm) | `X` |
| `c` | commit in vim editor | `cc` |
| `C` | commit in lazygit inline box | — |
| `A` | amend last commit | `ca` |
| `P` | push | `:Git push` |
| `p` | pull | `:Git pull` |
| `<c-s>` | stash | `s` (stash) |
