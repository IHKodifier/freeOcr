import 'url_helper_stub.dart'
    if (dart.library.html) 'url_helper_web.dart' as helper;

/// Cross-platform utility for opening external URLs and standalone static pages.
class UrlHelper {
  static void openUrl(String url) {
    helper.openUrl(url);
  }

  static void navigateToPath(String path, {bool openNewTab = false}) {
    helper.navigateToPath(path, openNewTab: openNewTab);
  }
}
