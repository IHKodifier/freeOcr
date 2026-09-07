import 'dart:html' as html;
import 'package:flutter/material.dart';

/// Web implementation of ThemeStorage writing to browser localStorage.
class ThemeStoragePlatform {
  static const String _storageKey = 'freeocr_theme';

  static void saveTheme(ThemeMode mode) {
    try {
      final value = mode == ThemeMode.dark ? 'dark' : 'light';
      html.window.localStorage[_storageKey] = value;
    } catch (_) {}
  }

  static ThemeMode loadTheme() {
    try {
      final saved = html.window.localStorage[_storageKey];
      if (saved == 'dark') return ThemeMode.dark;
      if (saved == 'light') return ThemeMode.light;
    } catch (_) {}
    return ThemeMode.light;
  }
}
