---
description: Archive completed PRD and progress to versioned folder
---

# Archive PRD

Archive current PRD and progress to a versioned folder, then reset for next cycle.

## Arguments

`$ARGUMENTS` = version string (e.g., `v0.1.0`, `v1.0.0`, `2024-Q1`)

## Your Task

1. **Validate PRD completion**
   ```bash
   cat plans/prd.json
   ```
   - Count features where `passes: false`
   - If incomplete, WARN and ask for confirmation
   - Show: "X of Y features passing. Archive anyway?"

2. **Determine version**
   - Use `$ARGUMENTS` if provided
   - Otherwise ask user for version string

3. **Create archive**
   ```bash
   mkdir -p plans/archive/$VERSION
   cp plans/prd.json plans/archive/$VERSION/
   cp plans/progress.txt plans/archive/$VERSION/
   ```

4. **Add summary to archived progress**
   Append to `plans/archive/$VERSION/progress.txt`:
   ```
   ---
   Archived: [ISO timestamp]
   Version: [version]
   Features: X/Y passing
   ```

5. **Extract learnings to CLAUDE.md**

   Review the archived `progress.txt` and `prd.json` for reusable knowledge:

   **Look for:**
   - Recurring gotchas/blockers across features
   - "When X, always do Y" patterns
   - Project-specific conventions discovered
   - Testing/verification insights
   - Dependency relationships worth documenting
   - Tooling quirks or workarounds

   **Add to:**
   - Project root `CLAUDE.md`

   **Format additions as actionable rules:**
   ```markdown
   ## [Category]
   - When modifying X, also update Y
   - Tests require Z running first
   - Use pattern A for feature type B
   ```

   **Skip if:**
   - No meaningful patterns emerged
   - Learnings were already captured in AGENTS.md during development
   - Notes are too feature-specific to generalize

   Ask user to confirm learnings before adding.

6. **Reset PRD**
   Create new `plans/prd.json`:
   ```json
   []
   ```

7. **Reset progress**
   Create new `plans/progress.txt`:
   ```
   Ralph Progress Log
   Started: [ISO timestamp]
   Previous: plans/archive/$VERSION/

   --- Session History ---
   ```

8. **Git commit**
   ```bash
   git add plans/ .claude/
   git commit -m "chore: archive PRD $VERSION

   Includes learnings extracted to CLAUDE.md"
   ```

9. **Report**
   - Archive location: `plans/archive/$VERSION/`
   - Learnings extracted to CLAUDE.md (if any)
   - PRD reset and ready for new features
