# scripts/generate_kb_index_hub.py
"""
Generates the comprehensive Knowledge Base Hub Directory (src/frontend/web/kb/index.html)
and dedicated standalone category hubs (/kb/workflows, /kb/comparisons, /kb/solutions,
/kb/troubleshooting) listing in-depth engineering articles categorized across the 4 core
content pillars with rich meta-tags, canonical URLs, theme switcher, and AdSense ad slots.
"""

import os
import sys

sys.path.insert(0, os.path.dirname(__file__))
from kb_articles_data import PILLARS, ARTICLES

# ==============================================================================
# Google AdSense Approval Configuration
# Set to True once Google AdSense site review has passed and ad units are active.
# When False, completely suppresses ad containers (.ad-banner-slot) and script tags
# to prevent AdSense rejection for "Low-value content" / "Empty ad placeholders".
# ==============================================================================
K_ADSENSE_APPROVED = False

if K_ADSENSE_APPROVED:
    AD_BANNER_SLOT_CSS = """
    /* Ad slot banner */
    .ad-banner-slot {
      margin: 2rem auto;
      max-width: 970px;
      min-height: 90px;
      background: var(--card-bg);
      border: 1px dashed var(--border);
      border-radius: 8px;
      display: flex;
      align-items: center;
      justify-content: center;
      overflow: hidden;
    }
    """
    MAIN_HUB_AD_SLOT_HTML = """
    <!-- AdSense Display Slot -->
    <div class="ad-banner-slot">
      <ins class="adsbygoogle" style="display:block; width:100%; text-align:center;"
        data-ad-client="ca-pub-6775900998665017" data-ad-slot="1234567890" data-ad-format="auto"
        data-full-width-responsive="true"></ins>
      <script>
        (adsbygoogle = window.adsbygoogle || []).push({});
      </script>
    </div>
    """
    CATEGORY_TOP_AD_SLOT_HTML = """
    <!-- AdSense Display Slot (Top) -->
    <div class="ad-banner-slot">
      <ins class="adsbygoogle" style="display:block; width:100%; text-align:center;"
        data-ad-client="ca-pub-6775900998665017" data-ad-slot="1234567890" data-ad-format="auto"
        data-full-width-responsive="true"></ins>
      <script>
        (adsbygoogle = window.adsbygoogle || []).push({});
      </script>
    </div>
    """
    CATEGORY_BOTTOM_AD_SLOT_HTML = """
    <!-- AdSense Display Slot (Bottom) -->
    <div class="ad-banner-slot">
      <ins class="adsbygoogle" style="display:block; width:100%; text-align:center;"
        data-ad-client="ca-pub-6775900998665017" data-ad-slot="1234567891" data-ad-format="auto"
        data-full-width-responsive="true"></ins>
      <script>
        (adsbygoogle = window.adsbygoogle || []).push({});
      </script>
    </div>
    """
else:
    AD_BANNER_SLOT_CSS = """
    /* Ad slot banner: suppressed during AdSense review */
    .ad-banner-slot {
      display: none !important;
    }
    """
    MAIN_HUB_AD_SLOT_HTML = ""
    CATEGORY_TOP_AD_SLOT_HTML = ""
    CATEGORY_BOTTOM_AD_SLOT_HTML = ""


BASE_WEB_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "src", "frontend", "web"))
BUILD_WEB_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "src", "frontend", "build", "web"))
BUILD_PDFTOOLZ_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "src", "frontend", "build", "freepdftoolz_web"))


def get_hub_output_paths():
    paths = [
        os.path.join(BASE_WEB_DIR, "kb", "index.html"),
        os.path.join(BASE_WEB_DIR, "knowledge-base", "index.html"),
        os.path.join(BASE_WEB_DIR, "kb.html"),
        os.path.join(BASE_WEB_DIR, "knowledge-base.html"),
    ]
    for b_dir in [BUILD_WEB_DIR, BUILD_PDFTOOLZ_DIR]:
        if os.path.exists(b_dir):
            paths.extend([
                os.path.join(b_dir, "kb", "index.html"),
                os.path.join(b_dir, "knowledge-base", "index.html"),
                os.path.join(b_dir, "kb.html"),
                os.path.join(b_dir, "knowledge-base.html"),
            ])
    return paths


