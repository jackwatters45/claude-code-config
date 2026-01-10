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

5. **Reset PRD**
   Create new `plans/prd.json`:
   ```json
   []
   ```

6. **Reset progress**
   Create new `plans/progress.txt`:
   ```
   Ralph Progress Log
   Started: [ISO timestamp]
   Previous: plans/archive/$VERSION/

   --- Session History ---
   ```

7. **Git commit**
   ```bash
   git add plans/
   git commit -m "chore: archive PRD $VERSION"
   ```

8. **Report**
   - Archive location: `plans/archive/$VERSION/`
   - PRD reset and ready for new features
