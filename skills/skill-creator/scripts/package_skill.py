#!/usr/bin/env python3
"""Validate and package a Claude Code skill into a .skill file."""

import argparse
import os
import re
import sys
import zipfile
from pathlib import Path

DEFAULT_OUTPUT = Path.home() / ".claude" / "skills"


def validate_skill(skill_dir: Path) -> list[str]:
    """Validate skill structure and return list of errors."""
    errors = []

    # Check SKILL.md exists
    skill_md = skill_dir / "SKILL.md"
    if not skill_md.exists():
        errors.append("Missing required file: SKILL.md")
        return errors

    content = skill_md.read_text()

    # Check frontmatter
    if not content.startswith("---"):
        errors.append("SKILL.md must start with YAML frontmatter (---)")
        return errors

    # Extract frontmatter
    parts = content.split("---", 2)
    if len(parts) < 3:
        errors.append("SKILL.md frontmatter not properly closed (missing second ---)")
        return errors

    frontmatter = parts[1].strip()

    # Check required fields
    if not re.search(r'^name:\s*\S', frontmatter, re.MULTILINE):
        errors.append("SKILL.md frontmatter missing 'name' field")

    if not re.search(r'^description:\s*\S', frontmatter, re.MULTILINE):
        errors.append("SKILL.md frontmatter missing 'description' field")

    # Check description quality
    desc_match = re.search(r'^description:\s*(.+?)(?=\n\w+:|$)', frontmatter, re.MULTILINE | re.DOTALL)
    if desc_match:
        description = desc_match.group(1).strip()
        if len(description) < 50:
            errors.append(f"Description too short ({len(description)} chars). Add more detail about when to use this skill.")
        if "TODO" in description:
            errors.append("Description contains TODO placeholder - please complete it")

    # Check for body content
    body = parts[2].strip()
    if len(body) < 50:
        errors.append("SKILL.md body is too short - add instructions for using the skill")

    # Check for extraneous files
    bad_files = ["README.md", "CHANGELOG.md", "INSTALLATION_GUIDE.md", "QUICK_REFERENCE.md"]
    for bad in bad_files:
        if (skill_dir / bad).exists():
            errors.append(f"Remove extraneous file: {bad} (not needed in skills)")

    return errors


def package_skill(skill_dir: Path, output_dir: Path) -> Path:
    """Create a .skill package from the skill directory."""
    skill_name = skill_dir.name
    output_file = output_dir / f"{skill_name}.skill"

    # Create zip file
    with zipfile.ZipFile(output_file, 'w', zipfile.ZIP_DEFLATED) as zf:
        for file_path in skill_dir.rglob("*"):
            if file_path.is_file():
                # Skip hidden files and __pycache__
                if any(part.startswith('.') or part == '__pycache__' for part in file_path.parts):
                    continue
                arcname = file_path.relative_to(skill_dir.parent)
                zf.write(file_path, arcname)

    return output_file


def main():
    parser = argparse.ArgumentParser(
        description="Validate and package a Claude Code skill",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=f"""
Examples:
  %(prog)s my-skill/                      # Validates and packages to {DEFAULT_OUTPUT}
  %(prog)s my-skill/ ./dist               # Packages to ./dist/
  %(prog)s my-skill/ --validate-only      # Only validate, don't package
"""
    )
    parser.add_argument("skill_dir", type=Path, help="Path to skill directory")
    parser.add_argument("output_dir", type=Path, nargs="?", default=DEFAULT_OUTPUT,
                        help=f"Output directory (default: {DEFAULT_OUTPUT})")
    parser.add_argument("--validate-only", "-v", action="store_true",
                        help="Only validate, don't create package")

    args = parser.parse_args()

    skill_dir = args.skill_dir.resolve()

    if not skill_dir.is_dir():
        print(f"Error: Not a directory: {skill_dir}")
        sys.exit(1)

    # Validate
    print(f"Validating: {skill_dir}")
    errors = validate_skill(skill_dir)

    if errors:
        print("\nValidation failed:")
        for error in errors:
            print(f"  - {error}")
        sys.exit(1)

    print("Validation passed!")

    if args.validate_only:
        sys.exit(0)

    # Package
    output_dir = args.output_dir.resolve()
    output_dir.mkdir(parents=True, exist_ok=True)

    output_file = package_skill(skill_dir, output_dir)
    print(f"\nPackaged: {output_file}")
    print(f"Size: {output_file.stat().st_size / 1024:.1f} KB")


if __name__ == "__main__":
    main()