def get_category_output_paths(pillar_id):
    paths = [
        os.path.join(BASE_WEB_DIR, "kb", pillar_id, "index.html"),
        os.path.join(BASE_WEB_DIR, "kb", f"{pillar_id}.html"),
        os.path.join(BASE_WEB_DIR, "knowledge-base", pillar_id, "index.html"),
        os.path.join(BASE_WEB_DIR, "knowledge-base", f"{pillar_id}.html"),
    ]
    for b_dir in [BUILD_WEB_DIR, BUILD_PDFTOOLZ_DIR]:
        if os.path.exists(b_dir):
            paths.extend([
                os.path.join(b_dir, "kb", pillar_id, "index.html"),
                os.path.join(b_dir, "kb", f"{pillar_id}.html"),
                os.path.join(b_dir, "knowledge-base", pillar_id, "index.html"),
                os.path.join(b_dir, "knowledge-base", f"{pillar_id}.html"),
            ])
    return paths


COMMON_CSS = """
    :root {
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
      --badge-bg: rgba(99, 102, 241, 0.1);
      --badge-text: #4f46e5;
      --toggle-bg: rgba(99, 102, 241, 0.08);
      --toggle-color: #6366f1;
    }

    [data-theme="dark"] {
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
      --badge-bg: rgba(99, 102, 241, 0.2);
      --badge-text: #a5b4fc;
      --toggle-bg: rgba(255, 255, 255, 0.1);
      --toggle-color: #f3f4f6;
    }

    * {
      box-sizing: border-box;
      margin: 0;
      padding: 0;
    }

    body {
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
      background-color: var(--bg);
      color: var(--text-main);
      line-height: 1.6;
      display: flex;
      flex-direction: column;
      min-height: 100vh;
      -webkit-font-smoothing: antialiased;
    }

    header {
      position: sticky;
      top: 0;
      z-index: 50;
      backdrop-filter: blur(12px);
      -webkit-backdrop-filter: blur(12px);
      background-color: var(--header-bg);
      border-bottom: 1px solid var(--border);
      padding: 0.85rem 2rem;
      display: flex;
      align-items: center;
      justify-content: space-between;
    }

    .logo {
      display: flex;
      align-items: center;
      gap: 0.6rem;
      font-weight: 800;
      font-size: 1.35rem;
      color: var(--heading);
      text-decoration: none;
      letter-spacing: -0.02em;
    }

    .logo-icon {
      width: 32px;
      height: 32px;
      background: rgba(99, 102, 241, 0.12);
      border-radius: 8px;
      display: flex;
      align-items: center;
      justify-content: center;
    }

    .logo span {
      color: var(--accent);
    }

    .nav-wrapper {
      display: flex;
      align-items: center;
      gap: 1.25rem;
    }

    nav {
      display: flex;
      align-items: center;
      gap: 1.5rem;
    }

    nav a {
      color: var(--text-muted);
      text-decoration: none;
      font-size: 0.95rem;
      font-weight: 500;
      transition: color 0.2s;
    }

    nav a:hover,
    nav a.active {
      color: var(--accent);
    }

    .theme-toggle-btn {
      background: var(--toggle-bg);
      border: 1px solid var(--border);
      border-radius: 8px;
      width: 36px;
      height: 36px;
      display: flex;
      align-items: center;
      justify-content: center;
      cursor: pointer;
      color: var(--toggle-color);
      transition: all 0.2s;
    }

    .container {
      max-width: 1200px;
      margin: 0 auto;
      padding: 2.5rem 1.5rem 5rem;
      flex: 1;
    }

    .breadcrumbs {
      display: flex;
      align-items: center;
      gap: 0.5rem;
      font-size: 0.875rem;
      color: var(--text-muted);
      margin-bottom: 2rem;
      flex-wrap: wrap;
    }

    .breadcrumbs a {
      color: var(--text-muted);
      text-decoration: none;
      transition: color 0.2s;
    }

    .breadcrumbs a:hover {
      color: var(--accent);
    }

    .breadcrumbs .separator {
      color: var(--text-muted);
      opacity: 0.6;
    }

    .breadcrumbs .current {
      color: var(--text-main);
      font-weight: 600;
    }

    .hero-banner {
      text-align: center;
      margin-bottom: 3rem;
    }

    .hero-badge {
      display: inline-flex;
      align-items: center;
      gap: 0.4rem;
      background: var(--badge-bg);
      color: var(--badge-text);
      font-size: 0.85rem;
      font-weight: 600;
      padding: 0.35rem 0.85rem;
      border-radius: 9999px;
      margin-bottom: 1rem;
      text-transform: uppercase;
      letter-spacing: 0.05em;
    }

    h1 {
      font-size: 2.75rem;
      font-weight: 800;
      color: var(--heading);
      letter-spacing: -0.03em;
      margin-bottom: 1rem;
      line-height: 1.15;
    }

    .hero-subtitle {
      color: var(--text-muted);
      font-size: 1.2rem;
      max-width: 760px;
      margin: 0 auto 2rem;
      line-height: 1.6;
    }

    .pillar-nav {
      display: flex;
      flex-wrap: wrap;
      justify-content: center;
      gap: 0.75rem;
      margin-bottom: 2rem;
    }

    .pillar-nav-btn {
      background: var(--card-bg);
      border: 1px solid var(--border);
      color: var(--text-main);
      padding: 0.6rem 1.15rem;
      border-radius: 9999px;
      text-decoration: none;
      font-size: 0.9rem;
      font-weight: 500;
      transition: all 0.2s;
      display: inline-flex;
      align-items: center;
      gap: 0.4rem;
    }

    .pillar-nav-btn:hover {
      border-color: var(--accent);
      color: var(--accent);
      transform: translateY(-1px);
    }

    .pillar-nav-btn.active {
      background: var(--accent);
      color: #ffffff;
      border-color: var(--accent);
    }
""" + AD_BANNER_SLOT_CSS + """
    .pillar-section {
      margin-bottom: 4rem;
    }

    .pillar-header {
      display: flex;
      align-items: center;
      gap: 1rem;
      margin-bottom: 1.75rem;
      padding-bottom: 1rem;
      border-bottom: 2px solid var(--border);
    }

    .pillar-icon-badge {
      font-size: 1.75rem;
      width: 48px;
      height: 48px;
      border-radius: 12px;
      background: var(--badge-bg);
      display: flex;
      align-items: center;
      justify-content: center;
      flex-shrink: 0;
    }

    .pillar-title {
      font-size: 1.65rem;
      font-weight: 700;
      color: var(--heading);
      letter-spacing: -0.02em;
    }

    .pillar-desc {
      color: var(--text-muted);
      font-size: 0.95rem;
      margin-top: 0.2rem;
    }

    .pillar-link {
      color: var(--accent);
      text-decoration: none;
      font-size: 0.9rem;
      font-weight: 600;
      display: inline-flex;
      align-items: center;
      gap: 0.25rem;
      transition: gap 0.2s;
    }

    .pillar-link:hover {
      text-decoration: underline;
    }

    .cards-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
      gap: 1.5rem;
    }

    .kb-card {
      background: var(--card-bg);
      border: 1px solid var(--card-border);
      border-radius: 12px;
      padding: 1.65rem;
      display: flex;
      flex-direction: column;
      transition: all 0.25s cubic-bezier(0.16, 1, 0.3, 1);
    }

    .kb-card:hover {
      transform: translateY(-3px);
      border-color: var(--accent);
      box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.08);
    }

    .card-meta {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 0.85rem;
      font-size: 0.8rem;
    }

    .card-category {
      font-weight: 700;
      text-transform: uppercase;
      letter-spacing: 0.05em;
      color: var(--accent);
    }

    .card-read-time {
      color: var(--text-muted);
    }

    .card-title {
      font-size: 1.15rem;
      font-weight: 700;
      line-height: 1.4;
      margin-bottom: 0.75rem;
    }

    .card-title a {
      color: var(--heading);
      text-decoration: none;
      transition: color 0.2s;
    }

    .card-title a:hover {
      color: var(--accent);
    }

    .card-desc {
      color: var(--text-muted);
      font-size: 0.925rem;
      line-height: 1.6;
      margin-bottom: 1.5rem;
      flex: 1;
    }

    .card-footer {
      display: flex;
      align-items: center;
      justify-content: flex-end;
      border-top: 1px solid var(--border);
      padding-top: 1rem;
      margin-top: auto;
    }

    .card-link {
      color: var(--accent);
      font-weight: 600;
      font-size: 0.875rem;
      text-decoration: none;
      display: inline-flex;
      align-items: center;
      gap: 0.35rem;
      transition: gap 0.2s;
    }

    .card-link:hover {
      color: var(--accent-light);
      gap: 0.6rem;
    }

    .cross-explore-box {
      margin-top: 3.5rem;
      padding: 2rem;
      background: var(--card-bg);
      border: 1px solid var(--border);
      border-radius: 12px;
      text-align: center;
    }

    .cross-explore-box h3 {
      font-size: 1.3rem;
      color: var(--heading);
      margin-bottom: 0.5rem;
    }

    .cross-explore-box p {
      color: var(--text-muted);
      font-size: 0.95rem;
      margin-bottom: 1.25rem;
    }

    footer {
      background-color: var(--footer-bg);
      border-top: 1px solid var(--border);
      padding: 3rem 2rem 2rem;
      margin-top: auto;
    }

    .footer-grid {
      max-width: 1100px;
      margin: 0 auto;
      display: grid;
      grid-template-columns: 2fr 1fr 1fr 1fr;
      gap: 3rem;
      margin-bottom: 2.5rem;
    }

    .footer-col h3 {
      font-size: 0.9rem;
      font-weight: 700;
      text-transform: uppercase;
      letter-spacing: 0.05em;
      color: var(--heading);
      margin-bottom: 1rem;
    }

    .footer-col ul {
      list-style: none;
    }

    .footer-col li {
      margin-bottom: 0.5rem;
    }

    .footer-col a {
      color: var(--text-muted);
      transition: color 0.2s;
      text-decoration: none;
      font-size: 0.9rem;
    }

    .footer-col a:hover {
      color: var(--accent);
    }

    .footer-brand p {
      color: var(--text-muted);
      font-size: 0.875rem;
      line-height: 1.6;
      margin-top: 0.5rem;
    }

    .footer-bottom {
      max-width: 1100px;
      margin: 0 auto;
      border-top: 1px solid var(--border);
      padding-top: 1.5rem;
      text-align: center;
      font-size: 0.85rem;
      color: var(--text-muted);
    }

    @media (max-width: 768px) {
      h1 {
        font-size: 2rem;
      }
      .cards-grid {
        grid-template-columns: 1fr;
      }
      .footer-grid {
        grid-template-columns: 1fr;
        gap: 1.5rem;
      }
      header {
        padding: 0.75rem 1rem;
      }
    }
"""

