// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// Web implementation using HTML Anchor element to initiate browser file download.
void triggerDownload(String url, String filename) {
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', filename)
    ..style.display = 'none';
  html.document.body?.children.add(anchor);
  anchor.click();
  anchor.remove();
}
