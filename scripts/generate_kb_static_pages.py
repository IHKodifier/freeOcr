#!/usr/bin/env python3
"""
generate_kb_static_pages.py — Generates standalone, rich static HTML pages for all
Knowledge Base technical whitepapers and guides for freeOCR.me.

Solves AdSense "Low value content / Site Under Construction" rejection by generating
complete, crawlable semantic HTML with 900–1,500 words per article across 23 guides,
distinct canonical and OpenGraph meta tags, JSON-LD TechArticle schema markup,
breadcrumbs, categorized sidebar navigation, and internal cross-links.
"""

import os
import sys

sys.path.insert(0, os.path.dirname(__file__))
from kb_articles_data import PILLARS, ARTICLES

BASE_WEB_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "src", "frontend", "web"))
BUILD_WEB_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "src", "frontend", "build", "web"))
BUILD_PDFTOOLZ_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "src", "frontend", "build", "freepdftoolz_web"))

def get_target_web_dirs():
    dirs = [BASE_WEB_DIR]
    for b_dir in [BUILD_WEB_DIR, BUILD_PDFTOOLZ_DIR]:
        if os.path.exists(b_dir):
            dirs.append(b_dir)
    return dirs

HTML_TEMPLATE = """<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{title} — freeOCR.me Knowledge Base</title>
  <meta name="title" content="{title} — freeOCR.me Knowledge Base">
  <meta name="description" content="{description}">
  <meta name="robots" content="index, follow">
  <link rel="canonical" href="https://freeocr.me/kb/{slug}">

  <!-- OpenGraph / Facebook -->
  <meta property="og:type" content="article">
  <meta property="og:url" content="https://freeocr.me/kb/{slug}">
  <meta property="og:title" content="{title} — freeOCR.me">
  <meta property="og:description" content="{description}">
  <meta property="og:image" content="https://freeocr.me/icons/Icon-512.png">
  <meta property="og:site_name" content="freeOCR.me">

  <!-- Twitter Card -->
  <meta name="twitter:card" content="summary_large_image">
  <meta name="twitter:url" content="https://freeocr.me/kb/{slug}">
  <meta name="twitter:title" content="{title} — freeOCR.me">
  <meta name="twitter:description" content="{description}">
  <meta name="twitter:image" content="https://freeocr.me/icons/Icon-512.png">

  <!-- Favicon -->
  <link rel="icon" type="image/png" href="/favicon.png">
  <link rel="shortcut icon" href="/favicon.ico">
  <link rel="manifest" href="/manifest.json">

  <!-- Theme Script (Runs synchronously before render) -->
  <script>
    (function () {{
      try {{
        var saved = localStorage.getItem('freeocr_theme');
        var theme = saved || (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light');
        document.documentElement.setAttribute('data-theme', theme);
      }} catch (e) {{ }}
    }})();
  </script>

  <!-- Google AdSense Monetization Tag -->
  <script async src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-6775900998665017" crossorigin="anonymous"></script>

  <!-- Google Analytics 4 (GA4) Telemetry Tag -->
  <script async src="https://www.googletagmanager.com/gtag/js?id=G-E852V95BXB"></script>
  <script>
    window.dataLayer = window.dataLayer || [];
    function gtag() {{ dataLayer.push(arguments); }}
    gtag('js', new Date());
    gtag('config', 'G-E852V95BXB', {{ 'send_page_view': true }});
  </script>

  <!-- JSON-LD TechArticle Structured Data -->
  <script type="application/ld+json">
  {{
    "@context": "https://schema.org",
    "@type": "TechArticle",
    "headline": "{title}",
    "description": "{description}",
    "author": {{
      "@type": "Organization",
      "name": "freeOCR.me Engineering Team",
      "url": "https://freeocr.me"
    }},
    "publisher": {{
      "@type": "Organization",
      "name": "freeOCR.me",
      "url": "https://freeocr.me",
      "logo": {{
        "@type": "ImageObject",
        "url": "https://freeocr.me/icons/Icon-512.png"
      }}
    }},
    "datePublished": "2026-09-15",
    "dateModified": "2026-09-23",
    "mainEntityOfPage": "https://freeocr.me/kb/{slug}"
  }}
  </script>

  <style>
    :root {{
      --bg: #ffffff;
      --card-bg: #f8fafc;
      --card-border: #e2e8f0;
      --text-main: #0f172a;
      --text-muted: #64748b;
      --heading: #0f172a;
      --accent: #6366f1;
      --accent-light: #4f46e5;
      --border: #e2e8f0;
      --code-bg: #f1f5f9;
      --header-bg: rgba(255, 255, 255, 0.92);
      --footer-bg: #f1f5f9;
      --tip-bg: #eef2ff;
      --tip-border: rgba(99, 102, 241, 0.3);
      --tip-text: #312e81;
      --sec-bg: #fff1f2;
      --sec-border: rgba(225, 29, 72, 0.3);
      --sec-text: #881337;
      --toggle-bg: rgba(99, 102, 241, 0.08);
      --toggle-color: #6366f1;
    }}

    [data-theme="dark"] {{
      --bg: #0b0f19;
      --card-bg: #111827;
      --card-border: rgba(255, 255, 255, 0.08);
      --text-main: #f3f4f6;
      --text-muted: #9ca3af;
      --heading: #ffffff;
      --accent: #6366f1;
      --accent-light: #818cf8;
      --border: rgba(255, 255, 255, 0.08);
      --code-bg: #1e293b;
      --header-bg: rgba(11, 15, 25, 0.92);
      --footer-bg: rgba(15, 23, 42, 0.95);
      --tip-bg: rgba(99, 102, 241, 0.12);
      --tip-border: rgba(99, 102, 241, 0.35);
      --tip-text: #c7d2fe;
      --sec-bg: rgba(225, 29, 72, 0.12);
      --sec-border: rgba(225, 29, 72, 0.35);
      --sec-text: #fecdd3;
      --toggle-bg: rgba(255, 255, 255, 0.1);
      --toggle-color: #f3f4f6;
    }}

    * {{
      box-sizing: border-box;
      margin: 0;
      padding: 0;
    }}

    body {{
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
      background-color: var(--bg);
      color: var(--text-main);
      line-height: 1.7;
      min-height: 100vh;
      display: flex;
      flex-direction: column;
      transition: background-color 0.2s ease, color 0.2s ease;
    }}

    header {{
      position: sticky;
      top: 0;
      z-index: 100;
      backdrop-filter: blur(12px);
      -webkit-backdrop-filter: blur(12px);
      background-color: var(--header-bg);
      border-bottom: 1px solid var(--border);
      padding: 1rem 2rem;
      display: flex;
      align-items: center;
      justify-content: space-between;
    }}

    .logo {{
      display: flex;
      align-items: center;
      gap: 0.5rem;
      text-decoration: none;
      color: var(--heading);
      font-weight: 800;
      font-size: 1.25rem;
      letter-spacing: -0.5px;
    }}

    .logo-icon {{
      width: 30px;
      height: 30px;
      border-radius: 8px;
      background: rgba(99, 102, 241, 0.15);
      border: 1px solid rgba(99, 102, 241, 0.3);
      display: flex;
      align-items: center;
      justify-content: center;
      color: var(--accent);
      font-size: 0.95rem;
    }}

    .logo span {{
      color: var(--accent);
    }}

    .nav-wrapper {{
      display: flex;
      align-items: center;
      gap: 1.5rem;
    }}

    nav {{
      display: flex;
      align-items: center;
      gap: 1.5rem;
    }}

    nav a {{
      color: var(--text-muted);
      text-decoration: none;
      font-size: 0.95rem;
      font-weight: 500;
      transition: color 0.2s;
    }}

    nav a:hover,
    nav a.active {{
      color: var(--accent-light);
      font-weight: 600;
    }}

    .theme-toggle-btn {{
      background: var(--toggle-bg);
      color: var(--toggle-color);
      border: none;
      border-radius: 8px;
      padding: 8px;
      cursor: pointer;
      display: flex;
      align-items: center;
      justify-content: center;
      transition: all 0.2s;
    }}

    .theme-toggle-btn:hover {{
      transform: scale(1.05);
    }}

    .main-layout {{
      max-width: 1240px;
      margin: 2rem auto;
      padding: 0 1.5rem;
      display: grid;
      grid-template-columns: 290px 1fr;
      gap: 2.5rem;
      flex: 1;
      width: 100%;
    }}

    .sidebar {{
      display: flex;
      flex-direction: column;
      gap: 1.5rem;
    }}

    .sidebar-card {{
      background: var(--card-bg);
      border: 1px solid var(--card-border);
      border-radius: 12px;
      padding: 1.25rem;
    }}

    .sidebar-title {{
      font-size: 0.82rem;
      font-weight: 700;
      text-transform: uppercase;
      letter-spacing: 0.05em;
      color: var(--text-muted);
      margin-bottom: 0.5rem;
    }}

    .sidebar-nav {{
      list-style: none;
      display: flex;
      flex-direction: column;
      gap: 0.25rem;
      margin-bottom: 0.75rem;
    }}

    .sidebar-nav a {{
      display: block;
      padding: 0.45rem 0.65rem;
      border-radius: 6px;
      color: var(--text-muted);
      text-decoration: none;
      font-size: 0.85rem;
      line-height: 1.35;
      transition: all 0.2s;
    }}

    .sidebar-nav a:hover {{
      color: var(--accent-light);
      background: rgba(99, 102, 241, 0.08);
    }}

    .sidebar-nav a.active {{
      color: #ffffff;
      background: var(--accent);
      font-weight: 600;
    }}

    .article-container {{
      background: var(--card-bg);
      border: 1px solid var(--card-border);
      border-radius: 16px;
      padding: 2.75rem 2.5rem;
    }}

    .breadcrumbs {{
      font-size: 0.85rem;
      color: var(--text-muted);
      margin-bottom: 1.25rem;
    }}

    .breadcrumbs a {{
      color: var(--accent-light);
      text-decoration: none;
    }}

    .category-badge {{
      display: inline-block;
      padding: 4px 10px;
      border-radius: 6px;
      background: rgba(99, 102, 241, 0.12);
      border: 1px solid rgba(99, 102, 241, 0.25);
      color: var(--accent-light);
      font-size: 0.75rem;
      font-weight: 700;
      letter-spacing: 0.08em;
      margin-bottom: 0.75rem;
    }}

    h1 {{
      font-size: clamp(1.8rem, 3.5vw, 2.4rem);
      font-weight: 800;
      line-height: 1.25;
      letter-spacing: -0.5px;
      color: var(--heading);
      margin-bottom: 0.5rem;
    }}

    .article-meta {{
      font-size: 0.85rem;
      color: var(--text-muted);
      margin-bottom: 2rem;
      padding-bottom: 1rem;
      border-bottom: 1px solid var(--border);
    }}

    .lead {{
      font-size: 1.125rem;
      line-height: 1.7;
      color: var(--text-main);
      margin-bottom: 1.75rem;
      font-weight: 450;
    }}

    h2 {{
      font-size: 1.45rem;
      font-weight: 700;
      color: var(--heading);
      margin-top: 2.25rem;
      margin-bottom: 0.85rem;
      letter-spacing: -0.3px;
    }}

    h3 {{
      font-size: 1.15rem;
      font-weight: 600;
      color: var(--heading);
      margin-top: 1.5rem;
      margin-bottom: 0.5rem;
    }}

    p {{
      margin-bottom: 1.25rem;
      color: var(--text-main);
    }}

    ul, ol {{
      margin-left: 1.5rem;
      margin-bottom: 1.5rem;
      color: var(--text-main);
    }}

    li {{
      margin-bottom: 0.5rem;
    }}

    code {{
      font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
      background: var(--code-bg);
      color: var(--accent-light);
      padding: 0.2rem 0.4rem;
      border-radius: 4px;
      font-size: 0.88em;
    }}

    pre {{
      background: var(--code-bg);
      padding: 1.25rem;
      border-radius: 8px;
      overflow-x: auto;
      margin-bottom: 1.5rem;
      border: 1px solid var(--border);
    }}

    pre code {{
      padding: 0;
      background: none;
      color: var(--text-main);
    }}

    .tip-box {{
      display: flex;
      gap: 1rem;
      background: var(--tip-bg);
      border: 1px solid var(--tip-border);
      color: var(--tip-text);
      padding: 1.25rem 1.5rem;
      border-radius: 10px;
      margin: 1.75rem 0;
    }}

    .tip-box p {{
      margin: 0.35rem 0 0;
      font-size: 0.95rem;
    }}

    .security-box {{
      display: flex;
      gap: 1rem;
      background: var(--sec-bg);
      border: 1px solid var(--sec-border);
      color: var(--sec-text);
      padding: 1.25rem 1.5rem;
      border-radius: 10px;
      margin: 1.75rem 0;
    }}

    .security-box p {{
      margin: 0.35rem 0 0;
      font-size: 0.95rem;
    }}

    .box-icon {{
      font-size: 1.5rem;
      line-height: 1;
    }}

    .benchmark-table {{
      width: 100%;
      border-collapse: collapse;
      margin: 1rem 0;
      font-size: 0.92rem;
    }}

    .benchmark-table th, .benchmark-table td {{
      padding: 0.75rem 1rem;
      border: 1px solid var(--border);
      text-align: left;
    }}

    .benchmark-table th {{
      background: var(--code-bg);
      font-weight: 700;
      color: var(--heading);
    }}

    .benchmark-table td.highlight {{
      color: #10b981;
      font-weight: 700;
    }}

    .cta-card {{
      background: linear-gradient(135deg, rgba(99, 102, 241, 0.12), rgba(168, 85, 247, 0.08));
      border: 1px solid rgba(99, 102, 241, 0.25);
      border-radius: 12px;
      padding: 2rem;
      text-align: center;
      margin-top: 3rem;
    }}

    .cta-card h3 {{
      font-size: 1.3rem;
      font-weight: 800;
      color: var(--heading);
      margin-bottom: 0.5rem;
    }}

    .cta-card p {{
      color: var(--text-muted);
      margin-bottom: 1.25rem;
      max-width: 600px;
      margin-left: auto;
      margin-right: auto;
    }}

    .btn-primary {{
      display: inline-flex;
      align-items: center;
      gap: 0.5rem;
      background: #6366f1;
      color: #ffffff;
      padding: 0.75rem 1.75rem;
      border-radius: 10px;
      font-weight: 700;
      text-decoration: none;
      transition: all 0.2s;
    }}

    .btn-primary:hover {{
      background: #4f46e5;
      transform: translateY(-2px);
      box-shadow: 0 10px 20px -5px rgba(99, 102, 241, 0.4);
    }}

    footer {{
      border-top: 1px solid var(--border);
      background: var(--footer-bg);
      padding: 3rem 2rem 2rem;
      margin-top: auto;
    }}

    .footer-grid {{
      max-width: 1200px;
      margin: 0 auto 2.5rem;
      display: grid;
      grid-template-columns: 2fr 1fr 1fr 1fr;
      gap: 2.5rem;
    }}

    .footer-col h4 {{
      color: var(--heading);
      font-size: 0.95rem;
      font-weight: 700;
      text-transform: uppercase;
      letter-spacing: 0.05em;
      margin-bottom: 1rem;
    }}

    .footer-col ul {{
      list-style: none;
      margin: 0;
    }}

    .footer-col li {{
      margin-bottom: 0.6rem;
    }}

    .footer-col a {{
      color: var(--text-muted);
      text-decoration: none;
      transition: color 0.2s;
      font-size: 0.9rem;
    }}

    .footer-col a:hover {{
      color: var(--accent-light);
    }}

    .footer-bottom {{
      max-width: 1200px;
      margin: 0 auto;
      border-top: 1px solid var(--border);
      padding-top: 1.5rem;
      text-align: center;
      font-size: 0.85rem;
      color: var(--text-muted);
    }}

    @media (max-width: 900px) {{
      .main-layout {{
        grid-template-columns: 1fr;
        gap: 2rem;
      }}
      .sidebar {{
        order: 2;
      }}
      .article-container {{
        padding: 1.75rem 1.25rem;
      }}
      .footer-grid {{
        grid-template-columns: 1fr 1fr;
      }}
    }}

    @media (max-width: 600px) {{
      .footer-grid {{
        grid-template-columns: 1fr;
      }}
      header {{
        padding: 0.75rem 1rem;
      }}
    }}
  </style>
</head>

<body>
  <header>
    <a href="/" class="logo">
      <div class="logo-icon">⚡</div>
      freeOCR<span>.me</span>
    </a>
    <div class="nav-wrapper">
      <nav>
        <a href="/">Home</a>
        <a href="/kb" class="active">Knowledge Base</a>
        <a href="/about">About</a>
        <a href="/contact">Contact</a>
        <a href="/privacy">Privacy</a>
        <a href="/terms">Terms</a>
      </nav>
      <button class="theme-toggle-btn" id="themeToggleBtn" aria-label="Toggle Theme">
        <span id="themeIcon">🌓</span>
      </button>
    </div>
  </header>

  <div class="main-layout">
    <aside class="sidebar">
      <div class="sidebar-card">
        <div class="sidebar-title" style="font-size: 0.9rem; margin-bottom: 1rem;">Knowledge Base Directory</div>
        {sidebar_links}
      </div>

      <div class="sidebar-card">
        <div class="sidebar-title">Security Assurance</div>
        <p style="font-size: 0.85rem; color: var(--text-muted); line-height: 1.5;">
          All file operations execute exclusively within volatile Linux RAM disk (tmpfs). Documents are unlinked immediately upon conversion.
        </p>
      </div>
    </aside>

    <main>
      <article class="article-container">
        <nav class="breadcrumbs">
          <a href="/">Home</a> &rsaquo;
          <a href="/kb">Knowledge Base</a> &rsaquo;
          {category_breadcrumb}
          <span>{title}</span>
        </nav>

        <span class="category-badge">{category}</span>
        <h1>{title}</h1>
        <div class="article-meta">
          Published September 15, 2026 &bull; freeOCR.me Engineering Team &bull; {read_time}
        </div>

        {content_html}

        <div class="cta-card">
          <h3>Try freeOCR.me 100% Free</h3>
          <p>Convert your scanned PDFs, receipts, and images to dual-layer searchable PDFs and Structured Markdown with ephemeral RAM security.</p>
          <a href="/" class="btn-primary">
            <span>⚡</span> Convert Scanned Document Now
          </a>
        </div>
      </article>
    </main>
  </div>

  <footer>
    <div class="footer-grid">
      <div class="footer-col">
        <h4>freeOCR.me</h4>
        <p style="font-size: 0.875rem; color: var(--text-muted); line-height: 1.6;">
          100% Free Online AI OCR utility platform. Converts scanned documents and images into searchable PDFs and structured text with zero persistent cloud storage.
        </p>
      </div>
      <div class="footer-col">
        <h4>Content Pillars</h4>
        <ul>
          <li><a href="/kb/workflows">Tool Guides &amp; Workflows</a></li>
          <li><a href="/kb/comparisons">Format Comparisons</a></li>
          <li><a href="/kb/solutions">Use-Case Solutions</a></li>
          <li><a href="/kb/troubleshooting">Troubleshooting &amp; FAQs</a></li>
        </ul>
      </div>
      <div class="footer-col">
        <h4>Features</h4>
        <ul>
          <li><a href="/">Scanned PDF to Searchable PDF</a></li>
          <li><a href="/">Extract PDF to Markdown</a></li>
          <li><a href="/">Multi-Column Layout OCR</a></li>
          <li><a href="/">Radon Deskewing Pipeline</a></li>
          <li><a href="/">Adaptive Otsu Binarization</a></li>
        </ul>
      </div>
      <div class="footer-col">
        <h4>Governance &amp; Trust</h4>
        <ul>
          <li><a href="/about">About Us</a></li>
          <li><a href="/contact">Contact</a></li>
          <li><a href="/privacy">Privacy Policy</a></li>
          <li><a href="/terms">Terms of Service</a></li>
        </ul>
      </div>
    </div>
    <div class="footer-bottom">
      &copy; 2026 freeOCR.me &bull; Ephemeral Linux RAM-Disk Optical Character Recognition. All rights reserved.
    </div>
  </footer>

  <script>
    (function () {{
      var btn = document.getElementById('themeToggleBtn');
      if (btn) {{
        btn.addEventListener('click', function () {{
          var current = document.documentElement.getAttribute('data-theme') || 'dark';
          var next = current === 'dark' ? 'light' : 'dark';
          document.documentElement.setAttribute('data-theme', next);
          try {{ localStorage.setItem('freeocr_theme', next); }} catch(e) {{}}
        }});
      }}
    }})();
  </script>
</body>
</html>
"""


