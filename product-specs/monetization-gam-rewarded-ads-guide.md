# Monetization Reference: Google Ad Manager (GAM), AdSense for Games (AFG), and Rewarded Web Video Policies

> **Status:** Active Reference Document  
> **Applicability:** `freeocr.me`, `freepdftoolz.me`, and future sister utility platforms (`freefileconverter.me`)  
> **Activation Trigger:** To be referenced and activated once standard Google AdSense site approval is obtained (`kAdSenseApproved = true`).

---

## 1. Executive Summary

This reference details the approval pipelines, eligibility boundaries, and compliance architectures for monetizing lengthy document processing and tiered upload limits across our utility web applications:
1. **Google Ad Manager (GAM)** is the recommended mediation and ad-serving hub; it is instantly accessible once AdSense is approved and natively supports compliant ad refreshing.
2. **AdSense for Games (AFG)** is **NOT** applicable to utility/SaaS tools and will result in rejection if applied for directly.
3. **Rewarded Limit Boosting** qualifies legally under Google's **Rewarded Inventory / Value Exchange Policy** via GAM or Google AdSense Rewarded Web Ad Units, not via gamification/AFG.
4. **Ad Rotation during long processing jobs** is fully compliant when declared through GAM's official inventory refresh mechanisms or tied to event-driven processing state transitions.

---

## 2. Approval Pipelines & Onboarding Mechanics

