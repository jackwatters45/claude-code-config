# Global Claude Configuration

## Safety Rules

**NEVER use `rm -rf`** — Use `trash` instead. The `trash` CLI moves files to macOS Trash for recovery.

```bash
# ❌ NEVER
rm -rf some-directory

# ✅ ALWAYS
trash some-directory
```

## Workflow Philosophy (Compound Engineering)

Each unit of work should improve the system for future tasks.

**Time allocation for non-trivial tasks:**

- **40% Planning** — research patterns, check docs, review commits before coding
- **20% Work** — incremental commits, continuous validation
- **20% Review** — quality, security, performance, simplification opportunities
- **20% Compounding** — document patterns to CLAUDE.md/AGENTS.md

**Key principle:** Favor clarity over abstraction. Document insights continuously. Codify knowledge for reuse.

## Frontend Design (Anti-AI Aesthetics)

When building UIs, avoid generic AI-generated patterns:

**AVOID:** Inter/Arial fonts, blue-gray palettes, symmetric grids, cookie-cutter layouts, predictable spacing

**PREFER:** Bold aesthetic choices, asymmetry, texture/gradients, context-specific character, distinctive typography

For UI features, always include "Verify in browser using visual-feedback" as acceptance criteria.

---

# Ralph PRD System

PRD-based incremental feature development for Claude Code.

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
