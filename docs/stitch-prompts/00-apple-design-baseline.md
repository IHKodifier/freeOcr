# Apple Design System Baseline (Stitch Prompt Template)

Governed by [`skills/apple-design/SKILL.md`](file:///e:/Non_Office/Dev_Space/vibe_skool/freeOcr/skills/apple-design/SKILL.md).

---

## Design System Baseline Specification

Every screen and UI variant generated via Google Stitch must conform to these Apple Design foundations:

1. **Fluid Motion & Physics-Based Springs:**
   - Default UI transitions use critically damped springs (**Damping `1.0`**, **Response `0.4s`**) for zero overshoot and natural settling.
   - Momentum-driven gestures (flicks, drag releases, sheet dismissals) use bouncier springs (**Damping `0.8`**, **Response `0.3s`**).
   - Every motion is **100% interruptible** — animations start from the live presentation value and inherit pointer velocity without hard-cuts or input lockouts.
2. **Response & Direct Manipulation:**
   - Feedback triggers instantly on `pointerdown` (`active` state `transform: scale(0.97)`). Zero tap delay (~300ms delay eliminated).
   - 1:1 direct tracking with `setPointerCapture` so content stays glued to the user's touch/cursor point.
3. **Materials, Depth & Translucency:**
   - Frosted glassmorphism surfaces (`backdrop-filter: blur(16px)` / `saturation(180%)`, background `rgba(255, 255, 255, 0.7)` in Light Mode and `rgba(15, 23, 42, 0.75)` in Dark Mode).
   - Subtle high-precision borders (`1px solid rgba(255, 255, 255, 0.12)` in Dark Mode, `1px solid rgba(0, 0, 0, 0.08)` in Light Mode).
4. **Spatial Consistency & Origin Anchoring:**
   - Menus, sheets, and popovers animate out from their trigger element (`transform-origin` set to trigger position).
   - Enter and exit paths are strictly symmetric (slide-in from right exits to right).
5. **Responsive Viewport Breakpoints & Theme Adaptation:**
   - **Phone (<640px):** Single-column stacked layouts, bottom action sheets, full-width touch targets (minimum 44x44pt).
   - **Tablet (640px – 1024px):** Adaptive split views, collapsible sidebars, multi-touch gesture support.
   - **Desktop (>1024px):** Side-by-side dual-pane workspace, keyboard shortcuts, floating action bar.
   - High-contrast automatic **Light Mode** (#F8FAFC) & **Dark Mode** (#0F172A) with vibrant indigo/violet primary accents (#6366F1).
