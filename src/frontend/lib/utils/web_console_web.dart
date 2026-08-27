import 'dart:html' as html;
import 'dart:developer' as developer;

/// Web implementation using native window.console.log, info, and developer.log
void browserConsoleLog(String message) {
  try {
    html.window.console.log(message);
    html.window.console.info(message);
  } catch (e) {
    // fallback if window object restricted
  }
  developer.log(message, name: 'AdSenseBanner');
}
