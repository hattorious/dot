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
