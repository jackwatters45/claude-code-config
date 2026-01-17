# Claude Code Configuration

Personal Claude Code configuration with custom commands, agents, skills, hooks, and scripts.

## Commands

Slash commands for common workflows. Invoke with `/command-name`.

| Command | Description |
|---------|-------------|
| `/init-prd` | Initialize PRD structure (`plans/prd.json`, `plans/progress.txt`) |
| `/ralph-prd` | PRD-aware development loop - implements features ONE at a time until all pass |
| `/ralph-test` | Test coverage loop - writes ONE test at a time until coverage target reached |
| `/archive-prd [version]` | Archive completed PRD to versioned folder, extract learnings to CLAUDE.md |

### Ralph PRD Workflow

```bash
/init-prd              # Create plans/prd.json, plans/progress.txt
# Edit plans/prd.json with features
/ralph-prd             # Loop until all features pass
/ralph-test            # Loop until coverage target (default 80%)
/archive-prd v1.0.0    # Archive, extract learnings, reset
```

## Agents

Custom subagents with specialized roles. Used via the Task tool.

| Agent | Model | Description |
|-------|-------|-------------|
| Explorer | Haiku | Fast codebase exploration and code search |
| Oracle | Opus | High-IQ debugging, architecture design, code review consultation |
| Librarian | Sonnet | Documentation lookup, open source exploration, knowledge synthesis |
| Document Writer | Sonnet | Technical documentation, README files, developer guides |

## Skills

Extended capabilities with specialized knowledge and tools.

| Skill | Description |
|-------|-------------|
| `agent-browser` | Browser automation for web testing, form filling, screenshots, data extraction |
| `debugging` | Systematic debugging workflow: reproduce, isolate, hypothesize, fix, verify |
| `pdf` | PDF processing: extract text/tables, merge, split, create, OCR |
| `skill-creator` | Guide for creating Claude Code skills |
| `visual-feedback` | Visual verification for frontend development using browser automation |

## Hooks

PreToolUse hooks for command validation.

| Hook | Matcher | Description |
|------|---------|-------------|
| `ralph-guard.sh` | Bash | Allowlist-based command validation for autonomous runs. Prompts for unknown commands, blocks dangerous patterns (`rm -rf /`, `sudo`, `.env` access) |

## Scripts

Standalone bash scripts for autonomous workflows.

| Script | Description |
|--------|-------------|
| `ralph.sh` | Bash harness for fresh-session autonomous runs. Script handles commits after CI passes. Default: 50 iterations |

### Usage

```bash
# Run autonomous PRD loop (fresh claude session per iteration)
~/.claude/scripts/ralph.sh [max_iterations]

# Example: run 20 iterations
~/.claude/scripts/ralph.sh 20
```

**Features:**
- Fresh `claude` CLI session per iteration (avoids context degradation)
- Script handles commits after CI passes (atomic, safe)
- Skip blocked stories (log and continue)
- Keep changes on failure + save `ci_errors.txt` for next iteration
- Signal protocol: `STORY_COMPLETE`, `STORY_BLOCKED: <reason>`

## Enabled Plugins

Official Claude Code plugins enabled in this configuration.

| Plugin | Description |
|--------|-------------|
| `exa-mcp-server` | Exa AI web search |
| `frontend-design` | Frontend design assistance |
| `context7` | Library documentation lookup |
| `feature-dev` | Feature development guidance |
| `commit-commands` | Git commit workflows |
| `github` | GitHub integration |
| `code-review` | Code review assistance |
| `ralph-loop` | Ralph loop plugin |
| `code-simplifier` | Code simplification |

## Configuration

### Model

Default model: `claude-opus-4-5-20251101`

### Status Line

Custom status line showing `user@host directory (branch)` with colored git branch.

### Permissions

Pre-approved commands for streamlined workflow:
- Git operations: `checkout`, `add`, `commit`, `push`, `pull`, `branch`, `fetch`, `stash`
- GitHub CLI: `gh pr create`, `gh issue create`
- File inspection: `cat`, `ls`, `grep`, `echo`
- Web tools: `WebFetch`, `WebSearch`

## File Structure

```
~/.claude/
├── agents/              # Custom subagent definitions
│   ├── document-writer.md
│   ├── explorer.md
│   ├── librarian.md
│   └── oracle.md
├── commands/            # Slash commands
│   ├── archive-prd.md
│   ├── init-prd.md
│   ├── ralph-prd.md
│   └── ralph-test.md
├── hooks/               # PreToolUse hooks
│   └── ralph-guard.sh
├── scripts/             # Standalone scripts
│   └── ralph.sh
├── skills/              # Custom skills
│   ├── agent-browser/
│   ├── debugging/
│   ├── pdf/
│   ├── skill-creator/
│   └── visual-feedback/
├── CLAUDE.md            # Global instructions
├── settings.json        # Configuration
└── README.md            # This file
```

## PRD Format

Features in `plans/prd.json`:

```json
[
  {
    "id": "auth-001",
    "category": "user-flow",
    "description": "User can log in",
    "passes": false,
    "steps": ["Navigate to /login", "Enter credentials", "Verify in browser"],
    "acceptanceCriteria": ["Redirects to dashboard", "Session cookie set"],
    "nonGoals": ["SSO support", "Password reset"],
    "successMetrics": ["Login <2s", "0 console errors"],
    "openQuestions": []
  }
]
```

**New fields:** `nonGoals` (scope boundaries), `successMetrics` (measurable outcomes), `openQuestions` (unresolved items)

## Knowledge Capture

Learnings are captured at two levels:

**During development (`/ralph-prd`):**
- `AGENTS.md` — reusable code-level patterns
- `progress.txt` — session-specific gotchas and notes

**At archive (`/archive-prd`):**
- Review `progress.txt` for recurring patterns
- Extract generalizable learnings to project `CLAUDE.md`
