# Flutter Mount Layout Shift & Translation Fix

> **Target File:** [`src/frontend/web/index.html`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/frontend/web/index.html)  
> **Target Recording:** [`scratch/2026-10-07 11 34 11.mp4`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/scratch/2026-10-07%2011%2034%2011.mp4) (Shift at second 00:04)  
> **Goal:** Eliminate the 14px upward jump during WebAssembly/CanvasKit mounting, achieving a stationary cross-fade between static HTML and the interactive Flutter canvas.

---

## The Three Root Causes

1. **Artificial CSS `translateY(-6px)` Animation (Line 1282):**
   The script explicitly animates the static shell 6px upward while fading it out, causing a visual jerk while Flutter renders stationary underneath.
2. **Top Margin Misalignment (8px Delta):**
   - HTML Announcement Banner starts at `Y = 92px` (72px header + 10px container pad + 10px banner margin).
   - Flutter Announcement Banner starts at `Y = 100px` (72px AppBar + 8px body pad + 10px SizedBox + 10px banner margin).
3. **Hero Dropzone Padding Misalignment (8px Delta):**
   - HTML Dropzone has `padding: 28px 20px; border-radius: 24px;`.
   - Flutter Dropzone (`hero_dropzone.dart`) has `padding: 20px 20px; border-radius: 20px;`.

---

## The 3 Code Changes to Fix 100%

All edits are located in [`src/frontend/web/index.html`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/src/frontend/web/index.html):

### Change 1: Remove `translateY(-6px)` from Unmount Script
**Location:** Around line 1280

```diff
       function hideStaticShell() {
         if (hasTransitioned) return;
         hasTransitioned = true;
         var shell = document.getElementById('app-loading-shell');
         var editorial = document.getElementById('editorial-content');
         if (shell) {
           shell.style.opacity = '0';
-          shell.style.transform = 'translateY(-6px)';
           setTimeout(function() {
             if (shell && shell.parentNode) shell.parentNode.removeChild(shell);
           }, 360);
         }
       }
```

---

### Change 2: Align Container Padding to Match Flutter (Y = 100px)
**Location:** Around lines 160–167

```diff
     #app-loading-shell {
       position: relative;
       z-index: 1;
       width: 100%;
-      transition: opacity 0.35s cubic-bezier(0.4, 0, 0.2, 1), transform 0.35s cubic-bezier(0.4, 0, 0.2, 1);
+      transition: opacity 0.35s ease-out;
     }
     .shell-container {
       max-width: 1200px;
       margin: 0 auto;
-      padding: 10px 16px 24px;
+      padding: 18px 16px 24px;
       box-sizing: border-box;
     }
```

*(Note: Increasing `.shell-container` top padding from `10px` to `18px` aligns the HTML orange banner top from `92px` to exactly `100px`, matching the Flutter canvas Y coordinate.)*

---

### Change 3: Synchronize Dropzone Padding & Radius
**Location:** Around line 828

```diff
           <!-- Hero Dropzone Skeleton -->
           <div style="width: 100%;
-            border-radius: 24px;
+            border-radius: 20px;
             background: var(--dropzone-bg);
             border: 2px dashed var(--dropzone-border);
             box-shadow: var(--dropzone-shadow);
-            padding: 28px 20px;
+            padding: 20px 20px;
             display: flex;
             flex-direction: column;
             align-items: center;
             text-align: center;
             box-sizing: border-box;
             backdrop-filter: blur(12px);
             -webkit-backdrop-filter: blur(12px);
             animation: subtleGlow 3s infinite ease-in-out;">
```

---

## Expected Result Post-Patch

* **Static HTML:** Renders at `Y = 100px` on first contentful paint.
* **Flutter Canvas:** Mounts at `Y = 100px` directly underneath.
* **Transition:** Zero vertical or horizontal pixel movement. The static shell dissolves in place with `opacity: 0` over 360ms, creating a completely seamless cross-fade.
