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

def markdown_to_simple_html(md_text: str, title: str, domain: str = "freeocr.me") -> str:
    """Converts basic markdown formatting into clean semantic HTML structure with domain-aware GA4 telemetry."""
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

    # Domain-aware branding and GA4 telemetry configuration
    is_pdftoolz = "freepdftoolz" in domain.lower()
    brand_name = "FreePDFToolz" if is_pdftoolz else "freeOCR.me"
    brand_domain = "freepdftoolz.me" if is_pdftoolz else "freeocr.me"
    brand_title = f"{title} | FreePDFToolz.me" if is_pdftoolz else f"{title} | freeOCR.me"
    ga_id = "G-W4D8V33FX1" if is_pdftoolz else "G-E852V95BXB"
    back_href = "https://freepdftoolz.me" if is_pdftoolz else "/"
    back_label = "Back to FreePDFToolz Suite" if is_pdftoolz else "Back to freeOCR.me Converter"
    footer_text = "&copy; 2026 FreePDFToolz.me — 100% Free &amp; Zero-Retention PDF Platform." if is_pdftoolz else "&copy; 2026 freeOCR.me — 100% Free &amp; Zero-Retention AI OCR Utility."

    return f"""<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{brand_title}</title>
  <meta name="description" content="{title} — {brand_name} Zero-Retention Utility Guide">
  <link rel="canonical" href="https://{brand_domain}/kb/ai-vs-traditional-ocr">

  <!-- Google Analytics 4 (GA4) Domain-Aware Telemetry Tag -->
  <script async src="https://www.googletagmanager.com/gtag/js?id={ga_id}"></script>
  <script>
    window.dataLayer = window.dataLayer || [];
    function gtag(){{dataLayer.push(arguments);}}
    gtag('js', new Date());
    gtag('config', '{ga_id}', {{ 'send_page_view': true }});
  </script>

  <script type="application/ld+json">
  {{
    "@context": "https://schema.org",
    "@type": "TechArticle",
    "headline": "{title}",
    "description": "{title} — {brand_name} Zero-Retention Utility Guide",
    "author": {{
      "@type": "Organization",
      "name": "{brand_name} Engineering Team"
    }},
    "publisher": {{
      "@type": "Organization",
      "name": "{brand_name}",
      "url": "https://{brand_domain}"
    }},
    "datePublished": "2026-09-15",
    "dateModified": "2026-09-15",
    "mainEntityOfPage": "https://{brand_domain}/kb/ai-vs-traditional-ocr"
  }}
  </script>
  <style>
    body {{ font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; line-height: 1.6; max-width: 840px; margin: 40px auto; padding: 0 20px; color: #1a1a1a; }}
    h1 {{ font-size: 2.2rem; color: #111827; line-height: 1.25; }}
    h2 {{ font-size: 1.6rem; color: #1f2937; margin-top: 1.8rem; }}
    h3 {{ font-size: 1.25rem; color: #374151; margin-top: 1.4rem; }}
    table {{ width: 100%; border-collapse: collapse; margin: 20px 0; }}
    th, td {{ border: 1px solid #e5e7eb; padding: 10px 12px; text-align: left; }}
    th {{ background: #f9fafb; font-weight: 600; }}
    a {{ color: #2563eb; text-decoration: none; }}
    a:hover {{ text-decoration: underline; }}
    .nav {{ margin-bottom: 2rem; font-size: 0.95rem; }}
    footer {{ margin-top: 3rem; padding-top: 1rem; border-top: 1px solid #e5e7eb; font-size: 0.85rem; color: #6b7280; }}
  </style>
</head>
<body>
  <div class="nav"><a href="{back_href}">&larr; {back_label}</a></div>
  <article>
    {content_body}
  </article>
  <footer>
    <p>{footer_text}</p>
  </footer>
</body>
</html>
"""

def main():
    docs_dir = os.path.join(os.path.dirname(__file__), "..", "docs", "blog")
    target_dir = os.path.join(os.path.dirname(__file__), "..", "src", "frontend", "build", "web")

    if not os.path.exists(docs_dir):
        print(f"[SEO Build] No docs/blog directory found at {docs_dir}. Skipping.")
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
