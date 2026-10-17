# TASK DISPATCH: TICKET-06 — Infolinks Secondary Contextual In-Screen Layer

> **Ticket ID:** `MONETIZE-06`  
> **Target Domain:** `https://freeocr.me`  
> **Estimated Execution Time:** 15 Minutes (Application today; 10 min tag insert upon 24–48h approval)  
> **Actor:** Publisher & Coding Agent  
> **Target Files:**  
> - [`src/frontend/web/index.html`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/frontend/web/index.html)  
> - [`src/frontend/web/ads.txt`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/frontend/web/ads.txt)  
> **Payout Rail:** Payoneer -> HBL Pakistan (or SWIFT Bank Wire)  
> **Governance:** Per [`.agents/AGENTS.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/.agents/AGENTS.md)

---

## 1. Context & Objectives

**Infolinks** is one of the oldest and most respected ad networks in the world. It was engineered specifically to run *on top of* existing display networks without competing for layout slots.

It specializes in non-intrusive units:
- **InFold:** A sleek, non-intrusive slide-up banner that sits at the bottom edge of the browser viewport.
- **InTag:** A compact tag cloud unit placed at the bottom of articles.
- **InText:** Contextual hyperlinks within educational text.

### Key Publisher Parameters:
- **Traffic Requirement:** Very low (<1,000 visits/mo accepted).
- **Approval Window:** 24 to 48 hours.
- **Payout to Pakistan:** Payoneer (minimum $50) -> withdraws directly to HBL in PKR, or Direct Bank Wire to HBL SWIFT (`HABBPKKA`).
- **Co-existence:** 100% non-exclusive. Explicitly approved by Google AdSense and third-party ad exchanges.

---

## 2. Step 1: Submit Application (Today — 5 mins)

1. Go to [infolinks.com/join-us](https://www.infolinks.com/join-us/) and choose **Publisher Sign Up**.
2. Enter your Name, Email, and Website URL: `https://freeocr.me`.
3. In the application notes, mention: *"Technology and Document Productivity utility with comprehensive technical Knowledge Base guides."*
4. In Payment Preferences, select **Payoneer** (recommended for low $50 threshold into HBL) or **Bank Wire**.
5. Submit. You will receive an email confirmation within 24–48 hours containing your publisher script tag.

---

## 3. Step 2: Code Integration (Upon Approval — 10 mins)

Once approved, integrate the lightweight asynchronous script into [`src/frontend/web/index.html`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/frontend/web/index.html) just before the closing `</body>` tag:

```html
  <!-- Infolinks Smart Contextual Script -->
  <script type="text/javascript">
    var infolinks_pid = [YOUR_INFOLINKS_PID];
    var infolinks_wsid = [YOUR_INFOLINKS_WSID];
  </script>
  <script type="text/javascript" src="//resources.infolinks.com/js/infolinks_main.js" async></script>
```

### Portal Safety Settings (Do NOT skip):
In the Infolinks dashboard under **Ad Units**:
- **ENABLE InFold:** Keep active (clean, docked footer unit).
- **ENABLE InTag:** Keep active.
- **DISABLE InScreen:** (Full-page interstitials must be turned OFF to protect Core Web Vitals and user trust).

### Update `src/frontend/web/ads.txt`:
Infolinks provides a list of authorized seller lines in their dashboard. Append them to [`src/frontend/web/ads.txt`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/frontend/web/ads.txt):

```text
# Infolinks Authorized Digital Sellers
infolinks.com, [YOUR_PID], DIRECT
```

---

## 4. Acceptance Criteria
- [ ] Application submitted to Infolinks.
- [ ] Payout method set to Payoneer (linked to HBL).
- [ ] Ticket marked pending in `00-PROGRESS-TRACKER.md` awaiting approval email.
- [ ] Once approved, InScreen popups disabled in dashboard, and script placed in `index.html`.
