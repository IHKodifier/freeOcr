// ignore: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;

/// Web implementation using HTML Anchor element and Blob to guarantee
/// that Chrome, Edge, and other browsers always save the file with the exact filename and extension (.pdf, .txt, .md).
void triggerDownload(String url, String filename) {
  // First, check for JS interop downloader in index.html which handles fetch -> Blob -> Anchor reliably
  if (js.context.hasProperty('downloadFileFromUrl')) {
    try {
      js.context.callMethod('downloadFileFromUrl', [url, filename]);
      return;
    } catch (_) {
      // Fallback to Dart implementation below
    }
  }

  html.HttpRequest.request(url, responseType: 'blob').then((xhr) {
    if (xhr.status == 200 && xhr.response != null) {
      final blob = xhr.response as html.Blob;
      final blobUrl = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: blobUrl)
        ..setAttribute('download', filename)
        ..style.display = 'none';
      html.document.body?.children.add(anchor);
      anchor.click();
      
      // CRITICAL: Delay cleanup and revocation by 30 seconds.
      // Calling revokeObjectUrl synchronously immediately causes Chrome's asynchronous
      // download manager to fail reading the blob, falling back to the raw blob UUID without extension.
      Timer(const Duration(seconds: 30), () {
        anchor.remove();
        html.Url.revokeObjectUrl(blobUrl);
      });
    } else {
      _directAnchorDownload(url, filename);
    }
  }).catchError((_) {
    _directAnchorDownload(url, filename);
  });
}

void _directAnchorDownload(String url, String filename) {
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', filename)
    ..setAttribute('target', '_blank')
    ..style.display = 'none';
  html.document.body?.children.add(anchor);
  anchor.click();
  Timer(const Duration(seconds: 10), () {
    anchor.remove();
  });
}

