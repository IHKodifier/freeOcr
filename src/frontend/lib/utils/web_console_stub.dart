import 'dart:developer' as developer;

/// Non-web stub for console logging using developer.log
void browserConsoleLog(String message) {
  developer.log(message, name: 'AdSenseBanner');
}
