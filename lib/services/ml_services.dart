import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

final _log = Logger();

class BruteForceDetector {
  static const String _modelAsset =
      'lib/services/ai_models/bruteforce_detector.tflite';
  static const String _scalerAsset =
      'lib/services/ai_models/scaler_params.json';

  Interpreter? _interpreter;
  List<double> _means = [0.0, 0.0, 0.0, 0.0];
  List<double> _stds = [1.0, 1.0, 1.0, 1.0];
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    try {
      _interpreter = await Interpreter.fromAsset(_modelAsset);
      await _loadScaler();
      _log.i('BruteForceDetector ready. Input: [1,4] Output: [1,1]');
      _initialized = true;
    } catch (e) {
      _log.e('Failed to initialize BruteForceDetector: $e');
      rethrow;
    }
  }

  Future<void> _loadScaler() async {
    try {
      final raw = await rootBundle.loadString(_scalerAsset);
      final json = jsonDecode(raw) as Map<String, dynamic>;
      _means = List<double>.from((json['means'] as List).map((v) => (v as num).toDouble()));
      _stds = List<double>.from((json['stds'] as List).map((v) => (v as num).toDouble()));
      _log.i('Scaler loaded — means: $_means  stds: $_stds');
    } catch (e) {
      _log.w('scaler_params.json missing or invalid — using identity scaling. $e');
    }
  }

  /// Expects packet map with keys: proto, iat_mean, fwd_pkts, pkt_size_avg
  Future<double> predict(Map<String, dynamic> packet) async {
    if (!_initialized) await init();
    try {
      // Input shape (1, 4)
      final input = [_scale(packet)];
      // Output shape (1, 1)
      final output = [[0.0]];

      _interpreter!.run(input, output);

      return output[0][0].clamp(0.0, 1.0);
    } catch (e) {
      _log.e('Inference error: $e');
      return 0.0;
    }
  }

  /// Builds the 4-element float32 vector in model feature order and
  /// applies StandardScaler:  scaled = (value − mean) / std
  List<double> _scale(Map<String, dynamic> packet) {
    final raw = [
      (packet['proto'] as num? ?? 6).toDouble(),       // index 0
      (packet['iat_mean'] as num? ?? 0).toDouble(),    // index 1
      (packet['fwd_pkts'] as num? ?? 1).toDouble(),    // index 2
      (packet['pkt_size_avg'] as num? ?? 0).toDouble(), // index 3
    ];

    return List.generate(raw.length, (i) {
      final std = _stds[i] == 0.0 ? 1.0 : _stds[i];
      return (raw[i] - _means[i]) / std;
    });
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _initialized = false;
  }
}
