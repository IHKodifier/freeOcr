import 'package:flutter/material.dart';

/// Stub implementation of ThemeStorage for VM / tests.
class ThemeStoragePlatform {
  static void saveTheme(ThemeMode mode) {}

  static ThemeMode loadTheme() {
    return ThemeMode.light;
  }
}
