# ABOUTME: Snapshot of lazygit default keybindings for reference.
# ABOUTME: Avoids re-fetching upstream docs every session. Update when upgrading lazygit.

# Lazygit Default Keybindings Reference

Snapshot from upstream docs (2026-03):
https://raw.githubusercontent.com/jesseduffield/lazygit/refs/heads/master/docs/Config.md

## Universal (highest priority — cannot be overridden per-context)

| Key | Action |
|-----|--------|
| `<space>` | select (multi-select toggle) |
| `<enter>` | confirm / context-dependent |
| `<esc>` | cancel / close |
| `h` | prev panel |
| `l` | next panel |
| `j` | cursor down |
| `k` | cursor up |
| `<tab>` | togglePanel / nextBlock |
| `<backtab>` | prevBlock |
| `q` | quit |
| `?` | help |
| `e` | edit config |
| `i` | filter files |
| `n` | next match |
| `o` | open link |
| `z` | undo |
| `Z` | redo |
| `0`–`5` | jump to panel |
| `/` | search |
| `m` | view merge options |
| `P` | push |
| `p` | pull |
| `R` | refresh |
| `W` | diffing menu |
| `@` | undo/redo menu |

## Files Context

| Key | Action |
|-----|--------|
| `c` | commit (default — remapped in this config) |
| `C` | commit with editor (default — remapped) |
| `a` | stage all |
| `s` | stage file (custom in this config) |
| `u` | unstage (custom in this config) |
| `-` | toggle staged (custom in this config) |
| `d` | view discard options |
| `D` | reset options |
| `e` | edit file |
| `f` | fetch |
| `i` | add to gitignore |
| `r` | refresh |
| `w` | open worktree menu |
| `x` | open command menu |
| `A` | amend last commit |
| `C` | commit (alt) |
| `F` | fetch all |
| `M` | open merge tool |
| `S` | stash all |
| `` ` `` | toggle range select |
| `=` | expand all |
| `y` | copy to clipboard |
| `;` | **goInto — toggle directory open/close (CUSTOM)** |

## Confirmed Free Keys (files context, verified 2026-03)

- `;` — now used for `goInto`
- `'` — free
- `b` — free
- `g` — free
- `t` — free

## This Config's Custom Keybindings

| Key | Action | Notes |
|-----|--------|-------|
| `;` | goInto (toggle dir) | universal, replaces default `<enter>` habit |
| `s` | stage file | customCommand, fugitive-style |
| `u` | unstage file | customCommand, fugitive-style |
| `-` | toggle staged | customCommand, fugitive-style |
| `X` | discard with confirm | customCommand, fugitive-style |
| `c` | commit in vim editor | remapped from default |
| `C` | commit inline | remapped from default |
| `<c-s>` | stash all | moved from `s` |
| `_` | collapseAll | moved from `-` |
| `+` | expandAll | moved from `=` |