HEADER_HTML = """
  <header>
    <a href="/" class="logo">
      <div class="logo-icon">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#6366f1" stroke-width="2"
          stroke-linecap="round" stroke-linejoin="round">
          <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path>
          <polyline points="14 2 14 8 20 8"></polyline>
          <line x1="16" y1="13" x2="8" y2="13"></line>
          <line x1="16" y1="17" x2="8" y2="17"></line>
          <polyline points="10 9 9 9 8 9"></polyline>
        </svg>
      </div>
      freeOCR<span>.me</span>
    </a>
    <div class="nav-wrapper">
      <nav>
        <a href="/">Home</a>
        <a href="/kb" class="active">Knowledge Base</a>
        <a href="/about">About</a>
        <a href="/privacy">Privacy</a>
        <a href="/terms">Terms</a>
      </nav>
      <button class="theme-toggle-btn" id="themeToggleBtn" aria-label="Toggle Theme">
        <svg id="sunIcon" style="width: 18px; height: 18px; display: none;" fill="none" stroke="currentColor"
          viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
            d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z">
          </path>
        </svg>
        <svg id="moonIcon" style="width: 18px; height: 18px; display: none;" fill="none" stroke="currentColor"
          viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
            d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z"></path>
        </svg>
      </button>
    </div>
  </header>
"""

