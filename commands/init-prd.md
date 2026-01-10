---
description: Initialize PRD-based development structure for Ralph Loop
---

# Initialize PRD Structure

Create the PRD tracking files for incremental feature development.

## Your Task

1. **Check for existing files FIRST:**
   ```bash
   ls plans/prd.json plans/progress.txt 2>/dev/null
   ```
   - If `plans/prd.json` exists: **DO NOT overwrite** - tell user PRD already exists
   - If `plans/progress.txt` exists: **DO NOT overwrite** - tell user progress file already exists
   - If `.ralph/init.sh` exists: skip, don't overwrite
   - Only create files that don't exist
   - If all files exist, just report "Ralph PRD already initialized" and stop

2. Create `plans/` directory if it doesn't exist

3. Create `plans/prd.json` as a flat array:
```json
[]
```

4. Create `plans/progress.txt`:
```
Ralph Progress Log
Initialized: [ISO timestamp]

--- Session History ---
```

5. Create `.ralph/init.sh` (executable) for project-specific dev setup:
```bash
#!/usr/bin/env bash
set -euo pipefail
echo "Starting development environment..."
# Customize for your project:
# - bun run dev
# - docker-compose up -d
echo "Development environment ready."
```

6. After creation, show the user:
   - `plans/prd.json` - add your features here
   - `plans/progress.txt` - session history
   - `.ralph/init.sh` - customize for your dev environment
   - **Ensure `bun run typecheck` and `bun run test` work** (required for CI checks)
   - Start with: `/ralph-prd "implement all features"`

## PRD Feature Structure

The PRD is a flat JSON array. Each feature:
```json
{
  "id": "auth-001",
  "category": "user-flow",
  "description": "User can log in with email and password",
  "passes": false,
  "steps": [
    "Navigate to /login",
    "Enter valid credentials",
    "Verify redirect to dashboard"
  ]
}
```

### Fields

| Field | Required | Description |
|-------|----------|-------------|
| `id` | Yes | Unique identifier (used in commits) |
| `category` | Yes | Grouping for organization |
| `description` | Yes | What this feature does |
| `passes` | Yes | `false` until verified, then `true` |
| `steps` | Yes | Verification steps |
| `dependencies` | No | Array of feature IDs that must pass first |
