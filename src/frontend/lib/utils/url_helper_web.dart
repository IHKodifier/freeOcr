import 'dart:html' as html;

/// Web implementation using window.open for external link navigation.
void openUrl(String url) {
  html.window.open(url, '_blank');
}

/// Web implementation for top-level browser navigation to standalone static pages.
void navigateToPath(String path, {bool openNewTab = false}) {
  if (openNewTab) {
    html.window.open(path, '_blank');
  } else {
    html.window.location.href = path;
  }
}
