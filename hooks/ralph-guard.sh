#!/bin/bash
# ralph-guard.sh - Bash allowlist hook for Ralph autonomous mode
#
# Prompts user for commands not in allowlist.
# Change "ask" to "deny" for strict mode.

input=$(cat)
cmd=$(echo "$input" | jq -r '.tool_input.command // empty')

if [ -z "$cmd" ]; then
  exit 0  # Not a bash command, allow
fi

# Extract first command (before pipes, &&, etc)
first_cmd=$(echo "$cmd" | sed 's/[|&;].*//' | awk '{print $1}' | xargs basename 2>/dev/null || echo "$cmd")

# Allowlist for Ralph autonomous mode
ALLOWED="^(git|bun|npm|pnpm|yarn|node|npx|ls|cat|head|tail|grep|wc|ps|echo|cd|pwd|mkdir|cp|mv|rm|touch|chmod|find|which|type|test|true|false|exit|printf|read|sleep|date|jq|sed|awk|sort|uniq|tr|cut|tee|diff|vitest|jest|playwright|curl|wget)$"

# Blocked patterns (dangerous operations)
BLOCKED_PATTERNS="rm -rf /|rm -rf \"|sudo|\.env|credentials|secret|password|token"

# Check for blocked patterns first
if echo "$cmd" | grep -qE "$BLOCKED_PATTERNS"; then
  jq -n '{
    permissionDecision: "deny",
    permissionDecisionReason: "Command matches blocked pattern (dangerous operation)"
  }'
  exit 0
fi

# Check allowlist
if ! echo "$first_cmd" | grep -qE "$ALLOWED"; then
  jq -n --arg cmd "$first_cmd" '{
    permissionDecision: "ask",
    permissionDecisionReason: ("Command not in Ralph allowlist: " + $cmd)
  }'
  exit 0
fi

# Allowed
exit 0
