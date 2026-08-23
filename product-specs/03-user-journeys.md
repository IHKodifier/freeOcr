# User Journeys: freeOCR.me

> **Stage:** 3 — User Journeys  
> **Persona:** FAANG-Veteran UX Designer  
> **Approved:** [x] approved  
> **Reads from:** [`01-product-brief.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/product-specs/01-product-brief.md), [`02-architecture.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/product-specs/02-architecture.md)  
> **Last Updated:** 2026-08-23  

---

## Journey 1: First-Time Visitor → 10-Second OCR Conversion & Instant Download

**Actor:** First-time or returning anonymous web user (Zero registration required)  
**Entry Point:** `https://freeocr.me/` (Direct visit or search engine landing)  
**Goal:** Convert a scanned PDF/image into a searchable PDF or text file with zero friction  
**Aha Moment:** Dragging a PDF onto the hero dropzone and seeing an instant side-by-side searchable preview within seconds  

### Flow Diagram

```
[Entry: Landing Page (Hero Dropzone + Top Banner Ad)]
        │
        ▼
[Drag & Drop PDF or Click 'Select File']
        │
   (validation) ───► Over Limit? ──► [Journey 2: Rewarded Ad Modal]
        │
        ▼
[Processing Screen: Real-Time SSE Progress Bar ("Converting page 3 of 8... 37%")]
        │
        ▼
[Interactive Side-by-Side Preview Screen (Original Scan vs Selectable Text)]
        │
   (user choice) ───┬──► [Direct Download: Searchable PDF / .txt / .md] ──► [Input File Purged]
                    │
                    └──► [Email Delivery: Enter Email] ──► [Click 'Send Links'] ──► [Input File Purged]
```

### Emotional Journey Map

| Step | Mental State | User's Question | Design Response |
|------|-------------|----------------|-----------------|
| **Landing** | Skeptical & Hurried | *"Can I convert this PDF right now without signing up?"* | Zero-clutter hero dropzone, zero signup requirement, "100% Free & Ephemeral Privacy" badge. 35s ad banner placed above fold. |
| **Drop File** | Expectant | *"Is my file valid and safe?"* | Immediate visual feedback, file size/page check animation, instant upload confirmation. |
| **Processing** | Focused | *"How fast is this working?"* | Live SSE progress bar with page count indicator (`Page 3 of 8...`), micro-animations keeping user engaged. |
| **Preview (Aha!)**| Delighted | *"Wow, the text is actually selectable and layout is identical!"* | Side-by-side interactive split view. Left: Original Scan; Right: Selectable OCR layer. |
| **Download / Email**| Relieved | *"How long do I have to download this?"* | Clear download buttons for `.pdf`, `.txt`, `.md`. Explicit badge: *"Output files expire in 24h. Input file purged instantly."* |
| **Post-Action** | Trusting | *"Can I send this link to my email?"* | Email input field with warning: *"Check email spelling carefully — input file is deleted immediately when 'Send Links' is clicked."* |

---

## Journey 2: Stackable Rewarded Ad Limit Boosts (High-Volume / Large File Conversion)

**Actor:** Free user uploading a file exceeding active session caps (e.g., 25-page PDF when active cap is 10 pages)  
**Entry Point:** Drag-and-drop validation check  
**Goal:** Stack limit boosts indefinitely (+15 pages & +20MB per watched video ad, up to 500+ MB / 500+ pages) without paywalls  

### Flow Diagram

```
[User Drops Large PDF (e.g. 25 Pages or 40MB)]
        │
        ▼
[Limit Detection: Exceeds Base/Current Active Session Cap]
        │
        ▼
[Clean Modal: "Unlock Limit Boost (+15 Pages & +20MB per ad watched)"]
        │
        ├──► [Click 'Watch 15s Rewarded Ad'] ──► [Ad Video Plays] ──► [Ad Completed Callback] ──► [Atomic Limit Boost (+15 Pages, +20MB) in Redis] ──► [Choose: Watch Another Ad to Stack Further OR Start Conversion]
        │
        └──► [Click 'Cancel'] ──► [Return to Dropzone with Helpful Tip]
```

*Note: All base limits, per-ad boost increments, session TTLs, and max stack caps are runtime configurable via environment settings.*

### Edge Cases & Recovery

