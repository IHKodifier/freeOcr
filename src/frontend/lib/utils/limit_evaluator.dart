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
}
