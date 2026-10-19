// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

/// Web implementation that programmatically dispatches a user interaction or opens a Direct Link
/// to ensure Monetag high-yield ad formats fire upon explicit user demand.
void triggerMonetagAd({String? directLinkUrl}) {
  try {
    // 1. If an explicit Monetag Direct Link URL is provided, open it in a new tab
    if (directLinkUrl != null && directLinkUrl.isNotEmpty) {
      html.window.open(directLinkUrl, '_blank');
    }

    // 2. Dispatch synthetic user interaction to allow Monetag's Vignette/OnClick listener to fire
    if (js.context.hasProperty('monetagRewardAd')) {
      js.context.callMethod('monetagRewardAd');
    }
  } catch (_) {
    // Graceful fallback
  }
}