| Scenario | What Happens | Recovery Path |
|----------|-------------|---------------|
| **Ad Blocker Active** | Rewarded ad script blocked from loading | Show polite message: *"Ad blocker detected. Disable ad blocker or trim PDF to under 10 pages to proceed free."* |
| **User Closes Ad Early** | Ad video closed before completion callback | Modal alerts: *"Ad was not completed. Watch full 15-second ad to activate your 60-minute pass."* |

---

## Journey 3: Email Link Delivery & Ephemeral Input Purge Lifecycle

**Actor:** User wanting download links sent to their inbox for later access within 24 hours  
**Entry Point:** Side-by-side preview screen  
**Goal:** Email download links to `.pdf`, `.txt`, and `.md` output files  

### Step-by-Step Flow

1. User views converted PDF in the interactive split-screen viewer.
2. Below the direct download buttons, user sees the **Email Delivery Box**:
   > ✉️ **Send Download Links to Email**  
   > *Enter your email address below. Output files remain available via link for 24 hours.*  
   > ⚠️ **Important:** Input file is permanently deleted from server memory immediately upon clicking 'Send Email'. Make sure your address is correct.
3. User types email address and clicks **[Send Download Links]**.
4. Frontend triggers `POST /api/v1/ocr/email-links`.
5. **Backend Execution:**
   - Email dispatch job queued (Resend / SMTP).
   - Python context manager immediately executes `os.remove()` / `tmpfs` unlinking on original input file.
6. UI displays success toast: *"Download links sent to user@example.com! Original input file has been permanently purged."*

---

## Journey 4: Encrypted or Corrupted PDF Repair & Recovery

**Actor:** User uploading a password-protected or structurally damaged scanned PDF  
**Entry Point:** File upload validation phase  

### Flow & Recovery Strategy

#### Path A: Password-Protected PDF
1. System detects encrypted PDF payload.
2. Inline Password Prompt appears over dropzone:
   > 🔒 **Password Protected PDF**  
   > *This file is encrypted. Enter password to decrypt and run OCR:*  
   > `[ Password Input Field ]` `[ Unlock & Process ]`
3. User enters password → File decrypted in RAM → OCR pipeline resumes seamlessly.

#### Path B: Corrupted Scanned PDF
1. File parsing fails due to broken PDF header or corrupted raster stream.
2. UI displays reassuring status banner:
   > 🛠️ *"Your file has structural errors. Attempting automated PDF repair..."*
3. Backend runs automated fallback repair script (`pdfcpu repair` / `qpdf` / `ghostscript`).
4. If repaired successfully: Conversion continues without requiring user re-upload.
5. If unfixable: Clear error message displayed with instructions on how to re-scan or re-save the document.

---

## Ad Placement & 35-Second Rotation Policy

To ensure strong monetization without degrading user experience:

- **Landing Page Ad:** Non-intrusive 728x90 leaderboard banner placed above the fold, directly above the dropzone.
- **Download Page Ad:** Banner ad displayed above the fold on the results/download screen.
- **35-Second Rotation Rule:** All display ad slots utilize an automated 35-second refresh timer script (`setInterval(refreshAds, 35000)`) as long as the page tab remains open and active.

---

## Screen Inventory

| Screen / View Name | Route / Component | First Appears In | Auth Required | Key Components |
|-------------------|-------------------|-----------------|---------------|----------------|
| **Home / Landing** | `/` | Journey 1 | No | 35s Leaderboard Ad Banner, Zero-Clutter Hero Dropzone, Ephemeral Privacy Badge |
| **Conversion Progress** | Inline Overlay | Journey 1 | No | Real-time SSE Progress Bar, Page Counter (`Page 3 of 8`), Micro-animations |
| **Side-by-Side Preview & Download** | `/result/{job_id}` | Journey 1 | No | Interactive Split Viewer (Original vs OCR Text), Direct Download Buttons (`.pdf`, `.txt`, `.md`), Email Delivery Input, 24h Expiration Badge, 35s Ad Banner |
| **Rewarded Ad Modal** | Modal Dialog | Journey 2 | No | Limit Exceeded Alert, Rewarded Video Player, 60-Minute Pass Confirmation |
| **Password Unlock Prompt** | Modal / Inline | Journey 4 | No | Password Input Field, Unlock & Process CTA |
| **PDF Repair Banner** | Processing Toast | Journey 4 | No | Animated Repair Status (`"Attempting PDF Repair..."`) |
