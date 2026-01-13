---
name: obsidian-vault
description: Apply Jack's Obsidian vault conventions when creating, editing, or organizing notes, categories, templates, or bases. Use when working in /Users/jw/obsidian/jacks-vault or when the user mentions Obsidian, notes, vault, daily notes, clippings, or categories.
---

# Vault: `/Users/jw/obsidian/jacks-vault/`

## Structure
- `Categories/` - Index pages embedding `.base` files
- `Templates/Bases/` - Dataview query files (`.base`)
- `Templates/` - Note templates
- `Daily/` - Daily notes (`YYYY-MM-DD.md`)
- `Weekly/` - Weekly notes (`YYYY-Www.md`)
- `Clippings/` - Web articles
- `References/` - Books, authors
- `Files/` - Attachments

## Key Conventions
- **Links in frontmatter**: Always quote - `"[[Books]]"`
- **Embeds**: `![[filename.base]]`
- **Tags**: lowercase, hyphenated (`#to-read`)
- **Dates**: `YYYY-MM-DD` format

## Creating Categories
1. Create `Categories/Name.md` with frontmatter including `categories: ["[[Name]]"]`
2. Create `Templates/Bases/Name.base` with filters
3. Embed base in category page: `![[Name.base]]`

## Base File Pattern
```yaml
filters:
  and:
    - note.categories.contains(link("CategoryName"))
    - '!file.name.contains("Template")'
    - '!file.inFolder("Categories")'
views:
  - type: table
    sort: [{ property: created, direction: DESC }]
```

## Rules
- Preserve existing frontmatter when editing
- Check for existing notes before creating
- Use templates when available
- Don't modify `.obsidian/` config
- Don't change `.base` files without explicit request

## Git Tracked
Only: `Templates/`, `Categories/`, `.obsidian/` (except workspace.json)
