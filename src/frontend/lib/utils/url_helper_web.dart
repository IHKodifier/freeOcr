import 'dart:html' as html;

/// Web implementation using window.open for external link navigation.
void openUrl(String url) {
  html.window.open(url, '_blank');
}
