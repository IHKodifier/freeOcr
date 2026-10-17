# TASK DISPATCH: TICKET-03 — Monetag Clean Native/Display Tag Integration

> **Ticket ID:** `MONETIZE-03`  
> **Target Domain:** `https://freeocr.me`  
> **Estimated Execution Time:** 25 Minutes  
> **Actor:** Coding Agent / Pair Programmer  
> **Target Files:**  
> - [`scripts/generate_kb_static_pages.py`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/scripts/generate_kb_static_pages.py)  
> - [`src/frontend/web/index.html`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/frontend/web/index.html)  
> **Prerequisites:** `MONETIZE-01` (Account and zone ID created) & `MONETIZE-02` (`ads.txt` updated)  
> **Governance:** Per [`.agents/AGENTS.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/.agents/AGENTS.md)

---

## 1. Context & Objectives

Monetag's **Native Banner** and **MultiTag** units rotate high-fill, clean programmatic display creatives. Because `freeocr.me`'s Knowledge Base articles are statically generated from `scripts/generate_kb_static_pages.py`, modifying the template's existing `.ads-rail` / `.ads-card` container (Lines 684–688) updates all 23+ guides simultaneously in one command (`python scripts/generate_kb_static_pages.py`).

This ticket details:
1. Embedding the clean Monetag display tag into `generate_kb_static_pages.py`.
2. Setting zero-CLS CSS styling so the ad container reserves physical space before the ad loads.
3. Adding Monetag verification or header script to `src/frontend/web/index.html`.
4. Regenerating the static KB guides and verifying output.

---

## 2. Implementation Specifications

### Part A: Update `scripts/generate_kb_static_pages.py`

In [`scripts/generate_kb_static_pages.py`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/scripts/generate_kb_static_pages.py), locate the `.ads-card` element around line 685:

```html
    <aside class="ads-rail" aria-label="Sponsor and Ad Content">
      <div class="ads-card" id="monetag-ad-slot" style="min-width: 300px; min-height: 250px; display: flex; justify-content: center; align-items: center; overflow: hidden;">
        <span style="font-size: 11px; text-transform: uppercase; letter-spacing: 0.05em; color: var(--text-muted); margin-bottom: 6px; display: block; width: 100%; text-align: center;">Sponsored</span>
        
        <!-- Monetag Clean Native / Display Tag -->
        <!-- Insert the exact script tag generated from Monetag Dashboard -->
        <script>(function(s,u,z,p){s.src=u,s.setAttribute('data-zone',z),p.appendChild(s);})(document.createElement('script'),'https://alwingulla.com/88/tag.min.js',[YOUR_MONETAG_ZONE_ID],document.getElementById('monetag-ad-slot'))</script>
      </div>
    </aside>
```

*(Note: Replace `[YOUR_MONETAG_ZONE_ID]` with your exact Zone ID from Monetag's "Get Tag" screen).*

---

### Part B: Domain Verification Meta Tag in `src/frontend/web/index.html`

If Monetag requested HTML Meta tag verification, place it inside the `<head>` of [`src/frontend/web/index.html`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/frontend/web/index.html):

```html
  <!-- Monetag Domain Verification -->
  <meta name="monetag" content="[YOUR_MONETAG_VERIFICATION_TOKEN]">
```

---

### Part C: Regenerate Static Knowledge Base Pages

Run the generation script from repository root:

```powershell
python scripts/generate_kb_static_pages.py
```

Expected output:
```text
Generating Knowledge Base static HTML articles for 23 guides...
  -> src/frontend/web/kb/ocr-guide/index.html
  -> src/frontend/web/kb/searchable-pdf-vs-plain-text/index.html
  ...
Done! Generated 23 KB guides.
```

---

## 3. Visual & Layout Shift (CLS) Audit

To guarantee that Google's Core Web Vitals remain pristine:
1. **Zero CLS:** The `.ads-card` container has fixed dimensions (`min-width: 300px; min-height: 250px;`). When the ad creative loads, the surrounding article text and sidebar do **not** jump or shift.
2. **Mobile Cleanliness:** On screens narrower than 1280px, the media query `.ads-rail { display: none; }` cleanly suppresses the rail, preventing horizontal overflow or mobile clutter.
3. **Graceful Adblocker Degradation:** If uBlock Origin or Brave Shields blocks the ad script, the container simply remains empty with zero broken layout shifts or intrusive error popups.

---

## 4. Acceptance Criteria
- [ ] `scripts/generate_kb_static_pages.py` contains the Monetag tag with correct zone ID.
- [ ] All 23 static KB pages are regenerated and contain the ad tag.
- [ ] Opening `src/frontend/web/kb/ocr-guide/index.html` in Chrome displays the "Sponsored" label and loads the programmatic ad creative.
- [ ] Zero popups, zero popunders, and zero intrusive push prompts appear when interacting with the page.
