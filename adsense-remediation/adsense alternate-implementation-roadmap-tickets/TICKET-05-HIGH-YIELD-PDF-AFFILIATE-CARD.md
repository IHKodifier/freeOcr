# TASK DISPATCH: TICKET-05 — High-Yield PDF SaaS Affiliate Recommendation Engine

> **Ticket ID:** `MONETIZE-05`  
> **Target Domain:** `https://freeocr.me`  
> **Estimated Execution Time:** 20 Minutes  
> **Actor:** Coding Agent & Publisher  
> **Target Files:**  
> - [`scripts/generate_kb_static_pages.py`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/scripts/generate_kb_static_pages.py)  
> - [`src/frontend/lib/screens/home_screen.dart`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/frontend/lib/screens/home_screen.dart) (Optional Flutter native widget)  
> **Affiliate Networks:** Impact.com / ShareASale (EaseUS PDF Editor, CloudConvert, PDF Extra)  
> **Payout Rail:** Payoneer -> HBL Pakistan (or Direct Bank Wire)  
> **Governance:** Per [`.agents/AGENTS.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/.agents/AGENTS.md)

---

## 1. Context & Objectives

Display ad networks (Monetag/Adsterra) pay on impressions (CPM: ~$1.00 per 1,000 views). On early-stage traffic, 100 views earn ~$0.10.

However, visitors to `freeOCR.me` are professionals, students, and legal workers dealing with complex PDF workflows. Recommending a premium desktop PDF editor (e.g. for batch editing, redaction, or signing) converts at high rates. A **single software purchase pays between $15.00 and $35.00 in cash commission** directly to your Payoneer/HBL account.

### Why this is a game-changer:
1. **Zero traffic barrier:** Anyone can register on Impact.com or ShareASale instantly.
2. **100% Adblock Immune:** Written in clean semantic HTML/CSS, not blocked by uBlock Origin or Brave.
3. **Zero Third-Party JS:** Zero tracking scripts; lightning-fast page speed.
4. **100% Co-existence:** Contractually non-exclusive with all display ad networks.

---

## 2. Recommended Affiliate Programs for HBL Payout

| Affiliate Program | Network | Commission Rate | Payout Method to Pakistan | Direct Signup Link |
| :--- | :---: | :---: | :---: | :--- |
| **EaseUS PDF Editor** | Impact.com | **30% – 50% ($15–$30/sale)** | Payoneer -> HBL / Wire | [impact.com](https://impact.com/) |
| **PDF Extra (MobiSystems)** | ShareASale / Impact | **40% ($20–$35/sale)** | Payoneer -> HBL / Wire | [shareasale.com](https://www.shareasale.com/) |
| **CloudConvert** | Direct / Impact | **20% Recurring** | Payoneer -> HBL / Wire | [cloudconvert.com](https://cloudconvert.com/) |

---

## 3. Implementation Specifications

### Part A: Create Native Recommendation Card Component

In [`scripts/generate_kb_static_pages.py`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/scripts/generate_kb_static_pages.py), add an authoritative recommendation card right after the main article text (before the freeOCR CTA):

```html
        <!-- High-Intent PDF Utility Recommendation (100% AdBlock-Immune Native Card) -->
        <div class="partner-recommendation-card" style="background: var(--tip-bg); border: 1px solid var(--tip-border); border-radius: 12px; padding: 1.5rem; margin: 2rem 0; display: flex; flex-direction: column; gap: 0.75rem;">
          <div style="display: flex; align-items: center; justify-content: space-between;">
            <span style="font-size: 0.75rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.08em; color: var(--accent-light);">Recommended Desktop Utility</span>
            <span style="font-size: 0.75rem; color: var(--text-muted);">Partner Tool</span>
          </div>
          <h3 style="font-size: 1.15rem; font-weight: 700; margin: 0; color: var(--heading);">Need Offline Batch OCR or Advanced PDF Editing?</h3>
          <p style="font-size: 0.92rem; color: var(--text-main); margin: 0; line-height: 1.5;">
            While freeOCR.me is optimized for secure online recognition, power users handling multi-gigabyte archival batches or redaction workflows can explore <strong>EaseUS PDF Editor</strong>.
          </p>
          <div style="margin-top: 0.5rem;">
            <a href="[YOUR_AFFILIATE_TRACKING_URL]" target="_blank" rel="sponsored nofollow noopener" style="display: inline-flex; align-items: center; gap: 6px; background: var(--accent); color: #ffffff; text-decoration: none; padding: 0.55rem 1.25rem; border-radius: 8px; font-weight: 600; font-size: 0.88rem; transition: background 0.15s ease;">
              <span>Explore Offline Batch Editor &rarr;</span>
            </a>
          </div>
        </div>
```

---

### Part B: Regenerate All KB Pages

Run the generation script:
```powershell
python scripts/generate_kb_static_pages.py
```

---

## 4. Verification & Legal Tagging

- **Mandatory Link Attributes:** Every affiliate link must include `rel="sponsored nofollow noopener"`. This protects your domain from search engine link spam penalties.
- **Visual Design:** The card integrates seamlessly with the existing dark/light CSS variables (`--tip-bg`, `--tip-border`, `--accent`).
- **Click Tracking:** Verify clicking the button opens the partner landing page in a new tab with your affiliate tracking cookie intact.

---

## 5. Acceptance Criteria
- [ ] Affiliate tracking link obtained from Impact.com or ShareASale.
- [ ] Native recommendation card inserted into `scripts/generate_kb_static_pages.py`.
- [ ] 23 static KB pages regenerated with the card visible.
- [ ] Links properly tagged with `rel="sponsored nofollow noopener"`.
- [ ] Payout method configured in Impact/ShareASale targeting personal Payoneer or HBL account.
