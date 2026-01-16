# Workflow Design Patterns

Patterns for multi-step processes and conditional logic in skills.

## Table of Contents
- [Sequential Workflows](#sequential-workflows)
- [Conditional Branching](#conditional-branching)
- [Error Handling](#error-handling)
- [User Interaction Points](#user-interaction-points)

## Sequential Workflows

For linear processes, use numbered steps with clear actions:

```markdown
## Workflow

1. Validate input file exists
2. Parse file contents
3. Transform data according to rules
4. Write output
5. Verify output integrity
```

**Key principles:**
- Each step should be independently verifiable
- Include validation checkpoints
- State what to do, not how to think about it

## Conditional Branching

When multiple paths exist, structure as decision tree:

```markdown
## Workflow

1. Analyze input type:
   - **PDF**: Use pdfplumber for extraction
   - **DOCX**: Use python-docx for parsing
   - **Image**: Use OCR via pytesseract

2. Based on content type, select processor...
```

Alternative: Use separate reference files per variant:
```
skill/
├── SKILL.md (selection logic)
└── references/
    ├── pdf-processing.md
    ├── docx-processing.md
    └── image-processing.md
```

## Error Handling

Define recovery strategies inline:

```markdown
## Error Handling

- **File not found**: Ask user to verify path
- **Permission denied**: Suggest chmod or run with elevated privileges
- **Parse error**: Report line number, suggest format check
- **API timeout**: Retry with exponential backoff (max 3 attempts)
```

## User Interaction Points

Mark where to pause for user input:

```markdown
## Workflow

1. Analyze codebase structure
2. **[USER INPUT]** Present analysis, get confirmation
3. Generate implementation plan
4. **[USER INPUT]** Review plan, approve or modify
5. Execute changes
6. **[USER INPUT]** Verify results
```

Use bold markers to highlight decision points where Claude should ask before proceeding.
