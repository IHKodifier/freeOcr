# TASK DISPATCH: TICKET-04 — Adsterra 300x250 Complementary Display Unit Integration

> **Ticket ID:** `MONETIZE-04`  
> **Target Domain:** `https://freeocr.me`  
> **Estimated Execution Time:** 20 Minutes  
> **Actor:** Coding Agent / Pair Programmer  
> **Target Files:**  
> - [`scripts/generate_kb_static_pages.py`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/scripts/generate_kb_static_pages.py)  
> - [`src/frontend/web/about/index.html`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/frontend/web/about/index.html)  
> - [`src/frontend/web/terms/index.html`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/frontend/web/terms/index.html)  
> **Prerequisites:** `MONETIZE-01` (Adsterra account approved, safety filters on) & `MONETIZE-02` (`ads.txt` updated)  
> **Governance:** Per [`.agents/AGENTS.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/.agents/AGENTS.md)

---

## 1. Context & Objectives

To maximize page yield, running multiple non-exclusive ad platforms simultaneously on the same page is standard industry practice. While **Monetag** runs in the right-hand sticky `.ads-rail`, **Adsterra** serves as the complementary display partner in the content body or footer slot.

Adsterra delivers standard 300x250 (Medium Rectangle) or 728x90 (Leaderboard) display creatives via standard asynchronous iframe/script tags.

This ticket covers:
1. Placing the Adsterra display unit inside the static Knowledge Base article body (just above the conversion CTA card).
2. Replacing the blank AdSense tags in [`about/index.html`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/frontend/web/about/index.html) and [`terms/index.html`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/frontend/web/terms/index.html) with active Adsterra units.
3. Ensuring zero script conflict between Monetag and Adsterra.

---

## 2. Implementation Specifications

### Part A: Embed Adsterra in Knowledge Base Content Stream

In [`scripts/generate_kb_static_pages.py`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/scripts/generate_kb_static_pages.py), locate the section above `.cta-card` around line 673:

```html
        <!-- In-Article Mid/End Display Ad Unit (Adsterra 300x250 or 728x90) -->
        <div class="article-ad-container" style="margin: 2.5rem 0; padding: 1rem 0; text-align: center; border-top: 1px solid var(--border); border-bottom: 1px solid var(--border);">
          <span style="font-size: 11px; text-transform: uppercase; letter-spacing: 0.05em; color: var(--text-muted); display: block; margin-bottom: 8px;">Advertisement</span>
          
          <div id="adsterra-slot-container" style="min-height: 250px; display: flex; justify-content: center; align-items: center;">
            <!-- Adsterra 300x250 Clean Display Script Code -->
            <script type="text/javascript">
              atOptions = {
                'key' : '[YOUR_ADSTERRA_KEY]',
                'format' : 'iframe',
                'height' : 250,
                'width' : 300,
                'params' : {}
              };
            </script>
            <script type="text/javascript" src="//www.topcreativeformat.com/[YOUR_ADSTERRA_KEY]/invoke.js"></script>
          </div>
        </div>

        <div class="cta-card">
          <h3>Try freeOCR.me 100% Free</h3>
          ...
```

---

### Part B: Update Static Editorial Pages (`about/` and `terms/`)

Currently, [`src/frontend/web/about/index.html`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/frontend/web/about/index.html) and [`src/frontend/web/terms/index.html`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/frontend/web/terms/index.html) contain blank Google AdSense blocks (`<ins class="adsbygoogle">`) that display as empty white space.

Replace the blank `<ins class="adsbygoogle">` block in `about/index.html` (lines 642–648) with the active Adsterra banner unit:

```html
      <div class="ad-unit-wrapper" style="min-height: 250px; display: flex; flex-direction: column; align-items: center; justify-content: center; margin: 2rem 0;">
        <span style="font-size: 11px; text-transform: uppercase; letter-spacing: 0.05em; color: var(--text-muted); margin-bottom: 6px;">Sponsored</span>
        <script type="text/javascript">
          atOptions = {
            'key' : '[YOUR_ADSTERRA_KEY]',
            'format' : 'iframe',
            'height' : 250,
            'width' : 300,
            'params' : {}
          };
        </script>
        <script type="text/javascript" src="//www.topcreativeformat.com/[YOUR_ADSTERRA_KEY]/invoke.js"></script>
      </div>
```

---

### Part C: Regenerate All KB Pages

Run the generation script:
```powershell
python scripts/generate_kb_static_pages.py
```

---

## 3. Simultaneous Multi-Network Co-existence Validation

- **No Script Pollution:** Monetag uses its isolated wrapper and Adsterra executes inside a sandboxed `iframe`. There are **zero variable leaks** between `window` scopes.
- **Coalition for Better Ads Compliance:** Total ad area on the screen does not exceed 30% of the viewport.
  - Desktop view: Sticky Monetag in right rail + Adsterra mid-content.
  - Mobile view: Monetag rail is hidden; only the single in-content Adsterra unit displays.

---

## 4. Acceptance Criteria
- [ ] Adsterra banner code is embedded with the user's specific key.
- [ ] Both Monetag and Adsterra ads render cleanly on `https://freeocr.me/kb/ocr-guide/` in desktop view.
- [ ] Blank Google ad blocks on `/about` and `/terms` are replaced with functional Adsterra units.
- [ ] Zero adult, gambling, or loud audio ads are served (verified by active safety toggles in `MONETIZE-01`).
