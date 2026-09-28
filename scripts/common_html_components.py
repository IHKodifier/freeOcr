"""
common_html_components.py — Canonical Reusable Static HTML Components for freeOCR.me

Single source of truth for freeOCR.me static HTML components.
Guarantees 100% visual and navigational parity between Flutter web client (AppFooter)
and all pre-rendered static HTML landing pages and articles.
"""

TWITTER_SVG = (
    '<svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">'
    '<path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68'
    'l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z"/>'
    '</svg>'
)

INSTAGRAM_SVG = (
    '<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" '
    'stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">'
    '<rect x="2" y="2" width="20" height="20" rx="5" ry="5"/>'
    '<path d="M16 11.37A4 4 0 1 1 12.63 8 4 4 0 0 1 16 11.37z"/>'
    '<line x1="17.5" y1="6.5" x2="17.51" y2="6.5"/>'
    '</svg>'
)

FACEBOOK_SVG = (
    '<svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">'
    '<path d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 '
    '10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 '
    '1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328'
    'l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z"/>'
    '</svg>'
)


def get_canonical_footer_css() -> str:
    """Returns CSS rules for the canonical footer matching Flutter AppFooter."""
    return """
    /* Canonical Responsive AppFooter Styles (matching Flutter AppFooter widget) */
    .app-footer {
      background: var(--footer-bg, #f1f5f9);
      border-top: 1px solid var(--border, rgba(0, 0, 0, 0.08));
      padding: 48px 32px;
      width: 100%;
      box-sizing: border-box;
      font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      margin-top: auto;
    }

    [data-theme="dark"] .app-footer {
      background: var(--footer-bg, rgba(15, 23, 42, 0.90));
      border-top: 1px solid var(--border, rgba(255, 255, 255, 0.10));
    }

    .footer-inner {
      max-width: 1140px;
      margin: 0 auto;
      box-sizing: border-box;
    }

    .footer-grid {
      display: grid;
      grid-template-columns: 3fr 2fr 3fr 2fr;
      gap: 24px;
      align-items: start;
    }

    @media (max-width: 768px) {
      .app-footer {
        padding: 36px 20px;
      }
      .footer-grid {
        grid-template-columns: 1fr;
        gap: 32px;
      }
    }

    .footer-brand {
      display: flex;
      flex-direction: column;
      gap: 12px;
    }

    .footer-brand-title {
      display: inline-flex;
      align-items: center;
      gap: 10px;
      text-decoration: none;
      color: var(--heading, #0f172a);
    }

    .footer-brand-title span {
      font-size: 20px;
      font-weight: 800;
      letter-spacing: -0.5px;
      color: var(--heading, #0f172a);
    }

    .footer-brand-title span .brand-accent {
      color: var(--accent, #6366f1);
    }

    .footer-brand-icon {
      border-radius: 8px;
      display: block;
      width: 30px;
      height: 30px;
      object-fit: cover;
    }

    .footer-brand-desc {
      font-size: 13px;
      line-height: 1.5;
      color: var(--text-muted, #64748b);
      margin: 0;
    }

    .footer-social-row {
      display: flex;
      gap: 8px;
      margin-top: 4px;
    }

    .footer-social-btn {
      display: inline-flex;
      align-items: center;
      justify-content: center;
      width: 36px;
      height: 36px;
      border-radius: 8px;
      background: transparent;
      color: var(--heading, #0f172a);
      text-decoration: none;
      transition: background 0.15s ease, color 0.15s ease;
    }

    [data-theme="dark"] .footer-social-btn {
      color: var(--text-main, #f8fafc);
    }

    .footer-social-btn:hover {
      background: rgba(99, 102, 241, 0.10);
      color: var(--accent, #6366f1);
    }

    .footer-col h3 {
      font-size: 14px;
      font-weight: 700;
      letter-spacing: 0.5px;
      color: var(--heading, #0f172a);
      margin: 0 0 14px 0;
    }

    [data-theme="dark"] .footer-col h3 {
      color: var(--heading, #ffffff);
    }

    .footer-links {
      list-style: none;
      padding: 0;
      margin: 0;
      display: flex;
      flex-direction: column;
      gap: 8px;
    }

    .footer-links li {
      margin: 0;
      padding: 0;
    }

    .footer-links a {
      font-size: 14px;
      font-weight: 400;
      color: var(--text-muted, #64748b);
      text-decoration: none;
      transition: color 0.15s ease;
      display: inline-block;
      padding: 2px 0;
    }

    .footer-links a:hover {
      color: var(--accent, #6366f1);
    }

    .engine-chips {
      display: flex;
      flex-wrap: wrap;
      gap: 6px;
    }

    .engine-chip {
      display: inline-flex;
      align-items: center;
      padding: 4px 10px;
      font-size: 12px;
      font-weight: 500;
      border-radius: 8px;
      text-decoration: none;
      background: var(--chip-bg, rgba(0, 0, 0, 0.04));
      color: var(--heading, #0f172a);
      border: 0.8px solid var(--chip-border, #cbd5e1);
      transition: all 0.15s ease;
    }

    [data-theme="dark"] .engine-chip {
      background: rgba(255, 255, 255, 0.06);
      color: var(--text-main, #f8fafc);
      border-color: rgba(255, 255, 255, 0.12);
    }

    .engine-chip:hover {
      background: rgba(99, 102, 241, 0.12);
      border-color: var(--accent, #6366f1);
      color: var(--accent, #6366f1);
    }

    .footer-bottom {
      max-width: 1140px;
      margin: 32px auto 0;
      padding-top: 20px;
      border-top: 1px solid var(--border, rgba(0, 0, 0, 0.08));
      font-size: 13px;
      color: var(--text-muted, #64748b);
      text-align: center;
      line-height: 1.5;
    }

    [data-theme="dark"] .footer-bottom {
      border-top-color: var(--border, rgba(255, 255, 255, 0.08));
    }
"""


