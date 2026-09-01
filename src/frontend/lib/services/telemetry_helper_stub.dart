import 'package:flutter/foundation.dart';

/// Fallback / Stub implementation of GA4 telemetry calls for non-web environments (tests, mobile, desktop).
void trackGa4PageView(String pagePath, String? pageTitle) {
  if (kDebugMode) {
    debugPrint('[Telemetry Stub PageView] Path: $pagePath, Title: $pageTitle');
  }
}

void trackGa4Event(String eventName, Map<String, dynamic>? parameters) {
  if (kDebugMode) {
    debugPrint('[Telemetry Stub Event] $eventName params: $parameters');
  }
}
