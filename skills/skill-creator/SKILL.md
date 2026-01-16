---
name: skill-creator
description: Guide for creating Claude Code skills. Use when user wants to create a new skill, update an existing skill, or learn about skill structure. Triggers on "create a skill", "new skill", "build a skill", "skill for...", or questions about SKILL.md format.
---

# Skill Creator

Skills extend Claude's capabilities with specialized knowledge, workflows, and tools.

## Skill Anatomy

```
skill-name/
├── SKILL.md (required)     # YAML frontmatter + markdown instructions
├── scripts/                # Executable code (Python/Bash)
├── references/             # Documentation loaded on-demand
└── assets/                 # Files for output (templates, images)
```

**SKILL.md structure:**
```yaml
---
name: skill-name
description: What it does + when to trigger. Be specific about triggers.
---

# Skill Title

Instructions for Claude to follow...
```

## Core Principles

1. **Concise is key** - Only add context Claude doesn't already have
2. **Progressive disclosure** - SKILL.md <500 lines; details in references/
3. **Match freedom to fragility** - Specific scripts for fragile ops, flexible text for heuristics

## Creation Process

### Step 1: Understand with Examples
Ask user for concrete usage examples. What would trigger this skill? What output is expected?

### Step 2: Plan Reusable Contents
For each example, identify:
- Scripts needed (repeated code → scripts/)
- Reference docs (schemas, APIs → references/)
- Templates/assets (boilerplate → assets/)

### Step 3: Initialize
```bash
scripts/init_skill.py <skill-name> --path ~/.claude/skills
```
Creates template structure with example files.

### Step 4: Implement
1. Start with scripts and references (may need user input for assets)
2. Test scripts by running them
3. Write SKILL.md body with workflow instructions
4. Delete unused example files

**Frontmatter tips:**
- `description` is the primary trigger mechanism
- Include both what it does AND when to use it
- Example: "PDF processing for rotating, extracting, and editing PDFs. Use when user asks to rotate a PDF, extract text from PDF, or modify PDF pages."

### Step 5: Package
```bash
scripts/package_skill.py <skill-folder>
```
Validates and creates .skill file in ~/.claude/skills/

### Step 6: Iterate
Use skill on real tasks, note struggles, update accordingly.

## Design Patterns

- **Multi-step workflows**: See [references/workflows.md](references/workflows.md)
- **Output formats**: See [references/output-patterns.md](references/output-patterns.md)

## Don't Include

- README.md, CHANGELOG.md, or other auxiliary docs
- User-facing documentation (skills are for AI agents)
- Setup/installation guides
