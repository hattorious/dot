# Session Reflection Analysis Improvements Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Extract the inline jq summarizer from SKILL.md into a portable bash script, and replace hardcoded `/tmp` output paths with unique timestamp+PID names.

**Architecture:** A new `summarize-session.sh` script handles project detection, jq summarization, and unique output naming — printing the output path to stdout. SKILL.md is updated to call the script and thread the returned path through to the subagent prompt.

**Tech Stack:** bash, jq

---

### Task 1: Baseline test (RED)

**Files:**
- Read: `claude/skills/session-reflection-analysis/SKILL.md`

- [ ] **Step 1: Confirm current skill hardcodes the output path**

Run:
```bash
grep -n "session-summary.jsonl\|session-reflection" /Users/rhattori/dot/claude/skills/session-reflection-analysis/SKILL.md
```

Expected output: lines referencing `/tmp/session-summary.jsonl` and `/tmp/session-reflection-` with a hardcoded date pattern. This is the failing baseline — document that these hardcoded paths exist.

---

### Task 2: Write `summarize-session.sh`

**Files:**
- Create: `claude/skills/session-reflection-analysis/summarize-session.sh`

- [ ] **Step 1: Create the script**

Write `claude/skills/session-reflection-analysis/summarize-session.sh`:

```bash
#!/usr/bin/env bash
# ABOUTME: Summarizes Claude Code session JSONL files into a token-reduced format.
# ABOUTME: Prints the output path to stdout for the caller to capture.

set -euo pipefail

# Verify jq is available
if ! command -v jq &>/dev/null; then
    echo "ERROR: jq is required but not installed." >&2
    echo "  macOS:        brew install jq" >&2
    echo "  Ubuntu/Debian: sudo apt install jq" >&2
    exit 1
fi

# Locate Claude project folder for current working directory
CURRENT_PATH=$(pwd | sed 's|^/||; s|/|-|g')
PROJECT_DIR="$HOME/.claude/projects/-${CURRENT_PATH}"

if [ ! -d "$PROJECT_DIR" ]; then
    echo "ERROR: No Claude session folder found for $(pwd)" >&2
    echo "  Expected: $PROJECT_DIR" >&2
    echo "  Available projects:" >&2
    ls "$HOME/.claude/projects/" >&2
    exit 1
fi

JSONL_FILES=("$PROJECT_DIR"/*.jsonl)
if [ ! -e "${JSONL_FILES[0]}" ]; then
    echo "ERROR: No .jsonl session files found in $PROJECT_DIR" >&2
    exit 1
fi

# Generate unique output path
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
OUTPUT="/tmp/claude-session-summary-${TIMESTAMP}-$$.jsonl"

# Summarize: extract user requests, tool names, assistant text (truncated)
cat "$PROJECT_DIR"/*.jsonl 2>/dev/null | jq -c '
select(.type == "user" or .type == "assistant") |
{
  type,
  ts: .timestamp,
  content: (
    if .message.content | type == "string" then
      .message.content[0:300]
    elif .message.content | type == "array" then
      [.message.content[] |
        if .type == "text" then {t: "text", v: .text[0:300]}
        elif .type == "tool_use" then {t: "tool", v: .name}
        elif .type == "tool_result" then {t: "result", len: (.content | length)}
        elif .type == "thinking" then empty
        else {t: .type}
        end
      ]
    else null
    end
  )
}' > "$OUTPUT" 2>/dev/null

echo "Summary: $(wc -l < "$OUTPUT") messages, $(wc -c < "$OUTPUT" | tr -d ' ') bytes" >&2

# Print output path to stdout for caller to capture
echo "$OUTPUT"
```

- [ ] **Step 2: Make it executable**

```bash
chmod +x /Users/rhattori/dot/claude/skills/session-reflection-analysis/summarize-session.sh
```

- [ ] **Step 3: Run the script and verify it works**

```bash
cd /Users/rhattori/dot
SUMMARY_PATH=$(bash claude/skills/session-reflection-analysis/summarize-session.sh)
echo "Output at: $SUMMARY_PATH"
ls -la "$SUMMARY_PATH"
```

Expected: script prints a summary line to stderr, then outputs a unique path like `/tmp/claude-session-summary-20260413-143022-12345.jsonl`. The file should exist and contain JSONL.

- [ ] **Step 4: Run a second instance and confirm paths differ**

```bash
cd /Users/rhattori/dot
PATH1=$(bash claude/skills/session-reflection-analysis/summarize-session.sh)
PATH2=$(bash claude/skills/session-reflection-analysis/summarize-session.sh)
echo "Path 1: $PATH1"
echo "Path 2: $PATH2"
[ "$PATH1" != "$PATH2" ] && echo "PASS: paths are unique" || echo "FAIL: paths are identical"
```

