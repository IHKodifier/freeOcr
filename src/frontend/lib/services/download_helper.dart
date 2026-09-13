import 'download_helper_stub.dart'
    if (dart.library.html) 'download_helper_web.dart' as helper;

abstract class DownloadHelper {
  static void triggerDownload(String url, String filename) {
    helper.triggerDownload(url, filename);
  }

  static void triggerDownloadBytes(List<int> bytes, String filename, [String mimeType = 'application/pdf']) {
    helper.triggerDownloadBytes(bytes, filename, mimeType);
  }
}

