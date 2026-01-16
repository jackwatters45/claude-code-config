#!/bin/bash
# ralph.sh - PRD-based story loop with fresh sessions
#
# Usage: ralph.sh [max_iterations]
# Default: 50 iterations

set -e

MAX_ITERATIONS=${1:-50}
PRD_FILE="plans/prd.json"
PROGRESS_FILE="plans/progress.txt"
CI_ERRORS_FILE="plans/ci_errors.txt"
RALPH_DIR=".ralph"

# Ensure directories exist
mkdir -p "$RALPH_DIR" plans

# Check PRD exists
if [ ! -f "$PRD_FILE" ]; then
  echo "Error: $PRD_FILE not found. Run /init-prd first."
  exit 1
fi

echo "=== Ralph Loop Starting ==="
echo "Max iterations: $MAX_ITERATIONS"
echo ""

for ((i=1; i<=MAX_ITERATIONS; i++)); do
  echo "=== Iteration $i/$MAX_ITERATIONS ==="

  # Find first non-passing story
  STORY=$(jq -r '[.[] | select(.passes == false)] | .[0].id // empty' "$PRD_FILE")

  if [ -z "$STORY" ]; then
    echo "All stories complete!"
    echo ""
    echo "=== Summary ==="
    jq -r '.[] | "\(.id): \(if .passes then "PASS" else "FAIL" end)"' "$PRD_FILE"
    exit 0
  fi

  STORY_DESC=$(jq -r ".[] | select(.id == \"$STORY\") | .description" "$PRD_FILE")
  echo "Story: $STORY"
  echo "Description: $STORY_DESC"
  echo ""

  # Build prompt
  PROMPT="You are in Ralph harness mode. Fresh session, no prior context.

Read plans/prd.json and plans/progress.txt for context.

Implement story: $STORY
Description: $STORY_DESC

When done, output exactly one of:
- STORY_COMPLETE (ready for CI)
- STORY_BLOCKED: <reason> (need human help, will skip to next)

Rules:
- ONE story only
- Follow existing code patterns
- Run typecheck and tests before signaling complete
- Do NOT run git commands (harness handles commits)"

  # Add error context if exists
  if [ -f "$CI_ERRORS_FILE" ]; then
    PROMPT="$PROMPT

Previous CI errors to fix:
$(cat "$CI_ERRORS_FILE")"
    rm "$CI_ERRORS_FILE"
  fi

  # Run claude (fresh session)
  echo "Running claude..."
  claude --dangerously-skip-permissions --print "$PROMPT" 2>&1 | tee "$RALPH_DIR/iteration-$i.log"

  # Check for signals
  if grep -q "STORY_COMPLETE" "$RALPH_DIR/iteration-$i.log"; then
    echo ""
    echo "Story signaled complete. Running CI..."

    # Run CI (adjust these commands for your project)
    CI_PASSED=true
    if ! bun run typecheck 2>&1 | tee "$RALPH_DIR/ci-$i.log"; then
      CI_PASSED=false
    fi
    if ! bun run test 2>&1 | tee -a "$RALPH_DIR/ci-$i.log"; then
      CI_PASSED=false
    fi

    if [ "$CI_PASSED" = true ]; then
      echo "CI passed! Committing..."

      # Commit
      git add -A
      git commit -m "feat($STORY): $STORY_DESC" || true

      # Update PRD
      jq "map(if .id == \"$STORY\" then .passes = true else . end)" "$PRD_FILE" > "$PRD_FILE.tmp"
      mv "$PRD_FILE.tmp" "$PRD_FILE"

      # Log progress
      {
        echo ""
        echo "=== Iteration $i ==="
        echo "Story: $STORY"
        echo "Description: $STORY_DESC"
        echo "Status: COMPLETE"
        echo "Commit: $(git rev-parse --short HEAD 2>/dev/null || echo 'none')"
        echo "Timestamp: $(date -Iseconds)"
      } >> "$PROGRESS_FILE"

      echo "Story $STORY complete!"
    else
      echo "CI failed. Saving errors for next iteration..."
      cp "$RALPH_DIR/ci-$i.log" "$CI_ERRORS_FILE"

      # Log failure (but keep changes)
      {
        echo ""
        echo "=== Iteration $i ==="
        echo "Story: $STORY"
        echo "Status: CI_FAILED"
        echo "Errors: See $CI_ERRORS_FILE"
        echo "Timestamp: $(date -Iseconds)"
      } >> "$PROGRESS_FILE"
    fi

  elif grep -q "STORY_BLOCKED" "$RALPH_DIR/iteration-$i.log"; then
    REASON=$(grep "STORY_BLOCKED" "$RALPH_DIR/iteration-$i.log" | sed 's/.*STORY_BLOCKED: *//')
    echo "Story blocked: $REASON"
    echo "Skipping to next story..."

    # Log blocker
    {
      echo ""
      echo "=== Iteration $i ==="
      echo "Story: $STORY"
      echo "Status: BLOCKED"
      echo "Reason: $REASON"
      echo "Timestamp: $(date -Iseconds)"
    } >> "$PROGRESS_FILE"

    # Don't exit, continue to next story
  else
    echo "No completion signal found. Check log: $RALPH_DIR/iteration-$i.log"
  fi

  echo ""
  sleep 3  # Brief pause between iterations
done

echo "=== Max iterations reached ==="
echo "Progress saved to $PROGRESS_FILE"
echo "Remaining stories:"
jq -r '.[] | select(.passes == false) | "  - \(.id): \(.description)"' "$PRD_FILE"
