import 'url_helper_stub.dart'
    if (dart.library.html) 'url_helper_web.dart' as helper;

/// Cross-platform utility for opening external URLs cleanly across Web and VM unit tests.
class UrlHelper {
  static void openUrl(String url) {
    helper.openUrl(url);
  }
}