FOOTER_HTML = """
  <footer>
    <div class="footer-grid">
      <div class="footer-col footer-brand">
        <a href="/" class="logo">
          freeOCR<span>.me</span>
        </a>
        <p>Private, high-performance optical character recognition running on volatile Linux RAM disk architecture with zero persistent disk storage.</p>
      </div>
      <div class="footer-col">
        <h3>Content Pillars</h3>
        <ul>
          <li><a href="/kb/workflows">Tool Guides &amp; Workflows</a></li>
          <li><a href="/kb/comparisons">Format Comparisons</a></li>
          <li><a href="/kb/solutions">Use-Case Solutions</a></li>
          <li><a href="/kb/troubleshooting">Troubleshooting &amp; FAQs</a></li>
        </ul>
      </div>
      <div class="footer-col">
        <h3>Popular Guides</h3>
        <ul>
          <li><a href="/kb/ocr-guide">Understanding OCR</a></li>
          <li><a href="/kb/pdf-standards">PDF Standards &amp; PDF/A</a></li>
          <li><a href="/kb/privacy-security">Zero-Disk Privacy</a></li>
          <li><a href="/kb/ai-vs-traditional-ocr">AI vs Traditional OCR</a></li>
        </ul>
      </div>
      <div class="footer-col">
        <h3>Legal &amp; Policy</h3>
        <ul>
          <li><a href="/about">About Us</a></li>
          <li><a href="/contact">Contact</a></li>
          <li><a href="/privacy">Privacy Policy</a></li>
          <li><a href="/terms">Terms of Service</a></li>
        </ul>
      </div>
    </div>
    <div class="footer-bottom">
      &copy; 2026 freeOCR.me. All rights reserved. Zero-Disk Retention Architecture.
    </div>
  </footer>

  <script>
    var toggleBtn = document.getElementById('themeToggleBtn');
    var sunIcon = document.getElementById('sunIcon');
    var moonIcon = document.getElementById('moonIcon');

    function updateIcons(t) {
      if (t === 'dark') {
        sunIcon.style.display = 'block';
        moonIcon.style.display = 'none';
      } else {
        sunIcon.style.display = 'none';
        moonIcon.style.display = 'block';
      }
    }

    var currentTheme = document.documentElement.getAttribute('data-theme') || 'light';
    updateIcons(currentTheme);

    toggleBtn.addEventListener('click', function () {
      var active = document.documentElement.getAttribute('data-theme') || 'light';
      var next = active === 'dark' ? 'light' : 'dark';
      document.documentElement.setAttribute('data-theme', next);
      try {
        localStorage.setItem('freeocr_theme', next);
      } catch (e) { }
      updateIcons(next);
    });
  </script>
"""


