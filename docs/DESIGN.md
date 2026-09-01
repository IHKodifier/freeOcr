---
name: Apple Design System (freeOCR.me)
colors:
  surface: '#F8FAFC'
  surface-dim: '#E2E8F0'
  surface-bright: '#FFFFFF'
  surface-container-lowest: '#FFFFFF'
  surface-container-low: '#F1F5F9'
  surface-container: '#E2E8F0'
  surface-container-high: '#CBD5E1'
  surface-container-highest: '#94A3B8'
  on-surface: '#0F172A'
  on-surface-variant: '#475569'
  outline: '#94A3B8'
  outline-variant: '#CBD5E1'
  primary: '#6366F1'
  on-primary: '#FFFFFF'
  primary-container: '#EEF2FF'
  on-primary-container: '#3730A3'
  secondary: '#4F46E5'
  on-secondary: '#FFFFFF'
  secondary-container: '#E0E7FF'
  on-secondary-container: '#312E81'
  tertiary: '#10B981'
  on-tertiary: '#FFFFFF'
  background: '#F8FAFC'
  on-background: '#0F172A'
typography:
  headline-xl:
    fontFamily: Inter
    fontSize: 48px
    fontWeight: '700'
    lineHeight: 56px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  body-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-sm:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.05em
rounded:
  sm: 0.375rem
  DEFAULT: 0.75rem
  md: 1rem
  lg: 1.5rem
  full: 9999px
spacing:
  unit: 4px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 48px
  max-width: 1280px
---

## Apple Design System Baseline — freeOCR.me

### 1. Motion & Physics
- Critically damped spring physics for all UI state transitions (Damping 1.0, Response 0.4s).
- Bouncy momentum spring physics for flicks and sheet dismissals (Damping 0.8, Response 0.3s).
- 100% interruptible interactive gestures inheriting pointer velocity.

### 2. Materials & Translucency
- Frosted glassmorphism surfaces (`backdrop-filter: blur(16px)` / `saturation(180%)`).
- Subtle high-precision translucent borders (`1px solid rgba(255, 255, 255, 0.12)` in Dark Mode, `1px solid rgba(0, 0, 0, 0.08)` in Light Mode).

### 3. Spatial Consistency & Viewports
- Origin-anchored popovers and action sheets.
- Responsive breakpoints: Mobile (<640px), Tablet (640px-1024px), Desktop (>1024px).
- High contrast Light Mode (#F8FAFC) & Dark Mode (#0F172A) with vibrant indigo/violet accents (#6366F1).
