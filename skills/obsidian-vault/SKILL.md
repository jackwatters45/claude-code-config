---
name: obsidian-vault
description: Apply Jack's Obsidian vault conventions when creating, editing, or organizing notes, categories, templates, or bases. Use when working in /Users/jw/obsidian/jacks-vault or when the user mentions Obsidian, notes, vault, daily notes, clippings, or categories.
---

# Jack's Obsidian Vault Conventions

## Vault Structure

```
/Users/jw/obsidian/jacks-vault/
├── Categories/         # Index pages (embed .base files)
├── Clippings/          # Web articles and clippings
├── Daily/              # Daily notes (YYYY-MM-DD.md)
├── Files/              # Attachments and files
├── References/         # Books, authors, reference material
├── Templates/          # Note templates
│   └── Bases/          # Dataview .base query files
├── Weekly/             # Weekly notes (YYYY-Www.md)
└── z_move/             # Staging area
```

## File Naming

| Type | Format | Example |
|------|--------|---------|
| Daily notes | `YYYY-MM-DD.md` | `2026-01-13.md` |
| Weekly notes | `YYYY-Www.md` | `2026-W02.md` |
| Books | Title as filename | `Atomic Habits.md` |
| Clippings | Article title | `How to Build a Second Brain.md` |
| People | Full name | `Richard Hamming.md` |

## Frontmatter Schemas

### Category Pages
```yaml
---
tags:
  - home              # If shown on home page
  - category-specific-tag
categories:
  - "[[CategoryName]]"
---
```

### Books
```yaml
---
categories:
  - "[[Books]]"
author: []
genre: []
cover:
pages:
year:
scoreGr:
rating:
language:
topics: []
created:
finished:
tags:
  - to-read           # or "reading", "books"
series: []
---
```

### Clippings
```yaml
---
categories:
  - "[[Clippings]]"
tags:
  - clippings
author: []
url: ""
created:
published:
topics: []
---
```

### People
```yaml
---
categories:
  - "[[People]]"
birthday:
org: []
linkedin:
instagram:
email:
phone:
created:
met:
last contact:
---
```

### Projects
```yaml
---
categories:
  - "[[Projects]]"
type: []
org: []
start:
year:
url:
status:
---
```

## Linking & Tags

- **Internal links**: `[[Note Name]]` or `[[Note Name|Display Text]]`
- **Category refs**: Always quote in frontmatter: `"[[Books]]"`
- **Embeds**: `![[filename]]` or `![[filename.base]]`
- **Tags**: lowercase, hyphenated (`#to-read`, `#self-improvement`)

### Common Tags
- Status: `#to-read`, `#reading`, `#books`
- Temporal: `#daily`, `#weekly`, `#monthly`
- Special: `#home` (appears on home page), `#0🌲` (evergreen)

## Base Files (.base)

Located in `Templates/Bases/`. Embedded with `![[Name.base]]`.

Structure:
```yaml
filters:
  and:
    - note.categories.contains(link("CategoryName"))
    - '!file.name.contains("Template")'
    - '!file.inFolder("Categories")'
properties:
  file.name:
    displayName: Name
views:
  - type: table
    name: All
    sort:
      - property: created
        direction: DESC
```

## Creating New Content

### New Category
1. Create `Categories/CategoryName.md`
2. Create `Templates/Bases/CategoryName.base`
3. Optionally create `Templates/CategoryName Template.md`
4. Add frontmatter with tags and self-referencing category
5. Embed the base: `![[CategoryName.base]]`

### New Note
1. Check if similar note exists first
2. Place in correct folder
3. Use appropriate template if available
4. Fill frontmatter completely
5. Use YYYY-MM-DD for dates

## Rules

**DO:**
- Preserve existing frontmatter when editing
- Use `[[]]` syntax for internal links
- Match existing tag conventions
- Create in appropriate folders
- Use templates when available

**DON'T:**
- Modify `.obsidian/` config
- Change `.base` files without explicit request
- Remove existing frontmatter fields
- Create duplicates without checking
- Add images to root (use Files/)

## Git Tracking

Whitelist approach - only tracked:
- `Templates/` and `Templates/**`
- `.obsidian/` (except workspace.json, graph.json)
- `Categories/` (added recently)

Clippings, Daily, Weekly, References are NOT tracked.
