import 'package:flutter/material.dart';
import 'theme_storage_stub.dart'
    if (dart.library.html) 'theme_storage_web.dart';

/// Cross-platform helper to load and save active theme preference.
class ThemeStorageHelper {
  static void saveTheme(ThemeMode mode) {
    ThemeStoragePlatform.saveTheme(mode);
  }

  static ThemeMode loadTheme() {
    return ThemeStoragePlatform.loadTheme();
  }
}