def generate_all():
    print(f"Generating Knowledge Base static HTML articles for {len(ARTICLES)} guides...")

    for article in ARTICLES:
        slug = article["slug"]
        title = article["title"]
        category = article["category"]
        description = article["description"]
        read_time = article["read_time"]
        content_html = article["content_html"]

        # Build categorized sidebar navigation grouped by the 4 pillars
        sidebar_blocks = []
        for pillar in PILLARS:
            sidebar_blocks.append(f'<div class="sidebar-title" style="margin-top: 0.9rem; font-size: 0.78rem;"><a href="/kb/{pillar["id"]}" style="color: inherit; text-decoration: none;">{pillar["icon"]} {pillar["title"]} &rarr;</a></div>')
            sidebar_blocks.append('<ul class="sidebar-nav">')
            for a_slug in pillar["slugs"]:
                other = next((a for a in ARTICLES if a["slug"] == a_slug), None)
                if other:
                    active_cls = ' class="active"' if other["slug"] == slug else ''
                    short_title = other["title"].split(":")[0]
                    sidebar_blocks.append(f'<li><a href="/kb/{other["slug"]}"{active_cls}>{short_title}</a></li>')
            sidebar_blocks.append('</ul>')
        sidebar_links = "\n        ".join(sidebar_blocks)

        parent_pillar = next((p for p in PILLARS if slug in p["slugs"]), None)
        category_breadcrumb = f'<a href="/kb/{parent_pillar["id"]}">{parent_pillar["title"]}</a> &rsaquo;' if parent_pillar else ''

        html_content = HTML_TEMPLATE.format(
            title=title,
            category=category,
            description=description,
            read_time=read_time,
            content_html=content_html,
            slug=slug,
            sidebar_links=sidebar_links,
            category_breadcrumb=category_breadcrumb
        )

        # Output to all target web directories
        target_dirs = get_target_web_dirs()
        for base_dir in target_dirs:
            # /kb/<slug>/index.html and /kb/<slug>.html
            kb_slug_dir = os.path.join(base_dir, "kb", slug)
            os.makedirs(kb_slug_dir, exist_ok=True)
            with open(os.path.join(kb_slug_dir, "index.html"), "w", encoding="utf-8") as f:
                f.write(html_content)
            with open(os.path.join(base_dir, "kb", f"{slug}.html"), "w", encoding="utf-8") as f:
                f.write(html_content)

            # /knowledge-base/<slug>/index.html and /knowledge-base/<slug>.html
            knowledge_base_slug_dir = os.path.join(base_dir, "knowledge-base", slug)
            os.makedirs(knowledge_base_slug_dir, exist_ok=True)
            with open(os.path.join(knowledge_base_slug_dir, "index.html"), "w", encoding="utf-8") as f:
                f.write(html_content)
            with open(os.path.join(base_dir, "knowledge-base", f"{slug}.html"), "w", encoding="utf-8") as f:
                f.write(html_content)

            # Aliases
            for alias in article.get("aliases", []):
                alias_dir = os.path.join(base_dir, "kb", alias)
                os.makedirs(alias_dir, exist_ok=True)
                with open(os.path.join(alias_dir, "index.html"), "w", encoding="utf-8") as f:
                    f.write(html_content)
                with open(os.path.join(base_dir, "kb", f"{alias}.html"), "w", encoding="utf-8") as f:
                    f.write(html_content)

                kb_alias_dir = os.path.join(base_dir, "knowledge-base", alias)
                os.makedirs(kb_alias_dir, exist_ok=True)
                with open(os.path.join(kb_alias_dir, "index.html"), "w", encoding="utf-8") as f:
                    f.write(html_content)
                with open(os.path.join(base_dir, "knowledge-base", f"{alias}.html"), "w", encoding="utf-8") as f:
                    f.write(html_content)

        print(f"Generated: /kb/{slug}/ and /knowledge-base/{slug}/ (directory + .html)")

    print(f"Knowledge base generation completed successfully ({len(ARTICLES)} articles generated).")


if __name__ == "__main__":
    generate_all()
