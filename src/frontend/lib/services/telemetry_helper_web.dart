// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;
import 'package:flutter/foundation.dart';

/// Web-specific implementation calling GA4 JS interop functions defined in `index.html`.
void trackGa4PageView(String pagePath, String? pageTitle) {
  try {
    if (js.context.hasProperty('trackGa4PageView')) {
      js.context.callMethod('trackGa4PageView', [pagePath, pageTitle]);
    } else if (kDebugMode) {
      debugPrint('[Telemetry Web] trackGa4PageView JS function not found');
    }
  } catch (e) {
    if (kDebugMode) {
      debugPrint('[Telemetry Web Error] trackGa4PageView failed: $e');
    }
  }
}

void trackGa4Event(String eventName, Map<String, dynamic>? parameters) {
  try {
    if (js.context.hasProperty('trackGa4Event')) {
      final jsParams = parameters != null ? js.JsObject.jsify(parameters) : null;
      js.context.callMethod('trackGa4Event', [eventName, jsParams]);
    } else if (kDebugMode) {
      debugPrint('[Telemetry Web] trackGa4Event JS function not found');
    }
  } catch (e) {
    if (kDebugMode) {
      debugPrint('[Telemetry Web Error] trackGa4Event failed: $e');
    }
  }
}
