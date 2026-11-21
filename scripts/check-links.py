#!/usr/bin/env python3
"""
scripts/check-links.py — Scans Markdown (.qmd, .md) and HTML files for broken local links and assets.
Zero external dependencies (Python 3 standard library only).
"""

import argparse
import html.parser
import os
import re
import sys
import urllib.parse
from pathlib import Path


class HTMLAttributeExtractor(html.parser.HTMLParser):
    """Extracts href and src attribute values from parsed HTML."""
    def __init__(self):
        super().__init__()
        self.links = []

    def handle_starttag(self, tag, attrs):
        for attr, val in attrs:
            if attr.lower() in ("href", "src") and val:
                self.links.append(val)


def is_external_or_anchor(link: str) -> bool:
    """Identifies remote URLs, protocols, and intra-page anchor links."""
    clean = link.strip()
    if clean.startswith(("#", "http://", "https://", "mailto:", "ftp://", "javascript:")):
        return True
    if clean.startswith("file://"):
        return False
    return False


def clean_link_target(link: str) -> str:
    """Strips query parameters and anchor fragments from link paths."""
    # Handle file:// scheme
    if link.startswith("file://"):
        link = link[7:]
    parsed = urllib.parse.urlparse(link)
    path = parsed.path
    return urllib.parse.unquote(path)


def audit_links(root_dir: Path) -> bool:
    """Scans all documents under root_dir and verifies local path targets."""
    if not root_dir.exists():
        sys.stderr.write(f"❌ Error: Root directory does not exist: {root_dir}\n")
        return False

    extensions = {".md", ".qmd", ".html"}
    files_to_check = [
        p for p in root_dir.rglob("*")
        if p.is_file()
        and p.suffix.lower() in extensions
        and not any(part.startswith(".") for part in p.relative_to(root_dir).parts)
    ]

    if not files_to_check:
        print(f"ℹ No Markdown or HTML files found under {root_dir}")
        return True

    # Regex patterns for Markdown links [text](path) and images ![alt](path)
    md_link_pattern = re.compile(r'!?\[.*?\]\(([^)\s]+)(?:\s+"[^"]*")?\)')

    broken_links = []
    total_links_checked = 0

    for file_path in sorted(files_to_check):
        content = file_path.read_text(encoding="utf-8", errors="replace")
        extracted_targets = []

        if file_path.suffix.lower() == ".html":
            parser = HTMLAttributeExtractor()
            try:
                parser.feed(content)
                extracted_targets.extend(parser.links)
            except Exception:
                pass
        else:
            # Strip fenced code blocks (``` ... ```) and inline code spans (`...`)
            text_no_code = re.sub(r'```.*?```', '', content, flags=re.DOTALL)
            text_no_code = re.sub(r'`[^`\n]+`', '', text_no_code)

            # Markdown link extraction
            for match in md_link_pattern.finditer(text_no_code):
                extracted_targets.append(match.group(1))

        for raw_target in extracted_targets:
            if is_external_or_anchor(raw_target):
                continue

            cleaned_path_str = clean_link_target(raw_target)
            if not cleaned_path_str:
                continue

            total_links_checked += 1

            target_path = Path(cleaned_path_str)
            # Resolve relative to current file's directory if not absolute
            if target_path.is_absolute():
                resolved = target_path
            else:
                resolved = (file_path.parent / target_path).resolve()

            if not resolved.exists():
                broken_links.append((file_path, raw_target, resolved))

    print(f"==> Audited {len(files_to_check)} document(s), checked {total_links_checked} local link(s)")

    if broken_links:
        sys.stderr.write(f"❌ Found {len(broken_links)} broken local link(s):\n")
        for source_file, raw_target, resolved in broken_links:
            rel_src = source_file.relative_to(root_dir) if source_file.is_relative_to(root_dir) else source_file
            sys.stderr.write(f"   In {rel_src}:\n")
            sys.stderr.write(f"      Referenced: '{raw_target}'\n")
            sys.stderr.write(f"      Resolved:   '{resolved}' (NOT FOUND)\n")
        return False

    print("✅ All local file references and assets successfully verified.")
    return True


def main():
    parser = argparse.ArgumentParser(
        description="Verify relative Markdown and HTML links and asset references across rendered sites or documentation.",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    parser.add_argument(
        "--root",
        type=Path,
        default=Path("."),
        help="Root directory containing Markdown or rendered HTML files to check",
    )

    args = parser.parse_args()

    if audit_links(args.root.resolve()):
        sys.exit(0)
    else:
        sys.exit(1)


if __name__ == "__main__":
    main()
