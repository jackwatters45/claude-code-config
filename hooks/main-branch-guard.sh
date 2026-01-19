#!/bin/bash
# Block file edits on main/master branch

# Only check for file-editing tools
TOOL="$CLAUDE_TOOL_NAME"
[[ ! "$TOOL" =~ ^(Edit|Write|MultiEdit)$ ]] && exit 0

# Get current branch
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)

if [[ "$BRANCH" == "main" || "$BRANCH" == "master" ]]; then
  cat <<EOF
{"blocked":true,"reason":"Cannot edit files on $BRANCH. Create a feature branch first:\n\ngit checkout -b feature/your-change"}
EOF
  exit 2
fi

exit 0
