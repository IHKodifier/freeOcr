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

/// Push a new URL state to browser history and synchronize document title without reload.
void pushUrlState(String path, {String? title}) {
  try {
    html.window.history.pushState(null, title ?? '', path);
    if (title != null && title.isNotEmpty) {
      html.document.title = title;
    }
  } catch (_) {}
}

/// Register a popstate listener for browser Back/Forward navigation.
void Function() listenPopState(void Function(String path) onPop) {
  try {
    final subscription = html.window.onPopState.listen((event) {
      final currentPath = html.window.location.pathname ?? '/';
      onPop(currentPath);
    });
    return () => subscription.cancel();
  } catch (_) {
    return () {};
  }
}
