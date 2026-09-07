# Dispatch Prompt: Google AdSense Account Setup & Monetization Integration

> **Task ID:** `PROD-02-ADSENSE`  
> **Target Domain:** `https://freeocr.me` (Live with HTTPS on Firebase Hosting)  
> **Target Files:** `src/frontend/web/ads.txt`, `src/frontend/web/index.html`

---

## Instructions for Agent:

You are tasked with integrating **Google AdSense** into the live production site **freeOCR.me** (`https://freeocr.me`).

### Context:
1. The domain `https://freeocr.me` is already live on Firebase Hosting with an SSL certificate.
2. In-app ad slots and Google Ad Manager (GAM) declared refresh scripts are already scaffolded in `src/frontend/web/index.html` and `src/frontend/lib/widgets/gam_banner_widget.dart`.
3. An AdSense publisher ID (`pub-XXXXXXXXXXXXXXXX`) must be placed in `ads.txt` and `index.html` for Google AdSense account approval.

### Execution Steps:
1. **Update `ads.txt` (`src/frontend/web/ads.txt`):**
   - Replace placeholder `pub-XXXXXXXXXXXXXXXX` with the user's real publisher ID:
     ```text
     google.com, pub-YOUR_ACTUAL_ID, DIRECT, f08c47fec0942fa0
     ```
2. **Inject AdSense Tag in `src/frontend/web/index.html`:**
   - Add the official Google AdSense script tag in the `<head>`:
     ```html
     <script async src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-YOUR_ACTUAL_ID" crossorigin="anonymous"></script>
     ```
   - If using Google Ad Manager (GAM), update the slot path `/1234567/` with the user's real network code.
3. **Audit Pre-rendered Educational & SEO Pages:**
   - Ensure the following pre-rendered pages exist in `src/frontend/build/web/` so Google's crawler finds high-quality, non-empty content:
     - `/01-local-development.html`
     - `/02-database-and-services.html`
     - `/03-authentication-and-saas.html`
     - `/04-testing-and-qa-guide.html`
     - `/DESIGN.html`
4. **Build & Deploy Release Web Bundle:**
   ```powershell
   cd src/frontend; C:\flutter\bin\flutter.bat build web --release
   python ../../scripts/build_seo_pages.py
   firebase deploy --only hosting
   ```
5. **Verify Live Endpoints:**
   - Confirm `https://freeocr.me/ads.txt` returns `HTTP 200 OK` with proper seller record.
   - Confirm `https://freeocr.me` loads with AdSense tags in the page DOM.

Do not commit or push to remote without explicit user authorization.
