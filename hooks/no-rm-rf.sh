#!/bin/bash
# no-rm-rf.sh - Block rm -rf commands, suggest trash instead

input=$(cat)
cmd=$(echo "$input" | jq -r '.tool_input.command // empty')

if [ -z "$cmd" ]; then
  exit 0
fi

# Block any rm -rf or rm -r -f variations
if echo "$cmd" | grep -qE 'rm\s+(-[a-zA-Z]*r[a-zA-Z]*f|-[a-zA-Z]*f[a-zA-Z]*r|\s+-r\s+-f|\s+-f\s+-r)'; then
  jq -n '{
    permissionDecision: "deny",
    permissionDecisionReason: "rm -rf is blocked. Use `trash` instead for safe deletion with recovery option."
  }'
  exit 0
fi

exit 0