def build_cards_html(slugs, article_by_slug):
    cards_html = ""
    for slug in slugs:
        art = article_by_slug.get(slug)
        if not art:
            continue
        title = art["title"]
        cat = art.get("category", "GUIDE")
        desc = art.get("description", "")
        read_time = art.get("read_time", "8 min read")

        cards_html += f"""
        <div class="kb-card">
          <div class="card-meta">
            <span class="card-category">{cat}</span>
            <span class="card-read-time">{read_time}</span>
          </div>
          <h3 class="card-title"><a href="/kb/{slug}">{title}</a></h3>
          <p class="card-desc">{desc}</p>
          <div class="card-footer">
            <a href="/kb/{slug}" class="card-link">
              Read Guide <span class="arrow">&rarr;</span>
            </a>
          </div>
        </div>
        """
    return cards_html


def build_hub_html():
    article_by_slug = {a["slug"]: a for a in ARTICLES}

    pillar_sections_html = ""
    for pillar in PILLARS:
        pillar_id = pillar["id"]
        pillar_title = pillar["title"]
        pillar_desc = pillar["description"]
        pillar_icon = pillar["icon"]
        slugs = pillar["slugs"]
        cards_html = build_cards_html(slugs, article_by_slug)

        pillar_sections_html += f"""
      <section class="pillar-section" id="{pillar_id}">
        <div class="pillar-header">
          <div class="pillar-icon-badge">{pillar_icon}</div>
          <div style="flex: 1;">
            <div style="display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 0.5rem;">
              <h2 class="pillar-title">{pillar_title}</h2>
              <a href="/kb/{pillar_id}" class="pillar-link">View All {len(slugs)} Guides &rarr;</a>
            </div>
            <p class="pillar-desc">{pillar_desc}</p>
          </div>
        </div>
        <div class="cards-grid">
          {cards_html}
        </div>
      </section>
        """

    json_ld = {
        "@context": "https://schema.org",
        "@type": "CollectionPage",
        "name": "Knowledge Base & Technical Architecture — freeOCR.me",
        "description": "Comprehensive technical documentation and engineering guides across 23 guides and 4 core content pillars.",
        "url": "https://freeocr.me/kb",
        "hasPart": [
            {
                "@type": "WebPage",
                "name": p["title"],
                "url": f"https://freeocr.me/kb/{p['id']}"
            }
            for p in PILLARS
        ]
    }
    import json
    json_ld_str = json.dumps(json_ld, indent=2)

    return f"""<!DOCTYPE html>
<html lang="en">

<head>
  <meta charset="UTF-8">
  <meta content="IE=Edge" http-equiv="X-UA-Compatible">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">

  <title>Knowledge Base &amp; Technical Architecture — freeOCR.me</title>
  <meta name="title" content="Knowledge Base &amp; Technical Architecture — freeOCR.me">
  <meta name="description"
    content="Comprehensive technical documentation, engineering guides, and deep architecture analyses for high-accuracy optical character recognition, dual-layer searchable PDF synthesis, and zero-retention privacy.">
  <meta name="keywords"
    content="ocr documentation, searchable pdf guide, optical character recognition architecture, pdf/a standards, jbig2 compression, tesseract ocr benchmarks, baidu unlimited ocr, document layout analysis">
  <meta name="robots" content="index, follow">
  <link rel="canonical" href="https://freeocr.me/kb">

  <!-- OpenGraph -->
  <meta property="og:type" content="website">
  <meta property="og:url" content="https://freeocr.me/kb">
  <meta property="og:title" content="Knowledge Base &amp; Technical Architecture — freeOCR.me">
  <meta property="og:description"
    content="Explore 23 in-depth engineering guides covering OCR workflows, PDF format comparisons, enterprise solutions, and scanner troubleshooting.">
  <meta property="og:image" content="https://freeocr.me/icons/Icon-512.png">

  <!-- Favicon -->
  <link rel="icon" type="image/png" href="/favicon.png">
  <link rel="shortcut icon" href="/favicon.ico">
  <link rel="manifest" href="/manifest.json">

  <!-- Theme Script (Synchronous to prevent flash) -->
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
  <script async src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-6775900998665017"
    crossorigin="anonymous"></script>

  <!-- Google Analytics 4 (GA4) Telemetry Tag -->
  <script async src="https://www.googletagmanager.com/gtag/js?id=G-E852V95BXB"></script>
  <script>
    window.dataLayer = window.dataLayer || [];
    function gtag() {{ dataLayer.push(arguments); }}
    gtag('js', new Date());
    gtag('config', 'G-E852V95BXB', {{ 'send_page_view': true }});
  </script>

  <!-- Structured Data -->
  <script type="application/ld+json">
{json_ld_str}
  </script>

  <style>
{COMMON_CSS}
  </style>
</head>

<body>
{HEADER_HTML}

  <main class="container">
    <div class="hero-banner">
      <div class="hero-badge">Engineering Documentation &amp; Research</div>
      <h1>Knowledge Base &amp; Technical Architecture</h1>
      <p class="hero-subtitle">
        Comprehensive engineering documentation, computer vision tutorials, and architecture deep dives across 23 guides.
        Learn how high-fidelity optical character recognition, dual-layer PDF synthesis, and zero-retention privacy work under the hood.
      </p>

      <div class="pillar-nav">
        <a href="/kb/workflows" class="pillar-nav-btn">⚡ Tool Guides &amp; Workflows</a>
        <a href="/kb/comparisons" class="pillar-nav-btn">⚖️ Format &amp; Tech Comparisons</a>
        <a href="/kb/solutions" class="pillar-nav-btn">🏢 Use-Case Solutions</a>
        <a href="/kb/troubleshooting" class="pillar-nav-btn">🛠️ Troubleshooting &amp; FAQs</a>
      </div>
    </div>

{MAIN_HUB_AD_SLOT_HTML}

    <!-- 4 Pillars Section -->
    {pillar_sections_html}

  </main>

{FOOTER_HTML}
</body>

</html>"""


