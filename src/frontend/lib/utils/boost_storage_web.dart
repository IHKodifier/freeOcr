import 'dart:html' as html;

/// Web implementation of BoostStorage persisting session boost to localStorage.
class BoostStoragePlatform {
  static const String _storageKeyLimit = 'freeocr_boosted_limit_mb';
  static const String _storageKeyExpiry = 'freeocr_boost_expires_at';

  static void saveBoost({required double limitMb, required DateTime expiresAt}) {
    try {
      html.window.localStorage[_storageKeyLimit] = limitMb.toString();
      html.window.localStorage[_storageKeyExpiry] = expiresAt.millisecondsSinceEpoch.toString();
    } catch (_) {}
  }

  static Map<String, dynamic>? loadBoost() {
    try {
      final savedLimit = html.window.localStorage[_storageKeyLimit];
      final savedExpiry = html.window.localStorage[_storageKeyExpiry];
      if (savedLimit != null && savedExpiry != null) {
        final double limit = double.tryParse(savedLimit) ?? 100.0;
        final int expiryMs = int.tryParse(savedExpiry) ?? 0;
        final expiryDate = DateTime.fromMillisecondsSinceEpoch(expiryMs);
        if (DateTime.now().isBefore(expiryDate)) {
          return {
            'limitMb': limit,
            'expiresAt': expiryDate,
          };
        } else {
          clearBoost();
        }
      }
    } catch (_) {}
    return null;
  }

  static void clearBoost() {
    try {
      html.window.localStorage.remove(_storageKeyLimit);
      html.window.localStorage.remove(_storageKeyExpiry);
    } catch (_) {}
  }
}
