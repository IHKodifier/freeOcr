#!/usr/bin/env python3
"""
build_seo_pages.py — Markdown to SEO HTML Compiler for freeOCR.me

Converts Markdown (.md) articles and blog posts in ./docs/ (e.g., ./docs/blog/*.md)
into 100/100 SEO-optimized static HTML files inside the web build output folder.

Zero HTML / Zero React authoring required. Authors write standard Markdown text files!
"""

import os
import sys
import glob
import re

def markdown_to_simple_html(md_text: str, title: str) -> str:
    """Converts basic markdown formatting into clean semantic HTML structure."""
    lines = md_text.splitlines()
    html_lines = []
    in_list = False

    for line in lines:
        stripped = line.strip()
        if not stripped:
            if in_list:
                html_lines.append("</ul>")
                in_list = False
            continue

        if stripped.startswith("# "):
            html_lines.append(f"<h1>{stripped[2:]}</h1>")
        elif stripped.startswith("## "):
            html_lines.append(f"<h2>{stripped[3:]}</h2>")
        elif stripped.startswith("### "):
            html_lines.append(f"<h3>{stripped[4:]}</h3>")
        elif stripped.startswith("- "):
            if not in_list:
                html_lines.append("<ul>")
                in_list = True
            html_lines.append(f"  <li>{stripped[2:]}</li>")
        else:
            if in_list:
                html_lines.append("</ul>")
                in_list = False
            # Convert bold/italic
            formatted = re.sub(r'\*\*(.*?)\*\*', r'<strong>\1</strong>', stripped)
            formatted = re.sub(r'\*(.*?)\*', r'<em>\1</em>', formatted)
            html_lines.append(f"<p>{formatted}</p>")

    if in_list:
        html_lines.append("</ul>")

    content_body = "\n".join(html_lines)

    return f"""<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{title} | freeOCR.me</title>
  <meta name="description" content="{title} — Free Ephemeral AI OCR Utility Guide">
  <style>
    body {{ font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; line-height: 1.6; max-width: 800px; margin: 40px auto; padding: 0 20px; color: #1a1a1a; }}
    h1 {{ font-size: 2.2rem; color: #111827; }}
    h2 {{ font-size: 1.6rem; color: #1f2937; margin-top: 1.8rem; }}
    a {{ color: #2563eb; text-decoration: none; }}
    a:hover {{ text-decoration: underline; }}
    .nav {{ margin-bottom: 2rem; font-size: 0.95rem; }}
    footer {{ margin-top: 3rem; padding-top: 1rem; border-top: 1px solid #e5e7eb; font-size: 0.85rem; color: #6b7280; }}
  </style>
</head>
<body>
  <div class="nav"><a href="/">&larr; Back to freeOCR.me Converter</a></div>
  <article>
    {content_body}
  </article>
  <footer>
    <p>&copy; 2026 freeOCR.me — 100% Free &amp; Zero-Retention AI OCR Utility.</p>
  </footer>
</body>
</html>
"""

def main():
    docs_dir = os.path.join(os.path.dirname(__file__), "..", "docs")
    target_dir = os.path.join(os.path.dirname(__file__), "..", "src", "frontend", "build", "web")

    if not os.path.exists(docs_dir):
        print(f"[SEO Build] No docs directory found at {docs_dir}. Skipping.")
        return

    md_files = glob.glob(os.path.join(docs_dir, "**", "*.md"), recursive=True)
    if not md_files:
        print("[SEO Build] No markdown docs found.")
        return

    for md_path in md_files:
        rel_path = os.path.relpath(md_path, docs_dir)
        html_rel_path = os.path.splitext(rel_path)[0] + ".html"
        out_path = os.path.join(target_dir, html_rel_path)

        os.makedirs(os.path.dirname(out_path), exist_ok=True)

        with open(md_path, "r", encoding="utf-8") as f:
            md_text = f.read()

        title = os.path.basename(md_path).replace("-", " ").replace(".md", "").title()
        html_content = markdown_to_simple_html(md_text, title)

        with open(out_path, "w", encoding="utf-8") as f:
            f.write(html_content)

        print(f"[SEO Build] Compiled {rel_path} -> {out_path}")

if __name__ == "__main__":
    main()
