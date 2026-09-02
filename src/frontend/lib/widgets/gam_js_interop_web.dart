// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

/// Triggers GAM ad slot refresh via JS interop on Flutter Web.
void triggerGamAdSlotRefresh() {
  try {
    js.context.callMethod('refreshGamAdSlot');
  } catch (_) {}
}
