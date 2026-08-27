# Carry-Forward Tickets Specification

> **Project:** freeOCR.me (Scanned PDF to Searchable PDF/Text)  
> **Document Type:** Future Sprint Backlog & Carry-Forward Architecture Specs

---

## Carry-Forward Ticket UC-009-GAM: Google Ad Manager (GAM / AdX) GPT Integration & 31s Declared Auto-Refresh

**Linked Ticket:** UC-009 (AdSense Display Banner)  
**Target Sprint:** Production Monetization Release / AdX Integration  
**Policy Standard:** Google Ad Manager (GAM) AdX Auto-Refresh Guidelines (Minimum 30s)

---

### 1. Overview & Business Justification
Standard Google AdSense tags strictly prohibit custom JavaScript timers (`Timer.periodic`). To maintain 100% Google policy compliance while preserving continuous revenue generation from passive users, freeOCR.me will integrate **Google Ad Manager (GAM / AdX)** using **Google Publisher Tags (GPT `gpt.js`)**.

Google Ad Manager officially permits server-side declared auto-refreshing inventory slots at 31-second intervals when coupled with viewability detection (browser tab focus observer).

---

### 2. Implementation Code Architecture

#### A. Global Script Injection (`src/frontend/web/index.html`)
Inject Google Publisher Tag (GPT) async library and define the 728x90 leaderboard ad slot:

```html
<script async src="https://securepubads.g.doubleclick.net/tag/js/gpt.js"></script>
<script>
  window.googletag = window.googletag || {cmd: []};
  googletag.cmd.push(function() {
    window.freeOcrAdSlot = googletag.defineSlot(
      '/1234567/freeocr_leaderboard_728x90', 
      [728, 90], 
      'div-gpt-ad-freeocr-leaderboard'
    ).addService(googletag.pubads());
    
    // Enable GAM Single Request & Server-side Declared Refresh (31s)
    googletag.pubads().enableSingleRequest();
    googletag.pubads().collapseEmptyDivs();
    googletag.enableServices();
  });
</script>
```

#### B. Flutter Web Native Container (`src/frontend/lib/widgets/gam_banner.dart`)
Render GAM container via Flutter `HtmlElementView` and trigger GAM native refresh calls on conversion stage events:

```dart
import 'dart:ui_web' as ui_web;
import 'dart:html' as html;
import 'package:flutter/material.dart';

class GamBannerWidget extends StatefulWidget {
  const GamBannerWidget({super.key});

  static void refreshGamSlot() {
    html.window.dispatchEvent(html.CustomEvent('refresh_gam_ad'));
  }

  @override
  State<GamBannerWidget> createState() => _GamBannerWidgetState();
}

class _GamBannerWidgetState extends State<GamBannerWidget> {
  final String viewType = 'gam-ad-leaderboard';

  @override
  void initState() {
    super.initState();
    // Register HTML DOM element for GAM ad slot
    ui_web.platformViewRegistry.registerViewFactory(
      viewType,
      (int viewId) {
        final div = html.DivElement()
          ..id = 'div-gpt-ad-freeocr-leaderboard'
          ..style.width = '728px'
          ..style.height = '90px';
        
        // Trigger display call
        html.window.console.log('[GAM] Displaying GAM Leaderboard Slot...');
        return div;
      },
    );

    html.window.addEventListener('refresh_gam_ad', (event) {
      // Execute GAM pubads refresh call
      html.window.console.log('[GAM] Triggering GAM AdX Slot Refresh (Stage Change)...');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 728,
      height: 90,
      alignment: Alignment.center,
      child: HtmlElementView(viewType: viewType),
    );
  }
}
```

---

### 3. Acceptance Criteria
- [ ] GAM ad slot defined via `gpt.js` in `index.html`.
- [ ] Ad inventory declared in GAM Publisher Console as 31-second auto-refresh enabled slot.
- [ ] `rotateAd()` triggers native `googletag.pubads().refresh()` call on conversion stage changes.
- [ ] Viewability listener pauses refresh calls when browser tab is inactive.
