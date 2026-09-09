// ignore: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;

/// Web implementation using immediate synchronous HTML Anchor trigger to guarantee
/// that Chrome, Edge, and other browsers preserve active user gesture, avoid 5-second
/// transient activation expiration on large files, and stream directly to disk.
void triggerDownload(String url, String filename) {
  // 1. First, check for JS interop downloader in index.html
  if (js.context.hasProperty('downloadFileFromUrl')) {
    try {
      js.context.callMethod('downloadFileFromUrl', [url, filename]);
      return;
    } catch (_) {
      // Fallback to Dart implementation below
    }
  }

  _directAnchorDownload(url, filename);
}

void _directAnchorDownload(String url, String filename) {
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', filename)
    ..style.display = 'none';
  html.document.body?.children.add(anchor);
  anchor.click();
  Timer(const Duration(seconds: 5), () {
    anchor.remove();
  });
}

