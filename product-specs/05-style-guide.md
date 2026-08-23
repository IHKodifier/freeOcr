# Style Guide: freeOCR.me

> **Stage:** 5 — Style Guide  
> **Persona:** Brand & Design Systems Lead (Apple-Inspired Design Tokens)  
> **Approved:** [x] approved  
> **Reads from:** [`01-product-brief.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/product-specs/01-product-brief.md), [`03-user-journeys.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/product-specs/03-user-journeys.md)  
> **Design Philosophy Reference:** [`apple-design`](file:///C:/Users/Ihtiram/.gemini/config/skills/apple-design/SKILL.md)  
> **Last Updated:** 2026-08-23  

---

## Brand Voice & Design Philosophy

**Three Adjectives:** **Fast · Trustworthy · Invitingly Simple**

### What It Feels Like
An Apple-grade utility — minimal, fluid, and direct. The interface behaves like physical glass and paper: drag-and-drop targets react on pointer-down, micro-animations use fluid spring physics, and complex OCR conversion pipeline mechanics are hidden behind a single, inviting hero dropzone.

### What It Should NOT Feel Like
It should **not** feel like a noisy, ad-cluttered spam converter or an intimidating enterprise software dashboard. Every element is restrained, crisp, and purposeful.

---

## Color System (Flutter Material 3 `ColorScheme`)

> All colors defined as Material 3 `ColorScheme` tokens in Flutter (`ThemeData.light().colorScheme` and `ThemeData.dark().colorScheme`). Raw hex values are restricted to token definitions.

### Material 3 `ColorScheme` Tokens

| Material 3 Token | Light Mode Hex | Dark Mode Hex | Usage |
|------------------|---------------|---------------|-------|
| `primary` | `#4F46E5` (Electric Indigo) | `#818CF8` (Light Indigo) | **Primary CTAs, active hero dropzone ring** |
| `onPrimary` | `#FFFFFF` | `#0F172A` | Text/icons on primary color |
| `primaryContainer` | `#EEF2FF` | `#312E81` | Light/Dark container fills for primary elements |
| `onPrimaryContainer` | `#312E81` | `#E0E7FF` | Text on primary container fills |
| `secondary` | `#3B82F6` (Cyber Blue) | `#60A5FA` | **Progress indicators, real-time SSE stream bars** |
| `onSecondary` | `#FFFFFF` | `#0F172A` | Text/icons on secondary color |
| `secondaryContainer` | `#DBEAFE` | `#1E3A8A` | Highlighting active preview tabs |
| `tertiary` | `#10B981` (Emerald Green) | `#34D399` | Success badges, zero-retention privacy badge |
| `surface` | `#F8FAFC` (Slate Light) | `#0F172A` (Slate Dark) | **Top-level page background** |
| `onSurface` | `#0F172A` | `#F8FAFC` | Main headings and primary body text |
| `surfaceContainer` | `#FFFFFF` | `#1E293B` (Slate Card) | Cards, dropzone background, dialog containers |
| `surfaceContainerHigh` | `rgba(255,255,255,0.75)`| `rgba(30,41,59,0.75)` | Frosted glass modals (`backdrop-filter blur 20px`) |
| `outline` | `#E2E8F0` | `#334155` | Card borders, dividers, dropzone dashed border |
| `outlineVariant` | `#CBD5E1` | `#475569` | Focus rings & active hover borders |
| `error` | `#EF4444` (Rose Red) | `#F87171` | Corrupted PDF alert, over-limit warnings |

---

## Typography

**Font Stack:**
- **Primary UI:** Google Fonts **Inter** (Optical sizing, clean geometric sans-serif).
- **OCR Text & Code Preview:** **JetBrains Mono** (Monospace font for `.txt` & `.md` side-by-side split viewer).

| Token | Font | Weight | Size | Line Height | Usage |
|-------|------|--------|------|-------------|-------|
| `text-hero` | Inter | 800 (Bold) | 3rem / 48px | 1.1 | Hero headline on Landing Page |
| `text-title-lg` | Inter | 700 (Bold) | 2rem / 32px | 1.2 | Modal & Section titles |
| `text-title-md` | Inter | 600 (SemiBold) | 1.25rem / 20px | 1.3 | Card titles, step headings |
| `text-body-lg` | Inter | 400 (Regular) | 1rem / 16px | 1.5 | Primary body text |
| `text-body-md` | Inter | 400 (Regular) | 0.875rem / 14px | 1.4 | Labels, dropzone instructions |
| `text-caption` | Inter | 500 (Medium) | 0.75rem / 12px | 1.3 | Badges, TTL notifications, ad labels |
| `text-code-preview`| JetBrains Mono | 400 (Regular) | 0.875rem / 14px | 1.6 | Side-by-side OCR text preview |

---

## Apple Design Principles & Micro-Animations

Reference: [`apple-design`](file:///C:/Users/Ihtiram/.gemini/config/skills/apple-design/SKILL.md)

### 1. Instant Pointer-Down Response
- Buttons and dropzones react on `pointer-down` (`:active` state), not waiting for touch-release.
- Primary buttons scale slightly down on press (`transform: scale(0.97)` over 100ms ease-out).

### 2. Fluid Spring Physics
All UI transitions use **critically damped springs** (no distraction, smooth settle) via Flutter `CurvedAnimation`:
- **Default UI Spring:** Damping ratio `1.0`, response `0.4s` (Smooth, instant feedback).
- **Sheet / Modal Spring:** Damping ratio `0.8`, response `0.3s` (Slight natural momentum bounce).

### 3. Translucent Materials & Depth (Frosted Glass)
- Modals, header bars, and floating action panels use translucent backdrop blurs (`BackdropFilter` with `blur(20px)` and 75% opacity).
- Subtle 1px translucent border (`border-default` at 50% opacity) creates spatial elevation without heavy drop shadows.

### 4. Direct Manipulation Dropzone
- Dropzone tracks hover state dynamically. Dragging a file over the dropzone triggers a smooth spring expansion (`scale 1.02` with an Electric Indigo glow ring).

---

## Component Specifications

### 1. Hero Drag & Drop Zone
- **Layout:** Large centered container, min-height 280px, dashed 2px border (`brand-500` on hover).
- **Background:** Translucent card surface (`surface-card`) with rounded corners (`radius-xl` 16px).
- **Default State:** Upload Icon + Title *"Drag & drop your scanned PDF here"* + Subtitle *"or click to browse files (100% Free & Privacy Ephemeral)"*.
- **Drag Hover State:** Border turns solid Electric Indigo (`brand-500`), subtle spring scale (`1.02`).

### 2. Side-by-Side Interactive Viewer
- **Left Pane:** Original scanned PDF page image viewer (High-res raster, zoomable).
- **Right Pane:** Interactive OCR text & layout viewer (Selectable text, copy button, `.txt` / `.md` tab toggles).
- **Split Slider Divider:** Drag handle with 1:1 pointer tracking.

### 3. Rewarded Ad Modal
- **Container:** Centered frosted glass overlay modal (`surface-translucent`, `radius-xl` 16px).
- **Header:** Icon + Title *"Unlock 60-Minute Session Pass"* + Subtitle *"Watch a 15-second ad to process up to 50 pages & 30MB"*.
- **Actions:** Primary CTA **[Watch Ad & Convert]** (Electric Indigo) + Secondary **[Cancel]** (Ghost button).

### 4. 35-Second Rotating Ad Slot Component
- **Container:** Secondary card container (`surface-card`) placed above the fold on Landing & Download pages.
- **Badge:** Top-left subtle tag: `SPONSORED` (text-caption, `text-muted`).
- **Timer:** Automated 35-second rotation script (`setInterval(refreshAds, 35000)`).

---

## Accessibility & Responsive Layout

- **Contrast Ratios:** All text tokens satisfy WCAG AA minimum 4.5:1 contrast against light (`#F8FAFC`) and dark (`#0F172A`) page surfaces.
- **Touch Targets:** Minimum 44×44px interactive tap area on mobile and desktop web.
- **Reduced Motion:** Respects user's system `prefers-reduced-motion` flag (falls back to simple opacity fades if motion is disabled).