### 2.1 Google Ad Manager (GAM - Small Business)
- **Prerequisites:** A valid, active, and fully approved Google AdSense account.
- **Onboarding Pipeline:**
  1. Visit [admanager.google.com](https://admanager.google.com/).
  2. Sign in with the Google Account that owns the approved AdSense account.
  3. Select currency, network billing time zone, and accept terms.
  4. **Approval Duration:** **Instantaneous.** No secondary domain audit or site crawl delay is required. Your network ID is created immediately.
- **Key Capabilities Enabled:**
  - Dynamic allocation: AdSense automatically competes against 3rd-party networks and direct sponsors in real time.
  - Granular key-value targeting (e.g. targeting ads specifically to PDF conversion vs OCR scanning).
  - Native, compliant ad refresh management.

### 2.2 AdSense for Games (AFG) vs AdSense for Video (AFV)
- **Target Products:**
  - **AFG:** Dedicated HTML5 / WebGL games (interactive canvases, game engines like Unity/Phaser).
  - **AFV:** Dedicated web video players (video content with pre-roll, mid-roll, post-roll).
- **Eligibility Barrier for Utilities:**
  - A PDF tool, OCR engine, or file converter is **NOT** a game or video publisher.
  - Submitting our domain directly to the Google AFG application queue will result in an immediate policy rejection for "Invalid Content / Not a Game".
- **Approval Pipeline:** Strict manual gate requiring proof of substantial interactive gameplay or video playback traffic (typically 500k+ monthly stream requests) or onboarding through a certified Google MCM (Multiple Customer Management) Partner.

---

## 3. Rewarded Limit Boosting: "Gamification" vs "Value Exchange"

### 3.1 Policy Classification
Our file limit expansion model (e.g., watching a sponsor message to boost upload capacity from 25 MB to 75 MB for 60 minutes) is **NOT** classified by Google as "gamification." It is classified as **Rewarded Web Inventory** under Google's **Value Exchange Policy**.

### 3.2 Google Value Exchange Compliance Checklist
To maintain 100% compliance when integrating live rewarded ad units:

| Rule | Implementation Requirement | Our Architecture Status |
| :--- | :--- | :--- |
| **Explicit Value Declaration** | The user must be informed of the exact reward *before* choosing to engage (e.g., `+50 MB limit boost`). | ✅ Modal explicitly announces `+50 MB` and resulting quota. |
| **Voluntary Opt-In Only** | Rewarded ads must **NEVER** launch unexpectedly, automatically on page load, or without a conscious user click. | ✅ Modal requires manual tap on "Watch Ad to Stack Boost". |
| **No Incentivized Clicks** | Publishers may reward users for *viewing* an ad, but must **NEVER** instruct, encourage, or require users to *click* the ad creative itself. | ✅ Modal tracks completion of view duration only; creative clicks are never demanded. |
| **Guaranteed Fulfillment** | Upon video ad completion or dismissal after the required threshold, the stated reward must be unlocked immediately. | ✅ State machine instantly triggers quota expansion and local file acceptance. |
| **Exit Option** | A visible, functioning close/cancel button must always be available to abort without receiving the reward. | ✅ Modal includes an explicit close (`X`) button and confirmation alert. |

---

## 4. 60-Second Ad Rotation During Lengthy Processing

When users upload multi-page documents (e.g., 50-page scanned PDFs), processing can take 30 to 90 seconds. Displaying ads during this idle waiting period requires strict adherence to refresh policies.

### 4.1 What Violates AdSense Direct Rules
- ❌ **Client-Side JavaScript Timers:** Using `setInterval()` or `setTimeout()` in Dart/JS to destroy and re-insert Google AdSense `<ins>` tags or re-execute `adsbygoogle.push({})` is a **direct policy violation** that leads to ad serving suspension.

### 4.2 What Is 100% Compliant

#### Option 1: GAM Official Inventory Auto-Refresh (Recommended)
Inside the Google Ad Manager dashboard:
1. Navigate to **Inventory** &rarr; **Ad Units**.
2. Select or create the ad unit placed next to the processing/progress view (e.g., `Processing_Leaderboard_300x250` or `Processing_Responsive_Banner`).
3. Set **Refresh rate** to **Dynamic** or **60 seconds** (Google allows 30s minimum, with 60s recommended for maximum eCPM and fill rates).
4. GAM's `gpt.js` (Google Publisher Tag) handles the auction, refresh signal, and viewability tracking automatically.
5. **Viewability Requirement:** The ad unit must remain in-viewport (at least 50% visible). Because the user is watching the live SSE processing bar, this criteria is naturally satisfied.

#### Option 2: Event-Driven Stage Transitions
Rather than relying solely on a fixed clock, trigger refreshed ad units when the backend advances through major, meaningful pipeline phases:
- **Phase 1 (0s):** Document Upload & RAM Disk Staging &rarr; Render Banner A.
- **Phase 2 (30s+):** OCR Model Execution / Page Scanning &rarr; Request Next Slot B.
- **Phase 3:** Searchable PDF Compilation & Compression &rarr; Transition to Result Summary Slot C.

Each phase represents a distinct view state change, which Google Publisher Tag (`gpt.js`) classifies as a legitimate content refresh.

---

## 5. Post-Approval Activation Roadmap

Once the Google AdSense approval email is received for `freeocr.me` / `freepdftoolz.me`:

1. **Enable Display Ad Units:**
   - Update `kAdSenseApproved = true` in `src/frontend/lib/widgets/adsense_banner.dart`.
   - Replace dummy test client IDs (`ca-pub-XXXXXXXXXXXXXXXX`) with production publisher and ad slot IDs.
2. **Activate Google Ad Manager:**
   - Sign up at `admanager.google.com` using the primary AdSense Google account.
   - Set up Ad Units for:
     - `Header_Banner` (Leaderboard 728x90 / responsive)
     - `Footer_Banner` (300x250 / responsive)
     - `Processing_Progress_Slot` (Auto-refresh enabled at 60s)
3. **Transition Rewarded Boost from Option A to Live Rewarded Ads:**
   - Flip `isAdPlaybackEnabled` to true.
   - Replace the simulated playback timer in `src/frontend/lib/widgets/rewarded_video_ad_modal.dart` with the Google Publisher Tag (GPT) Rewarded Web Ad API (`googletag.defineOutOfPagePassback` / `rewardedSlot.show()`).
