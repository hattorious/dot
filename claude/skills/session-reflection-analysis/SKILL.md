---
name: session-reflection-analysis
description: Use when asked to reflect on how the session went
---

# Session Reflection Analysis

Analyze recent chat history to identify improvement opportunities and reduce token waste in future sessions.

## Overview

This skill helps identify patterns of inefficiency in Claude Code sessions by analyzing session history. The analysis focuses on actionable improvements to documentation, automation, and workflows.

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

## Step 2: Launch Subagent for Analysis

Derive the reflection report path from the summary path:

```bash
REPORT_PATH="${SUMMARY_PATH/session-summary/session-reflection}"
REPORT_PATH="${REPORT_PATH/.jsonl/.md}"
```

**Important:** Both paths are ephemeral — they live in `/tmp` and are never committed to git.

Use the Agent tool to spawn an analysis subagent. Substitute the actual resolved values of `$SUMMARY_PATH` and `$REPORT_PATH` into the prompt string before dispatching:

```
Agent tool parameters:
- subagent_type: "Explore"
- prompt: |
    Analyze the session summary at <actual SUMMARY_PATH value> for inefficiency patterns.
    Write your findings to <actual REPORT_PATH value>.
    (Replace the angle-bracket placeholders with the real paths before dispatching.)

    Read the file and look for these patterns:

    | Pattern | Example | Impact |
    |---------|---------|--------|
    | **Wasted tokens** | Re-reading same file 5+ times | High |
    | **Wrong paths taken** | Implemented feature, then discovered existing code | Medium-High |
    | **Repeated mistakes** | Same error type in 3+ instances | Medium |
    | **Missing automation** | Manual steps repeated across sessions | Medium |
    | **Missing documentation** | Had to figure out what should be in CLAUDE.md | Medium |
    | **Unnecessary tool calls** | Called multiple tools when one would work | Low-Medium |
    | **Context loss after compaction** | Info that should survive in persistent docs | High |
    | **Assumption without verification** | Decisions made without checking existing code | High |

    For each pattern found, propose improvements as:
    1. CLAUDE.md updates
    2. New skills for .claude/skills/
    3. New slash commands for .claude/commands/
    4. Script automation
    5. Git hooks
    6. Workflow changes

    Make all proposals copy-paste ready with complete text/code.
    Quantify impact where possible (tokens saved, time saved).
    Be specific with examples from the actual session data.
```

## Step 3: Create Reflection Document

The subagent should generate a document with this structure:

```markdown
# Session Reflection: YYYY-MM-DD

## Summary Statistics
- Session date range: [start] to [end]
- Messages analyzed: [count]
- Major inefficiencies found: [count]

## Proposed Improvements

### High Priority

#### 1. [Problem Title]

**Problem observed**: [What went wrong - be specific with examples]

**Proposed solution**:
```
[Complete text/code to add or change - copy-paste ready]
```

**File to modify**: `path/to/file.md`

**Cost**: [Effort to implement, any downsides]

**Benefit**: [Time/tokens saved - quantify if possible]

---

### Medium Priority
...

### Low Priority
...

## Implementation Notes

[Cross-cutting concerns, dependencies, warnings]
```

## Step 4: Present Findings

After analysis completes:

1. **Summarize key findings** - 3-5 bullet points of major inefficiencies
2. **Show the reflection document path** - Where to find full details
3. **Ask which changes to implement** - Don't auto-implement

## Critical Rules

1. **NEVER read raw session files directly** - Always use the jq summary
2. **NEVER implement changes automatically** - Only propose them
3. **Make proposals copy-paste ready** - Complete text, not descriptions
4. **Quantify impact when possible** - "Saved 10K tokens" not "saves tokens"
5. **Be specific with examples** - "Re-read config.py 7 times" not "read files multiple times"
6. **NEVER commit outputs to git** — `/tmp` paths are ephemeral by design. Reflection reports contain session analysis that could reveal work patterns or process weaknesses.

## Example Analysis Output

```
High Priority Issues Found:

1. **Re-reading the same file repeatedly** (7 times in one session)
   - Propose: Add key architecture summaries to CLAUDE.md
   - Benefit: Save ~15K tokens per session

2. **Implemented feature without checking existing code first**
   - Took 3 iterations to match actual behavior
   - Propose: Add "Check existing code FIRST" rule to CLAUDE.md
   - Benefit: Prevent wrong-path implementations

3. **Manual repetitive commands**
   - Same shell commands typed each session
   - Propose: Create slash commands for common operations
   - Benefit: Save 2-3 minutes per session, prevent typos
```

## Troubleshooting

### Can't find project folder
```bash
# List all projects with recent activity
ls -lt ~/.claude/projects/ | head -10

# Search for a keyword in project names
ls ~/.claude/projects/ | grep -i "keyword"
```

### No jsonl files found
Sessions may not have been saved yet, or the project path detection failed. Check the folder manually.

### jq not installed
```bash
# macOS
brew install jq

# Ubuntu/Debian
sudo apt install jq

# Or use the standalone binary
curl -Lo /usr/local/bin/jq https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-macos-arm64
chmod +x /usr/local/bin/jq
```
