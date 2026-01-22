#!/bin/bash
# ralph.sh - PRD-based story loop with fresh sessions
#
# Usage: ralph.sh [options]
#   -n, --max=N      Max iterations (default: 50)
#   -s, --scope=X    Test scope: wla|pll|nll|mll|msl (default: auto-detect from story ID)
#   -h, --help       Show this help

set -e

# Defaults
MAX_ITERATIONS=50
TEST_SCOPE_OVERRIDE=""

# Parse flags
while [[ $# -gt 0 ]]; do
  case $1 in
    -n|--max)
      MAX_ITERATIONS="$2"
      shift 2
      ;;
    --max=*)
      MAX_ITERATIONS="${1#*=}"
      shift
      ;;
    -s|--scope)
      TEST_SCOPE_OVERRIDE="$2"
      shift 2
      ;;
    --scope=*)
      TEST_SCOPE_OVERRIDE="${1#*=}"
      shift
      ;;
    -h|--help)
      echo "Usage: ralph.sh [options]"
      echo "  -n, --max=N      Max iterations (default: 50)"
      echo "  -s, --scope=X    Test scope: wla|pll|nll|mll|msl (default: auto-detect)"
      echo "  -h, --help       Show this help"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      echo "Use --help for usage"
      exit 1
      ;;
  esac
done

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

    # Determine test scope: manual override > auto-detect from story ID > full suite
    TEST_SCOPE="$TEST_SCOPE_OVERRIDE"
    if [ -z "$TEST_SCOPE" ]; then
      TEST_SCOPE=$(echo "$STORY" | grep -oE '^(wla|pll|nll|mll|msl)' || echo "")
    fi

    # Run CI
    CI_PASSED=true
    if ! bun run typecheck 2>&1 | tee "$RALPH_DIR/ci-$i.log"; then
      CI_PASSED=false
    fi

    # Scoped or full tests
    if [ -n "$TEST_SCOPE" ]; then
      echo "Running scoped tests: test:$TEST_SCOPE"
      if ! (cd packages/pipeline && bun run test:$TEST_SCOPE) 2>&1 | tee -a "$RALPH_DIR/ci-$i.log"; then
        CI_PASSED=false
      fi
    else
      # Prefer test:unit if available (skips integration tests), fall back to test
      if grep -q '"test:unit"' package.json 2>/dev/null; then
        echo "Running unit tests (test:unit found in package.json)"
        if ! bun run test:unit 2>&1 | tee -a "$RALPH_DIR/ci-$i.log"; then
          CI_PASSED=false
        fi
      else
        if ! bun run test 2>&1 | tee -a "$RALPH_DIR/ci-$i.log"; then
          CI_PASSED=false
        fi
      fi
    fi

    if [ "$CI_PASSED" = true ]; then
      echo "CI passed! Committing..."

      # Update PRD first (before commit so correct state is committed)
      jq "map(if .id == \"$STORY\" then .passes = true else . end)" "$PRD_FILE" > "$PRD_FILE.tmp"
      mv "$PRD_FILE.tmp" "$PRD_FILE"

      # Commit with updated PRD
      git add -A
      git commit -m "feat($STORY): $STORY_DESC" || true

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
