/// Stub implementation for non-web / VM unit tests.
void openUrl(String url) {
  // No-op during non-web unit tests
}

/// Stub navigation for non-web / VM unit tests.
void navigateToPath(String path, {bool openNewTab = false}) {
  // No-op during non-web unit tests
}

/// Stub URL push state for non-web / VM unit tests.
void pushUrlState(String path, {String? title}) {
  // No-op during non-web unit tests
}

/// Stub popstate listener for non-web / VM unit tests.
void Function() listenPopState(void Function(String path) onPop) {
  return () {};
}
