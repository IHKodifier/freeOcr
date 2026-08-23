# Testing & QA Verification Guide: freeOCR.me

This guide provides test scenarios, verification checklists, and QA procedures for testing **freeOCR.me**.

---

## 1. Quick Tester Checklist

| Feature | How to Test | Expected Behavior |
|---------|-------------|-------------------|
| **Health Check** | Open `http://127.0.0.1:8000/api/v1/health` | Returns `{"status": "ok", "version": "0.1.0"}` |
| **Runtime Config** | Open `http://127.0.0.1:8000/api/v1/config` | Returns JSON config matching `config.json` |
| **Flutter Web UI** | Run `cd src/frontend; flutter run -d chrome` | Renders headline and Material 3 Electric Indigo theme |
| **Light / Dark Mode** | Toggle OS light/dark mode preference | UI colors instantly switch between Slate Light (`#F8FAFC`) and Slate Dark (`#0F172A`) |

---

## 2. Test Scenarios for Beta Testers

### Scenario A: Standard PDF Upload & Conversion
1. Drag & drop a scanned 5-page PDF into the hero dropzone.
2. Verify real-time SSE progress updates (`Page 1 of 5...`, `Page 2 of 5...`).
3. Verify output side-by-side preview pane opens upon completion.
4. Test downloading `.pdf`, `.txt`, and `.md` formats.

### Scenario B: Stackable Rewarded Ad Limit Boost
1. Drag & drop a 30-page PDF (exceeding default `base_max_pages = 10`).
2. Verify Rewarded Ad Modal appears: *"Unlock Stackable Limit Boost (+15 Pages & +20MB per ad watched)"*.
3. Click **[Watch 15s Ad]** to simulate completing a rewarded ad.
4. Verify session limit in Redis increments to 25 pages.
5. Click **[Watch 15s Ad]** again to stack limit to 40 pages.
6. Verify file conversion begins smoothly.

### Scenario C: Instant Input File Purging (Zero Retention)
1. Convert a document and click **[Send Email Link]**.
2. Check RAM disk directory (`/tmp` / `ramdisk`); verify input file is unlinked immediately.
3. Verify link expiration timestamp is set for 24 hours.
