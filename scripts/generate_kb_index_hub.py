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
from common_html_components import get_canonical_footer_css, get_canonical_footer_html

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


def get_hub_output_paths():
    paths = [
        os.path.join(BASE_WEB_DIR, "kb", "index.html"),
        os.path.join(BASE_WEB_DIR, "knowledge-base", "index.html"),
        os.path.join(BASE_WEB_DIR, "kb.html"),
        os.path.join(BASE_WEB_DIR, "knowledge-base.html"),
    ]
    if os.path.exists(BUILD_WEB_DIR):
        paths.extend([
            os.path.join(BUILD_WEB_DIR, "kb", "index.html"),
            os.path.join(BUILD_WEB_DIR, "knowledge-base", "index.html"),
            os.path.join(BUILD_WEB_DIR, "kb.html"),
            os.path.join(BUILD_WEB_DIR, "knowledge-base.html"),
        ])
    return paths


def get_category_output_paths(pillar_id):
    paths = [
        os.path.join(BASE_WEB_DIR, "kb", pillar_id, "index.html"),
        os.path.join(BASE_WEB_DIR, "kb", f"{pillar_id}.html"),
        os.path.join(BASE_WEB_DIR, "knowledge-base", pillar_id, "index.html"),
        os.path.join(BASE_WEB_DIR, "knowledge-base", f"{pillar_id}.html"),
    ]
    if os.path.exists(BUILD_WEB_DIR):
        paths.extend([
            os.path.join(BUILD_WEB_DIR, "kb", pillar_id, "index.html"),
            os.path.join(BUILD_WEB_DIR, "kb", f"{pillar_id}.html"),
            os.path.join(BUILD_WEB_DIR, "knowledge-base", pillar_id, "index.html"),
            os.path.join(BUILD_WEB_DIR, "knowledge-base", f"{pillar_id}.html"),
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
      --toggle-border: rgba(99, 102, 241, 0.2);
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
      --toggle-border: rgba(255, 255, 255, 0.15);
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
      width: 100%;
      max-width: 100%;
      margin: 10px 0 6px;
      padding: 0 20px;
      box-sizing: border-box;
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
      gap: 0.5rem;
    }

    nav {
      display: flex;
      align-items: center;
      gap: 4px;
      font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    }

    nav a {
      color: var(--text-muted);
      text-decoration: none;
      font-size: 13px;
      font-weight: 600;
      padding: 4px 8px;
      border-radius: 6px;
      transition: color 0.15s ease;
    }

    nav a:hover {
      color: var(--accent);
    }

    nav a.active {
      color: var(--accent);
      font-weight: 700;
    }

    .nav-sep {
      color: var(--toggle-border, rgba(148, 163, 184, 0.3));
      opacity: 0.6;
      font-size: 12px;
      user-select: none;
      padding: 0 2px;
    }

    .theme-toggle-btn {
      background: var(--toggle-bg);
      border: 1px solid var(--toggle-border, rgba(99, 102, 241, 0.2));
      border-radius: 50%;
      width: 34px;
      height: 34px;
      margin-left: 4px;
      padding: 0;
      display: inline-flex;
      align-items: center;
      justify-content: center;
      cursor: pointer;
      color: var(--toggle-color);
      outline: none;
      transition: background-color 0.2s ease, transform 0.2s;
    }

    .theme-toggle-btn:hover {
      transform: scale(1.05);
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

""" + get_canonical_footer_css() + """

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
    }
"""

HEADER_HTML = """
  <header style="width: 100%; max-width: 100%; margin: 10px 0 6px; padding: 0 20px; box-sizing: border-box; position: sticky; top: 0; z-index: 100;">
    <div style="width: 100%; height: 56px; padding: 0 14px; display: flex; justify-content: space-between; align-items: center; box-sizing: border-box; background: var(--card-bg, #f8fafc); border: 1px solid var(--card-border, #e2e8f0); border-radius: 16px; box-shadow: 0 4px 16px rgba(0, 0, 0, 0.05); backdrop-filter: blur(16px); -webkit-backdrop-filter: blur(16px); transition: background-color 0.2s ease, border-color 0.2s ease;">
      <a href="/" style="display: flex; align-items: center; gap: 8px; text-decoration: none;">
        <img src="/icons/Icon-48.png" width="32" height="32" alt="freeOCR.me Logo" style="border-radius: 8px; display: block;" onerror="this.onerror=null;this.src='/favicon.png';" />
        <span style="font-size: 18px; font-weight: 800; color: var(--heading, #0f172a); letter-spacing: -0.5px; font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;">
          freeOCR<span style="color: #6366f1;">.me</span>
        </span>
      </a>
      <div class="nav-wrapper">
        <nav style="display: flex; align-items: center; gap: 4px; font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;">
          <a href="/">Home</a>
          <span class="nav-sep">|</span>
          <a href="/about">About</a>
          <span class="nav-sep">|</span>
          <a href="/kb" class="active">Knowledge Base</a>
          <span class="nav-sep">|</span>
          <a href="/privacy">Privacy</a>
          <span class="nav-sep">|</span>
          <a href="/terms">Terms</a>
          <span class="nav-sep">|</span>
          <a href="/contact">Contact</a>
        </nav>
        <button class="theme-toggle-btn" id="themeToggleBtn" aria-label="Toggle Theme">
          <span id="themeIcon" style="display: inline-flex; align-items: center; justify-content: center;"><svg width="18" height="18" viewBox="0 0 24 24" fill="#6366F1" style="display: block;"><path d="M12.3 2a10 10 0 0 0-.19 20 10.04 10.04 0 0 0 9.89-7.57 1 1 0 0 0-1.25-1.18A8.04 8.04 0 0 1 10.75 4.75a8 8 0 0 1 2.73-1.6 1 1 0 0 0-.68-1.92A10.22 10.22 0 0 0 12.3 2z"/></svg></span>
        </button>
      </div>
    </div>
  </header>
"""

FOOTER_HTML = get_canonical_footer_html("freeocr.me") + """

  <script>
    (function () {
      var btn = document.getElementById('themeToggleBtn');
      var icon = document.getElementById('themeIcon');
      var moonSvg = '<svg width="18" height="18" viewBox="0 0 24 24" fill="#6366F1" style="display: block;"><path d="M12.3 2a10 10 0 0 0-.19 20 10.04 10.04 0 0 0 9.89-7.57 1 1 0 0 0-1.25-1.18A8.04 8.04 0 0 1 10.75 4.75a8 8 0 0 1 2.73-1.6 1 1 0 0 0-.68-1.92A10.22 10.22 0 0 0 12.3 2z"/></svg>';
      var sunSvg = '<svg width="18" height="18" viewBox="0 0 24 24" fill="#F59E0B" style="display: block;"><circle cx="12" cy="12" r="5"/><line x1="12" y1="1" x2="12" y2="3" stroke="#F59E0B" stroke-width="2" stroke-linecap="round"/><line x1="12" y1="21" x2="12" y2="23" stroke="#F59E0B" stroke-width="2" stroke-linecap="round"/><line x1="4.22" y1="4.22" x2="5.64" y2="5.64" stroke="#F59E0B" stroke-width="2" stroke-linecap="round"/><line x1="18.36" y1="18.36" x2="19.78" y2="19.78" stroke="#F59E0B" stroke-width="2" stroke-linecap="round"/><line x1="1" y1="12" x2="3" y2="12" stroke="#F59E0B" stroke-width="2" stroke-linecap="round"/><line x1="21" y1="12" x2="23" y2="12" stroke="#F59E0B" stroke-width="2" stroke-linecap="round"/><line x1="4.22" y1="19.78" x2="5.64" y2="18.36" stroke="#F59E0B" stroke-width="2" stroke-linecap="round"/><line x1="18.36" y1="5.64" x2="19.78" y2="4.22" stroke="#F59E0B" stroke-width="2" stroke-linecap="round"/></svg>';
      function updateIcon(theme) {
        if (icon) {
          icon.innerHTML = theme === 'dark' ? sunSvg : moonSvg;
        }
      }
      var initial = document.documentElement.getAttribute('data-theme') || 'light';
      updateIcon(initial);
      if (btn) {
        btn.addEventListener('click', function () {
          var current = document.documentElement.getAttribute('data-theme') || 'light';
          var next = current === 'dark' ? 'light' : 'dark';
          document.documentElement.setAttribute('data-theme', next);
          updateIcon(next);
          try { localStorage.setItem('freeocr_theme', next); } catch(e) {}
        });
      }
    })();
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
        var theme = saved || 'light';
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
        var theme = saved || 'light';
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
