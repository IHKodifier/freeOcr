/// Stub implementation of BoostStorage for VM / tests.
class BoostStoragePlatform {
  static void saveBoost({required double limitMb, required DateTime expiresAt}) {}

  static Map<String, dynamic>? loadBoost() => null;

  static void clearBoost() {}
}
