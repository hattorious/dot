# JSON Sorting Design

**Date:** 2026-04-10  
**Status:** Approved

## Goal

Reduce noisy git diffs caused by tools rewriting JSON config files in non-deterministic key order. Enforce consistent, sorted JSON across the dotfiles repo via a Makefile target (for bulk normalization) and a pre-commit hook (for ongoing enforcement).

## Scope

All `.json` and `.jsonc` files in the repo, excluding vendor/generated directories:

- `vim/vim_runtime/plugins/`
- `tmp/`
- `dotbot/`
- `.git/` (excluded automatically by pre-commit and `fd`)

## Architecture

Three components, all backed by a single Python script:

```
scripts/sort-json.py         ← sorting engine (PEP 723, uv run)
Makefile (sort-json target)  ← manual bulk normalization entrypoint
.pre-commit-config.yaml      ← auto-sorts staged JSON files on commit
```

The script is the single source of truth for sorting logic. Both the Makefile target and the pre-commit hook invoke it directly — no duplicated logic.

## Component Design

### `scripts/sort-json.py`

**Dependencies:** `commentjson` (declared via PEP 723 inline metadata, managed by uv)

**Interface:** accepts one or more file paths as positional arguments, sorts in-place.

**Behavior:**
- Uses `commentjson` for all files — handles both plain JSON and JSONC (JSON with `//` and `/* */` comments), preserving comments through the sort
- Recursively sorts all object keys at all nesting levels
- Arrays are not reordered — only object keys
- Indentation is detected from the original file (first indent level); defaults to 2 spaces
- Trailing newline is preserved if present
- Parse failures are hard errors: exits 1 with a descriptive message, blocking the commit

### Makefile target

Uses `fd` (required: `brew install fd`) for clean exclude syntax and automatic `.gitignore` respecting.

```makefile
sort-json:
	fd --extension json \
	    --exclude "vim/vim_runtime/plugins" \
	    --exclude "tmp" \
	    --exclude "dotbot" \
	    --exec-batch uv run scripts/sort-json.py

.PHONY: sort-json
```

Use `make sort-json` for the initial normalization pass and ad-hoc use.

### `.pre-commit-config.yaml`

Local hook using `language: system` — no separate hook environment, uv manages script dependencies.

```yaml
repos:
  - repo: local
    hooks:
      - id: sort-json
        name: Sort JSON keys
        language: system
        entry: uv run scripts/sort-json.py
        types: [json]
        exclude: |
          (?x)^(
            vim/vim_runtime/plugins/|
            tmp/|
            dotbot/
          )
```

**Hook behavior:** fix-in-place — the script modifies files and pre-commit re-stages them. Commits proceed without requiring a manual re-run.

## Dependencies

| Tool | Install | Purpose |
|------|---------|---------|
| `uv` | Brewfile | Runs the Python script with inline deps |
| `fd` | Brewfile (`brew install fd`) | Clean file discovery in Makefile target |
| `commentjson` | PEP 723 inline (auto via uv) | JSONC-aware parsing with comment preservation |
| `pre-commit` | Brewfile | Hook framework |

## Bootstrap on a New Machine

1. `brew bundle` — installs `uv`, `fd`, `pre-commit`
2. `pre-commit install` — registers the git hook
3. `make sort-json` — normalize all existing JSON files
4. Commit the normalized files

No manual pip installs or venv setup required.

## Decisions Log

- **Custom script over `pre-commit/pre-commit-hooks` `pretty-format-json`:** The bundled hook uses stdlib `json`, which cannot parse JSONC. Required custom implementation to support `zed/settings.json` and other JSONC files.
- **`commentjson` over manual tokenizer:** Handles comment preservation without needing a hand-rolled JSONC tokenizer.
- **`fd` over `find`:** Cleaner exclude syntax, `.gitignore`-aware by default.
- **Fix-in-place hook:** Lower friction than fail-and-report for a dotfiles workflow.
- **Hard fail on parse errors:** Malformed JSON should block commits, not be silently skipped.
