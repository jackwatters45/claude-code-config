---
description: Generate a technical spec from an Obsidian brainstorm note
allowed-tools: Read, Edit, Glob
---

# Generate Technical Spec

Generate a structured technical spec from the brainstorm section of an Obsidian feature note.

## Input

$ARGUMENTS - Path to Obsidian feature note (e.g., `LaxDB - Stats.md`)

If no path provided, search for feature notes in the vault:
```
Glob: /Users/jw/obsidian/jacks-vault/**/*.md with "status:" in frontmatter
```

## Process

1. **Read the feature note**
2. **Extract the ## Brainstorm section** (or all content if no section exists)
3. **Analyze and generate spec** covering:
   - Overview (1-2 sentences)
   - Requirements (functional + non-functional)
   - Technical approach (architecture, patterns)
   - Phases with tasks
   - Open questions
   - YAGNI items to defer
4. **Update the note:**
   - Add/replace ## Spec section
   - Update frontmatter: `status: speccing`
5. **Show diff** of what was added

## Spec Format

```markdown
## Spec

### Overview
[1-2 sentence summary of what this feature does]

### Requirements
- [ ] Functional requirement 1
- [ ] Functional requirement 2
- [ ] Non-functional: performance, security, etc.

### Technical Approach

#### Architecture
[Key architectural decisions]

#### Patterns to Follow
[Reference existing codebase patterns]

### Phases

#### Phase 1: MVP
- [ ] Task 1
- [ ] Task 2

#### Phase 2: Enhancement
- [ ] Task 3

### Open Questions
- [ ] Question needing resolution before implementation

### YAGNI (Defer)
- Feature X - not needed for MVP
- Feature Y - add later if validated
```

## Notes

- Preserve existing ## Brainstorm content unchanged
- If ## Spec already exists, ask before overwriting
- Reference the repo's existing spec if `repo_spec` is in frontmatter
- Keep the spec focused on "what" not "how to code it"