def get_canonical_footer_html(*args, **kwargs) -> str:
    """
    Renders the exact 4-column footer HTML matching Flutter's AppFooter widget.
    
    Columns:
      1. Brand & Social Handles (Twitter/X, Instagram, Facebook)
      2. Navigation (Home, About Us, Knowledge Base, AI vs Traditional OCR)
      3. Engines (Baidu Unlimited OCR, Tesseract OCR, OCRmyPDF, PyMuPDF)
      4. Legal (Privacy Policy, Terms of Service, Contact Us, Source Code (GitHub))
      Bottom: Copyright & Ephemeral RAM Disk statement.
    """
    brand_html = """
        <a href="/" class="footer-brand-title">
          <img src="/icons/Icon-48.png" width="30" height="30" alt="freeOCR.me Logo" class="footer-brand-icon" onerror="this.onerror=null;this.src='/favicon.png';" />
          <span>freeOCR<span class="brand-accent">.me</span></span>
        </a>
        <p class="footer-brand-desc">
          &copy; 2026 freeOCR.me &bull; Privacy-First Ephemeral OCR Platform.<br>
          All rights reserved. Files processed in RAM disk.
        </p>"""

    nav_items = """
          <li><a href="/">Home</a></li>
          <li><a href="/about">About Us</a></li>
          <li><a href="/kb">Knowledge Base</a></li>
          <li><a href="/kb/ai-vs-traditional-ocr">AI vs Traditional OCR</a></li>"""

    bottom_notice = (
        "&copy; 2026 freeOCR.me &bull; Privacy-First Ephemeral OCR Platform. "
        "All rights reserved. Files processed in RAM disk."
    )

    return f"""  <footer class="app-footer">
    <div class="footer-inner">
      <div class="footer-grid">
        <!-- Column 1: Brand & Social Channels -->
        <div class="footer-col footer-brand">{brand_html}
          <div class="footer-social-row">
            <a href="https://x.com/freeocrme" class="footer-social-btn" title="Twitter / X" target="_blank" rel="noopener" aria-label="Twitter / X">
              {TWITTER_SVG}
            </a>
            <a href="https://instagram.com/freeocrme" class="footer-social-btn" title="Instagram" target="_blank" rel="noopener" aria-label="Instagram">
              {INSTAGRAM_SVG}
            </a>
            <a href="https://facebook.com/freeOCRme" class="footer-social-btn" title="Facebook" target="_blank" rel="noopener" aria-label="Facebook">
              {FACEBOOK_SVG}
            </a>
          </div>
        </div>

        <!-- Column 2: Navigation Links -->
        <div class="footer-col">
          <h3>Navigation</h3>
          <ul class="footer-links">{nav_items}
          </ul>
        </div>

        <!-- Column 3: Open-Source Engine Attributions -->
        <div class="footer-col">
          <h3>Engines</h3>
          <div class="engine-chips">
            <a href="https://github.com/PaddlePaddle/PaddleOCR" target="_blank" rel="noopener" class="engine-chip">Baidu Unlimited OCR</a>
            <a href="https://github.com/tesseract-ocr/tesseract" target="_blank" rel="noopener" class="engine-chip">Tesseract OCR</a>
            <a href="https://github.com/ocrmypdf/OCRmyPDF" target="_blank" rel="noopener" class="engine-chip">OCRmyPDF</a>
            <a href="https://github.com/pymupdf/PyMuPDF" target="_blank" rel="noopener" class="engine-chip">PyMuPDF</a>
          </div>
        </div>

        <!-- Column 4: Legal & Policy Links -->
        <div class="footer-col">
          <h3>Legal</h3>
          <ul class="footer-links">
            <li><a href="/privacy">Privacy Policy</a></li>
            <li><a href="/terms">Terms of Service</a></li>
            <li><a href="/contact">Contact Us</a></li>
            <li><a href="https://github.com/IHKodifier/freeOcr" target="_blank" rel="noopener">Source Code (GitHub)</a></li>
          </ul>
        </div>
      </div>

      <div class="footer-bottom">
        {bottom_notice}
      </div>
    </div>
  </footer>"""
