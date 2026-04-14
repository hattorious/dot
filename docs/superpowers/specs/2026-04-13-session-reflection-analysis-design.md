# Session Reflection Analysis — Improvements Design

**Date:** 2026-04-13
**Scope:** Refactor the `session-reflection-analysis` skill to eliminate fixed output paths and extract inline bash into a standalone script.

---

## Problem Statement

Two issues with the current skill:

1. **Fixed output paths** — summary and reflection report are always written to `/tmp/session-summary.jsonl` and `/tmp/session-reflection-YYYY-MM-DD.md`. Concurrent sessions (or two runs on the same day) overwrite each other, causing intermingled output and wasted tokens re-analyzing wrong data.

2. **Inline bash** — the jq summarization block is embedded directly in `SKILL.md`. This is hard to maintain, not reusable across repos, and forces the AI to copy-paste shell commands manually every time.

**Out of scope:** Persisting outputs to git. Reflection reports contain session analysis that could reveal work patterns, tooling gaps, or process weaknesses. All outputs stay ephemeral in `/tmp`.

---

## Design

### New file: `summarize-session.sh`

Location: `claude/skills/session-reflection-analysis/summarize-session.sh`

Responsibilities:
- Auto-detect the Claude project folder from `pwd`
- Verify `jq` is installed, exit with a clear error if not
- Generate a unique output path: `/tmp/claude-session-summary-YYYYMMDD-HHMMSS-PID.jsonl`
- Run the jq transform to produce a token-reduced summary
- Print the output path to stdout so the calling process can capture it

Unique naming uses `$(date +%Y%m%d-%H%M%S)-$$` — timestamp for human readability, PID for concurrent-session safety.

### Updated file: `SKILL.md`

Changes:
- Step 1 (locate sessions): replace inline bash with `path=$(bash .../summarize-session.sh)`
- Step 2 (generate summary): remove the jq block entirely; script handles it
- Reflection report path: derived from the same timestamp — `/tmp/claude-session-reflection-YYYYMMDD-HHMMSS-PID.md` — passed to the subagent explicitly
- Add note: outputs are ephemeral, never commit to git

---

## File Layout After Change

```
claude/skills/session-reflection-analysis/
├── SKILL.md                  # updated: references script, uses dynamic paths
└── summarize-session.sh      # new: jq summarizer, prints output path
```

---

## Constraints

- Script must be portable bash — no Python, no uv, no repo-specific tooling
- `jq` is the only external dependency (already required by the skill)
- No outputs committed to git, ever
- Script is self-contained: works when copied to any repo's skill folder

---

## Testing

Manual verification:
1. Run skill from two terminal sessions simultaneously — confirm output paths differ
2. Run from a project with no `.jsonl` files — confirm clean error message
3. Run without `jq` installed — confirm clear install instructions in error output
