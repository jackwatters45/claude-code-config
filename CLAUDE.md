# Ralph PRD System

PRD-based incremental feature development for Claude Code.

## Commands

- `/init-prd` - Initialize PRD structure
- `/ralph-prd "task"` - Run PRD-aware development loop
- `/ralph-test` - Run test coverage loop (one test per iteration)
- `/archive-prd [version]` - Archive completed PRD + extract learnings to CLAUDE.md

## File Structure

```
project/
├── plans/
│   ├── prd.json         # Feature list (flat array)
│   ├── progress.txt     # PRD session history
│   ├── test-progress.txt # Test coverage history
│   └── archive/         # Completed PRDs by version
└── .ralph/
    └── init.sh          # Project dev setup
```

## PRD Format

Flat JSON array:
```json
[
  {
    "id": "auth-001",
    "category": "user-flow",
    "description": "User can log in",
    "passes": false,
    "steps": ["Navigate to /login", "Enter credentials", "Verify redirect"]
  }
]
```

## Rules

1. **ONE feature per iteration**
2. **CI must pass** - `bun run typecheck && bun run test`
3. **Commit per feature**
4. **Revert on failure** - `git checkout -- .`
5. **Document in progress.txt**

## Workflow

```
/init-prd              # Create plans/prd.json, plans/progress.txt
# Edit plans/prd.json with features
/ralph-prd "implement" # Loop until all pass
/ralph-test            # Loop until coverage target (default 80%)
/archive-prd v1.0.0    # Archive, extract learnings, reset
```

## Knowledge Capture

Learnings are captured at two levels:

**During development (`/ralph-prd`):**
- AGENTS.md — reusable patterns discovered while implementing
- progress.txt — session-specific gotchas and notes

**At archive (`/archive-prd`):**
- Review progress.txt for recurring patterns
- Extract generalizable learnings to project root `CLAUDE.md`

## Plan Mode

- Make the plan extremely concise. Sacrifice grammar for the sake of concision.
- At the end of each plan, give me a list of unresolved questions to answer, if any.
