import 'web_console_stub.dart'
    if (dart.library.html) 'web_console_web.dart'
    if (dart.library.js_util) 'web_console_web.dart'
    if (dart.library.js_interop) 'web_console_web.dart'
    if (dart.library.js) 'web_console_web.dart';

/// Logs message directly into browser DevTools console (F12) on web,
/// while safely falling back on VM / test environments.
void logToBrowserConsole(String message) {
  browserConsoleLog(message);
}
