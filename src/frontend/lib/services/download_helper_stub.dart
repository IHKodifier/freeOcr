/// Stub implementation for non-web environments (e.g. Flutter VM test runner).
void triggerDownload(String url, String filename) {
  // No-op on non-web platforms during unit/widget testing
}

void triggerDownloadBytes(List<int> bytes, String filename, [String mimeType = 'application/pdf']) {
  // No-op on non-web platforms during unit/widget testing
}

