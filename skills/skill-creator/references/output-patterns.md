# Output Patterns

Patterns for skills that produce specific output formats.

## Table of Contents
- [Template-Based Output](#template-based-output)
- [Structured Data Output](#structured-data-output)
- [File Generation](#file-generation)
- [Quality Standards](#quality-standards)

## Template-Based Output

When output follows a consistent structure, provide templates in `assets/`:

```
skill/
├── SKILL.md
└── assets/
    ├── report-template.md
    ├── email-template.txt
    └── slides-template.pptx
```

Reference in SKILL.md:
```markdown
## Output Format

Use template from `assets/report-template.md`:
- Fill [TITLE] with project name
- Fill [DATE] with current date
- Fill [SUMMARY] with 2-3 sentence overview
```

## Structured Data Output

For JSON/YAML output, define schema inline:

```markdown
## Output Schema

```json
{
  "name": "string (required)",
  "version": "semver string",
  "dependencies": ["array of package names"],
  "config": {
    "debug": "boolean, default false"
  }
}
```

**Validation rules:**
- name: alphanumeric + hyphens only
- version: must be valid semver
```

## File Generation

When creating files, specify naming and location:

```markdown
## Generated Files

| File | Location | Purpose |
|------|----------|---------|
| `index.html` | project root | Main entry point |
| `styles.css` | `assets/` | Compiled styles |
| `config.json` | project root | Runtime config |

**Naming conventions:**
- Use kebab-case for files
- Use PascalCase for components
```

## Quality Standards

Define what "done" looks like:

```markdown
## Quality Checklist

Before completing:
- [ ] All TODOs resolved
- [ ] No hardcoded secrets
- [ ] Error messages are user-friendly
- [ ] Output validated against schema
- [ ] File permissions set correctly
```

For code output:
```markdown
## Code Standards

- Follow existing project conventions
- Include type hints (Python) or types (TypeScript)
- Add docstrings for public functions
- No unused imports
```
