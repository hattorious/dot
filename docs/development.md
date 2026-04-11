# Development

## Getting started

You need Homebrew. Everything else comes from:

```bash
make init    # installs brew deps, Python deps, pre-commit hooks
./install    # sets up dotfile symlinks via Dotbot
```

Both are idempotent.

## How .toolkit/ works

`.toolkit/` is the dev infrastructure for this repo — separate from the dotfiles themselves.

```
.toolkit/
├── Brewfile    # dev-only brew deps: fd, uv, pre-commit
└── main.mk     # included by the root Makefile
```

`make init` runs three things:
1. `brew bundle --file=.toolkit/Brewfile` — installs fd, uv, pre-commit
2. `uv sync --dev` — installs Python deps (commentjson, pytest, ruff) into `.venv`
3. `pre-commit install --install-hooks` — wires up the git hooks

The separation keeps dev tools out of the main `Brewfile`, which tracks tools you actually use day-to-day.

## Scripts

`scripts/sort_json.py` sorts JSON keys recursively in-place. It's invoked by `make sort-json` (whole repo) and the pre-commit hook (staged files only).

Tools like Zed rewrite config files with keys in arbitrary order. Sorting normalizes the output so `git diff` shows real changes, not key reordering noise.

The script handles JSONC (JSON with comments) via `commentjson`. Comments are stripped on write — that's a known tradeoff, since the tools that write these files also strip comments on save.

## Testing

Tests live in `tests/`, organized by level:

```
tests/
├── unit/         # pure function tests (sort_recursive, detect_indent)
├── integration/  # file I/O tests (sort_file, atomic writes)
└── e2e/          # subprocess tests that invoke the CLI directly
```

```bash
make test                      # run all tests
uv run pytest tests/unit -v    # just unit tests
```

Pre-commit hooks run on every `git commit`: ruff lint, ruff format, JSON key sort. Fix failures before committing — don't use `--no-verify`.

## JSON key sorting

`make sort-json` sorts everything in the repo. The pre-commit hook sorts staged JSON files only.

Excluded paths (vendor code or generated files):
- `vim/vim_runtime/plugins/`
- `tmp/`
- `dotbot/`
