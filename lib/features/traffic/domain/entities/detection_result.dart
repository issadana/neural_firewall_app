class DetectionResult {
  final String flowId;
  final Map<String, double> modelScores;
  final String selectedModel;
  final double selectedScore;
  final String action;
  final String threatType;
  final DateTime timestamp;
  final List<String>? flaggedReasons;

  const DetectionResult({
    required this.flowId,
    required this.modelScores,
    required this.selectedModel,
    required this.selectedScore,
    required this.action,
    required this.threatType,
    required this.timestamp,
    this.flaggedReasons,
  });
}
