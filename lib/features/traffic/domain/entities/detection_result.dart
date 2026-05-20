class DetectionResult {
  final String flowId;
  final double bruteForceScore;
  final double dosScore;
  final String modelVersion;
  final DateTime timestamp;
  final List<String>? flaggedReasons;

  const DetectionResult({
    required this.flowId,
    required this.bruteForceScore,
    required this.dosScore,
    required this.modelVersion,
    required this.timestamp,
    this.flaggedReasons,
  });
}
