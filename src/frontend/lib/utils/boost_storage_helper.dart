import 'boost_storage_stub.dart'
    if (dart.library.html) 'boost_storage_web.dart';

/// Cross-platform helper to persist and restore active session boost limits.
class BoostStorageHelper {
  static void saveBoost({required double limitMb, required DateTime expiresAt}) {
    BoostStoragePlatform.saveBoost(limitMb: limitMb, expiresAt: expiresAt);
  }

  static Map<String, dynamic>? loadBoost() {
    return BoostStoragePlatform.loadBoost();
  }

  static void clearBoost() {
    BoostStoragePlatform.clearBoost();
  }
}
