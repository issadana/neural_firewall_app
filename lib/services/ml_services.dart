import 'dart:math';
import 'package:logger/logger.dart';

final _log = Logger();

class MlInferenceService {
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    try {
      _log.i('ML Inference Service initialized');
      _initialized = true;
    } catch (e) {
      _log.e('Failed to initialize ML service: $e');
      throw Exception('ML initialization failed: $e');
    }
  }

  Future<double> runBruteForce(Map<String, dynamic> features) async {
    if (!_initialized) await init();
    try {
      final packetCount = features['packetCount'] as int? ?? 0;
      final duration = features['duration'] as int? ?? 0;
      final iatStd = features['iatStd'] as int? ?? 0;

      var score = 0.0;
      if (packetCount > 100) score += 0.3;
      if (iatStd < 10) score += 0.2;
      if (duration < 5000) score += 0.1;

      return min(1.0, score);
    } catch (e) {
      _log.e('Brute force inference error: $e');
      return 0.0;
    }
  }

  Future<double> runDos(Map<String, dynamic> features) async {
    if (!_initialized) await init();
    try {
      final totalBytes = features['totalBytes'] as int? ?? 0;
      final iatMean = features['iatMean'] as int? ?? 0;
      final packetCount = features['packetCount'] as int? ?? 0;

      var score = 0.0;
      if (packetCount > 1000) score += 0.4;
      if (totalBytes > 10000000) score += 0.3;
      if (iatMean < 5) score += 0.2;

      return min(1.0, score);
    } catch (e) {
      _log.e('DoS inference error: $e');
      return 0.0;
    }
  }

  void dispose() {
    _initialized = false;
  }
}

class HeuristicService {
  bool checkSynFlood(int synCount, Duration window, int threshold) {
    final ratePerSecond = (synCount / window.inSeconds).toInt();
    return ratePerSecond > threshold;
  }

  bool checkPacketFlood(int packetCount, Duration window, int threshold) {
    final ratePerSecond = (packetCount / window.inSeconds).toInt();
    return ratePerSecond > threshold;
  }

  double calculateAnomalyScore(
    int iatStdDev,
    int packetCount,
    int totalBytes,
  ) {
    var score = 0.0;

    if (iatStdDev < 5) score += 0.2;
    if (iatStdDev < 2) score += 0.2;
    if (packetCount > 500) score += 0.3;
    if (totalBytes > 5000000) score += 0.2;

    return (score / 1.0).clamp(0.0, 1.0);
  }

  Map<String, dynamic> analyzeFlow(Map<String, dynamic> features) {
    return {
      'flaggedReasons': <String>[],
      'heuristicScore': 0.0,
      'anomalyFlags': <String>[],
    };
  }
}