Expected: `PASS: paths are unique`

- [ ] **Step 5: Test missing jq error**

```bash
# Temporarily rename jq to simulate absence
JQ_PATH=$(which jq)
sudo mv "$JQ_PATH" "${JQ_PATH}.bak"
bash /Users/rhattori/dot/claude/skills/session-reflection-analysis/summarize-session.sh || true
sudo mv "${JQ_PATH}.bak" "$JQ_PATH"
```

Expected: error message with install instructions on stderr, exit code 1.

- [ ] **Step 6: Test missing project dir error**

```bash
cd /tmp
bash /Users/rhattori/dot/claude/skills/session-reflection-analysis/summarize-session.sh || true
```

Expected: `ERROR: No Claude session folder found for /tmp` with available projects listed.

- [ ] **Step 7: Commit**

```bash
git add claude/skills/session-reflection-analysis/summarize-session.sh
git commit -m "feat(skills): add summarize-session.sh to session-reflection-analysis"
```

---

### Task 3: Update `SKILL.md`

**Files:**
- Modify: `claude/skills/session-reflection-analysis/SKILL.md`

- [ ] **Step 1: Replace Step 1 and Step 2 in SKILL.md**

The current Steps 1 and 2 contain inline bash for project detection and jq summarization. Replace them with:

```markdown
## Step 1: Generate Session Summary

**CRITICAL**: Do NOT read raw session files directly. They are massive and will consume your entire token budget.

Run the summarizer script and capture the output path:

```bash
SUMMARY_PATH=$(bash "$(dirname "$0")/summarize-session.sh")
```

The script:
- Auto-detects the project folder from `pwd`
- Verifies `jq` is installed (exits with install instructions if not)
- Writes a token-reduced summary to a unique path in `/tmp`
- Prints the output path to stdout

If the script fails, check the error message — it will tell you whether jq is missing or no session files were found.

**Save the output path** — you will pass it to the subagent in the next step.
```

- [ ] **Step 2: Update Step 3 (subagent prompt) to use the dynamic path**

Find the subagent prompt section that references `/tmp/session-summary.jsonl` and update it to reference `$SUMMARY_PATH`. The reflection report path should be derived from the same timestamp:

```markdown
## Step 2: Launch Subagent for Analysis

Derive the reflection report path from the summary path:

```bash
REPORT_PATH="${SUMMARY_PATH/session-summary/session-reflection}"
REPORT_PATH="${REPORT_PATH/.jsonl/.md}"
```

Use the Agent tool to spawn an analysis subagent:

```
Task tool parameters:
- subagent_type: "Explore"
- prompt: |
    Analyze the session summary at <SUMMARY_PATH> for inefficiency patterns.
    Write your findings to <REPORT_PATH>.

    [... rest of analysis prompt unchanged ...]
```

Replace `<SUMMARY_PATH>` and `<REPORT_PATH>` with the actual values captured above.

**Important:** Both paths are ephemeral — they live in `/tmp` and are never committed to git.
```

- [ ] **Step 3: Add ephemeral outputs note to Critical Rules**

Add to the Critical Rules section:

```markdown
6. **NEVER commit outputs to git** — `/tmp` paths are ephemeral by design. Reflection reports contain session analysis that could reveal work patterns or process weaknesses.
```

- [ ] **Step 4: Verify the updated SKILL.md contains no hardcoded `/tmp/session-summary.jsonl`**

```bash
grep -n "session-summary.jsonl\|session-reflection-20" /Users/rhattori/dot/claude/skills/session-reflection-analysis/SKILL.md
```

Expected: no output (no hardcoded paths remain).

- [ ] **Step 5: Commit**

```bash
git add claude/skills/session-reflection-analysis/SKILL.md
git commit -m "feat(skills): update session-reflection-analysis to use unique output paths"
```

---

### Task 4: Skill compliance verification (GREEN)

**Files:**
- Read: `claude/skills/session-reflection-analysis/SKILL.md`

- [ ] **Step 1: Verify the skill instructs Claude to capture the script output path**

```bash
grep -n "SUMMARY_PATH\|summarize-session.sh" /Users/rhattori/dot/claude/skills/session-reflection-analysis/SKILL.md
```

Expected: lines showing `SUMMARY_PATH=$(bash .../summarize-session.sh)` and references to `$SUMMARY_PATH` in the subagent prompt instructions.

- [ ] **Step 2: Verify no hardcoded paths remain**

```bash
grep -rn "session-summary.jsonl\|/tmp/session-reflection-20" /Users/rhattori/dot/claude/skills/session-reflection-analysis/
```

Expected: no output.

- [ ] **Step 3: Push**

```bash
git push
```
