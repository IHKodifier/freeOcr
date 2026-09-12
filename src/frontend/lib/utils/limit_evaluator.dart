class LimitEvaluationResult {
  final bool isExceeded;
  final double fileSizeMb;
  final double maxAllowedMb;

  LimitEvaluationResult({
    required this.isExceeded,
    required this.fileSizeMb,
    required this.maxAllowedMb,
  });
}

class LimitEvaluator {
  /// Evaluates whether a file size in bytes exceeds the current allowed limit in MB.
  static LimitEvaluationResult evaluate({
    required int fileSizeInBytes,
    required double currentLimitMb,
  }) {
    final double fileSizeMb = fileSizeInBytes / (1024 * 1024);
    final bool isExceeded = fileSizeMb > currentLimitMb;
    return LimitEvaluationResult(
      isExceeded: isExceeded,
      fileSizeMb: fileSizeMb,
      maxAllowedMb: currentLimitMb,
    );
  }

  /// Calculates how many rewarded video ads are required to boost the limit enough to accommodate the file.
  static int calculateAdsRequired({
    required int fileSizeInBytes,
    required double currentLimitMb,
    double boostPerAdMb = 50.0,
  }) {
    final double fileSizeMb = fileSizeInBytes / (1024 * 1024);
    final double deficitMb = fileSizeMb - currentLimitMb;
    if (deficitMb <= 0) return 0;
    return (deficitMb / boostPerAdMb).ceil();
  }
}
