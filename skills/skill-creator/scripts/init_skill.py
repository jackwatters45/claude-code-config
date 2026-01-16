#!/usr/bin/env python3
"""Initialize a new Claude Code skill with template structure."""

import argparse
import os
import sys
from pathlib import Path

SKILL_MD_TEMPLATE = '''---
name: {skill_name}
description: TODO - Describe what this skill does and when to use it. Include specific triggers like "when the user asks to..." or "use when working with..."
---

# {skill_title}

TODO: Add skill instructions here.

## When to Use

- TODO: List specific triggers and use cases

## Workflow

1. TODO: Step one
2. TODO: Step two

## Resources

- `scripts/example.py` - TODO: Describe script purpose
- `references/guide.md` - TODO: Describe reference content
'''

EXAMPLE_SCRIPT = '''#!/usr/bin/env python3
"""Example script - replace or delete this file."""

def main():
    print("Hello from {skill_name}!")

if __name__ == "__main__":
    main()
'''

EXAMPLE_REFERENCE = '''# Reference Guide

TODO: Add reference documentation here.

This file is loaded by Claude when needed, keeping SKILL.md lean.
'''

EXAMPLE_ASSET_README = '''# Assets

Place files here that Claude should use in output (templates, images, etc.)
but not load into context.

Examples:
- logo.png
- template.html
- boilerplate/
'''


def init_skill(skill_name: str, output_path: Path) -> Path:
    """Create a new skill directory with template files."""

    # Validate skill name
    if not skill_name.replace('-', '').replace('_', '').isalnum():
        print(f"Error: Invalid skill name '{skill_name}'. Use alphanumeric, hyphens, underscores only.")
        sys.exit(1)

    skill_dir = output_path / skill_name

    if skill_dir.exists():
        print(f"Error: Directory already exists: {skill_dir}")
        sys.exit(1)

    # Create directories
    (skill_dir / "scripts").mkdir(parents=True)
    (skill_dir / "references").mkdir()
    (skill_dir / "assets").mkdir()

    # Create SKILL.md
    skill_title = skill_name.replace('-', ' ').replace('_', ' ').title()
    skill_md = SKILL_MD_TEMPLATE.format(skill_name=skill_name, skill_title=skill_title)
    (skill_dir / "SKILL.md").write_text(skill_md)

    # Create example files
    example_script = EXAMPLE_SCRIPT.format(skill_name=skill_name)
    script_path = skill_dir / "scripts" / "example.py"
    script_path.write_text(example_script)
    script_path.chmod(0o755)

    (skill_dir / "references" / "guide.md").write_text(EXAMPLE_REFERENCE)
    (skill_dir / "assets" / "README.md").write_text(EXAMPLE_ASSET_README)

    return skill_dir


def main():
    parser = argparse.ArgumentParser(
        description="Initialize a new Claude Code skill",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s my-skill                    # Creates ./my-skill/
  %(prog)s my-skill --path ~/.claude/skills  # Creates ~/.claude/skills/my-skill/
"""
    )
    parser.add_argument("skill_name", help="Name of the skill (use hyphens, e.g., 'pdf-editor')")
    parser.add_argument("--path", "-p", type=Path, default=Path.cwd(),
                        help="Output directory (default: current directory)")

    args = parser.parse_args()

    skill_dir = init_skill(args.skill_name, args.path)

    print(f"Created skill: {skill_dir}")
    print(f"\nNext steps:")
    print(f"  1. Edit {skill_dir}/SKILL.md with your skill instructions")
    print(f"  2. Add scripts to {skill_dir}/scripts/")
    print(f"  3. Add references to {skill_dir}/references/")
    print(f"  4. Package with: package_skill.py {skill_dir}")


if __name__ == "__main__":
    main()
