# Google Stitch Prompt: Interactive Split Preview Viewer (`/result/{job_id}`)

> **Route:** `/result/{job_id}`  
> **Governance:** [`skills/apple-design/SKILL.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/skills/apple-design/SKILL.md)  

---

## Stitch Copy-Pasteable Prompt

```text
Design an interactive PDF split-view comparison screen for freeOCR.me following Apple Design fluid interface standards.

Layout & Components:
- Header: Back button ("Back to Converter Home") with spring hover effect, document title ("scanned_invoice_2026.pdf"), and 1-click download menu (Searchable PDF, Raw Text .txt, Markdown .md).
- Top Ad Banner: Policy-compliant Google AdSense unit with user-event rotation triggers.
- Main Split Viewer Area:
  - Left Panel: Original scanned document image render with fluid zoom controls (+ / - / fit width).
  - Right Panel: Extracted OCR text overlay rendered in JetBrains Mono / SF Mono, interactive search bar, copy-to-clipboard button with instant feedback checkmark animation.
  - Middle Divider: Draggable split handle with 1:1 pointer capture, velocity-aware release, and momentum projection (damping 0.8, response 0.3s).
- Bottom Action Dock: Floating glassmorphic bar with "Convert Another File" button and "Download Searchable PDF" primary CTA.
- Responsive Behavior: Side-by-side on Desktop (>1024px), tabbed/stacked view on Phone (<640px).
```
