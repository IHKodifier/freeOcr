import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Client-side Favorites Service for FreePDFToolz.
///
/// Stores favorite PDF tools anonymously in browser SharedPreferences
/// adhering to the 100% Zero-Data-Retention architecture.
class FavoritesService {
  static const String prefsKey = 'freepdftoolz_favorites';

  static final ValueNotifier<Set<String>> favoritesNotifier = ValueNotifier<Set<String>>({});

  static SharedPreferences? _prefs;

  /// Initializes the service from SharedPreferences.
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final list = _prefs?.getStringList(prefsKey) ?? [];
    favoritesNotifier.value = Set<String>.from(list);
  }

  /// Returns whether a tool is currently favorited.
  static bool isFavorite(String toolId) {
    return favoritesNotifier.value.contains(toolId);
  }

  /// Returns the current set of favorited tool IDs.
  static Set<String> getFavorites() {
    return Set<String>.from(favoritesNotifier.value);
  }

  /// Toggles favorite state for a given tool and persists to SharedPreferences.
  static Future<void> toggleFavorite(String toolId) async {
    final updated = Set<String>.from(favoritesNotifier.value);
    if (updated.contains(toolId)) {
      updated.remove(toolId);
    } else {
      updated.add(toolId);
    }

    favoritesNotifier.value = updated;

    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
    await _prefs?.setStringList(prefsKey, updated.toList());
  }
}