def build_category_hub_html(pillar):
    article_by_slug = {a["slug"]: a for a in ARTICLES}
    pillar_id = pillar["id"]
    pillar_title = pillar["title"]
    pillar_desc = pillar["description"]
    pillar_icon = pillar["icon"]
    slugs = pillar["slugs"]
    cards_html = build_cards_html(slugs, article_by_slug)

    # Sub-nav pills with current active category
    nav_buttons = [f'<a href="/kb" class="pillar-nav-btn">📚 All Categories</a>']
    for p in PILLARS:
        active_cls = ' active' if p["id"] == pillar_id else ''
        nav_buttons.append(f'<a href="/kb/{p["id"]}" class="pillar-nav-btn{active_cls}">{p["icon"]} {p["title"]}</a>')
    pillar_nav_html = "\n        ".join(nav_buttons)

    # Other categories for cross-exploration
    other_pillars = [p for p in PILLARS if p["id"] != pillar_id]
    other_links = " &bull; ".join([f'<a href="/kb/{p["id"]}" style="color: var(--accent); text-decoration: none; font-weight: 600;">{p["icon"]} {p["title"]}</a>' for p in other_pillars])

    import json
    json_ld = {
        "@context": "https://schema.org",
        "@type": "CollectionPage",
        "name": f"{pillar_title} — freeOCR.me Knowledge Base",
        "description": pillar_desc,
        "url": f"https://freeocr.me/kb/{pillar_id}",
        "breadcrumb": {
            "@type": "BreadcrumbList",
            "itemListElement": [
                {
                    "@type": "ListItem",
                    "position": 1,
                    "name": "Home",
                    "item": "https://freeocr.me/"
                },
                {
                    "@type": "ListItem",
                    "position": 2,
                    "name": "Knowledge Base",
                    "item": "https://freeocr.me/kb"
                },
                {
                    "@type": "ListItem",
                    "position": 3,
                    "name": pillar_title,
                    "item": f"https://freeocr.me/kb/{pillar_id}"
                }
            ]
        },
        "mainEntity": {
            "@type": "ItemList",
            "itemListElement": [
                {
                    "@type": "ListItem",
                    "position": idx + 1,
                    "url": f"https://freeocr.me/kb/{s}",
                    "name": article_by_slug[s]["title"]
                }
                for idx, s in enumerate(slugs) if s in article_by_slug
            ]
        }
    }
    json_ld_str = json.dumps(json_ld, indent=2)

    return f"""<!DOCTYPE html>
<html lang="en">

<head>
  <meta charset="UTF-8">
  <meta content="IE=Edge" http-equiv="X-UA-Compatible">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">

  <title>{pillar_title} — freeOCR.me Knowledge Base</title>
  <meta name="title" content="{pillar_title} — freeOCR.me Knowledge Base">
  <meta name="description" content="{pillar_desc}">
  <meta name="robots" content="index, follow">
  <link rel="canonical" href="https://freeocr.me/kb/{pillar_id}">

  <!-- OpenGraph -->
  <meta property="og:type" content="website">
  <meta property="og:url" content="https://freeocr.me/kb/{pillar_id}">
  <meta property="og:title" content="{pillar_title} — freeOCR.me Knowledge Base">
  <meta property="og:description" content="{pillar_desc}">
  <meta property="og:image" content="https://freeocr.me/icons/Icon-512.png">

  <!-- Favicon -->
  <link rel="icon" type="image/png" href="/favicon.png">
  <link rel="shortcut icon" href="/favicon.ico">
  <link rel="manifest" href="/manifest.json">

  <!-- Theme Script (Synchronous to prevent flash) -->
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
  <script async src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-6775900998665017"
    crossorigin="anonymous"></script>

  <!-- Google Analytics 4 (GA4) Telemetry Tag -->
  <script async src="https://www.googletagmanager.com/gtag/js?id=G-E852V95BXB"></script>
  <script>
    window.dataLayer = window.dataLayer || [];
    function gtag() {{ dataLayer.push(arguments); }}
    gtag('js', new Date());
    gtag('config', 'G-E852V95BXB', {{ 'send_page_view': true }});
  </script>

  <!-- Structured Data -->
  <script type="application/ld+json">
{json_ld_str}
  </script>

  <style>
{COMMON_CSS}
  </style>
</head>

<body>
{HEADER_HTML}

  <main class="container">
    <nav class="breadcrumbs" aria-label="breadcrumb">
      <a href="/">Home</a>
      <span class="separator">/</span>
      <a href="/kb">Knowledge Base</a>
      <span class="separator">/</span>
      <span class="current">{pillar_title}</span>
    </nav>

    <div class="hero-banner">
      <div class="hero-badge">{len(slugs)} Technical Guides</div>
      <h1>{pillar_icon} {pillar_title}</h1>
      <p class="hero-subtitle">{pillar_desc}</p>

      <div class="pillar-nav">
        {pillar_nav_html}
      </div>
    </div>

{CATEGORY_TOP_AD_SLOT_HTML}

    <div class="cards-grid">
      {cards_html}
    </div>

{CATEGORY_BOTTOM_AD_SLOT_HTML}

    <div class="cross-explore-box">
      <h3>Explore Other Knowledge Base Topics</h3>
      <p>Discover tutorials, engineering benchmarks, and privacy deep-dives across our documentation pillars.</p>
      <div>{other_links}</div>
    </div>
  </main>

{FOOTER_HTML}
</body>

</html>"""


def main():
    # 1. Generate Main Hub (/kb)
    hub_html = build_hub_html()
    for p in get_hub_output_paths():
        os.makedirs(os.path.dirname(p), exist_ok=True)
        with open(p, "w", encoding="utf-8") as f:
            f.write(hub_html)
        print(f"Generated Knowledge Base Hub Directory at: {p}")

    # 2. Generate Dedicated Category Hubs (/kb/{pillar_id})
    for pillar in PILLARS:
        pillar_id = pillar["id"]
        cat_html = build_category_hub_html(pillar)
        for p in get_category_output_paths(pillar_id):
            os.makedirs(os.path.dirname(p), exist_ok=True)
            with open(p, "w", encoding="utf-8") as f:
                f.write(cat_html)
            print(f"Generated Category Hub [{pillar_id}] at: {p}")


if __name__ == "__main__":
    main()
