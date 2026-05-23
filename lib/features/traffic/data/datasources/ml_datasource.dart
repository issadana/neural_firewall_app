import 'dart:convert';

import 'package:Sentri/core/constants/ai_models.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

final _log = Logger();

class MlDataSource {
  static const String _modelAsset =
      AiModels.bruteForceModel; 
  static const String _scalerAsset =
      AiModels.bruteForceScalerParams; 

  Interpreter? _interpreter;
  List<double> _means = [0.0, 0.0, 0.0, 0.0];
  List<double> _stds = [1.0, 1.0, 1.0, 1.0];
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    try {
      _interpreter = await Interpreter.fromAsset(_modelAsset);
      await _loadScaler();
      _log.i('MlDataSource ready. Input: [1,4] Output: [1,1]');
      _initialized = true;
    } catch (e) {
      _log.e('Failed to initialize MlDataSource: $e');
      rethrow;
    }
  }

  Future<void> _loadScaler() async {
    try {
      final String jsonString = await rootBundle.loadString(_scalerAsset);
      final Map<String, dynamic> scalerParams = jsonDecode(jsonString);
      List<double> means = List<double>.from(scalerParams['mean'] as List);
      List<double> scales = List<double>.from(scalerParams['scale'] as List);
      _log.i('Scaler loaded — means: $means  scales: $scales');
    } catch (e) {
      _log.w('scaler_params.json missing or invalid — using identity scaling. $e');
    }
  }

  /// Expects packet map with keys: proto, iat_mean, fwd_pkts, pkt_size_avg
  Future<double> predict(Map<String, dynamic> packet) async {
    if (!_initialized) await init();
    try {
      final input = [_scale(packet)];
      final output = [[0.0]];
      _interpreter!.run(input, output);
      return output[0][0].clamp(0.0, 1.0);
    } catch (e) {
      _log.e('Inference error: $e');
      return 0.0;
    }
  }

  List<double> _scale(Map<String, dynamic> packet) {
    final raw = [
      (packet['proto'] as num? ?? 6).toDouble(),
      (packet['iat_mean'] as num? ?? 0).toDouble(),
      (packet['fwd_pkts'] as num? ?? 1).toDouble(),
      (packet['pkt_size_avg'] as num? ?? 0).toDouble(),
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
