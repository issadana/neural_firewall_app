import 'dart:convert';
import 'package:Sentri/core/constants/ai_models.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

final _log = Logger();

/// One loaded TFLite model plus the scaler params (feature order + mean/scale)
/// for its section of `scaler_params.json`.
class _LoadedModel {
  final AiModelSpec spec;
  final Interpreter interpreter;
  final List<String> features;
  final List<double> means;
  final List<double> stds;

  _LoadedModel({
    required this.spec,
    required this.interpreter,
    required this.features,
    required this.means,
    required this.stds,
  });
}

/// Runs on-device threat-detection inference. Loads every shipped TFLite model
/// up front, then scores a packet through whichever models are currently
/// enabled ([predictAll]). Each model builds its own input vector from its
/// feature list (read from `scaler_params.json`), so models with different
/// feature counts all work through one call.
class MlDataSource {
  /// Maps the canonical feature names in `scaler_params.json` to the keys the
  /// traffic pipeline emits, plus accepted aliases. First key found in the
  /// packet map wins; a feature with no match falls back to the model's mean
  /// (so it standardizes to ~0, i.e. neutral).
  static const Map<String, List<String>> _featureAliases = {
    'protocol': ['protocol', 'proto'],
    'iat_mean': ['iat_mean'],
    'iat_std': ['iat_std'],
    'fwd_pkts': ['fwd_pkts'],
    'bwd_pkts': ['bwd_pkts'],
    'fwd_max': ['fwd_max'],
    'fwd_mean': ['fwd_mean'],
    'fwd_rate': ['fwd_rate'],
    'duration': ['duration'],
    'idle_mean': ['idle_mean'],
    'pkt_size_avg': ['pkt_size_avg', 'packet_size'],
    'packet_size': ['packet_size', 'pkt_size_avg'],
  };

  final Map<String, _LoadedModel> _models = {};
  bool _initialized = false;

  /// Catalog ids of models that loaded successfully.
  Iterable<String> get loadedModelIds => _models.keys;

  /// True if every feature model [id] needs can be satisfied from [available]
  /// (honouring feature aliases). A model whose features aren't all supplied is
  /// scored on mean-defaults — useful to display, but not trustworthy enough to
  /// drive a block. Returns false for unknown/unloaded models.
  bool hasFullFeatureSupport(String id, Set<String> available) {
    final model = _models[id];
    if (model == null) return false;
    return model.features.every((feature) {
      final keys = _featureAliases[feature] ?? [feature];
      return keys.any(available.contains);
    });
  }

  /// Loads every model in [AiModels.all]. A model that fails to load is logged
  /// and skipped — the rest still work. Safe to call repeatedly.
  Future<void> init() async {
    if (_initialized) return;

    final Map<String, dynamic> scalerRoot;
    try {
      scalerRoot =
          jsonDecode(await rootBundle.loadString(AiModels.scalerParams))
              as Map<String, dynamic>;
    } catch (e) {
      _log.e('Failed to read ${AiModels.scalerParams}: $e');
      rethrow;
    }

    for (final spec in AiModels.all) {
      try {
        final interpreter = await Interpreter.fromAsset(spec.assetPath);
        final scaler = _parseScaler(scalerRoot, spec);
        _models[spec.id] = _LoadedModel(
          spec: spec,
          interpreter: interpreter,
          features: scaler.$1,
          means: scaler.$2,
          stds: scaler.$3,
        );
        _log.i(
          'Loaded model "${spec.id}" — ${scaler.$1.length} features: ${scaler.$1}',
        );
      } catch (e) {
        _log.e('Skipping model "${spec.id}" (${spec.assetPath}): $e');
      }
    }
    _initialized = true;
    _log.i('MlDataSource ready — ${_models.length}/${AiModels.all.length} models loaded');
  }

  (List<String>, List<double>, List<double>) _parseScaler(
    Map<String, dynamic> root,
    AiModelSpec spec,
  ) {
    final section = root[spec.scalerKey];
    if (section is! Map<String, dynamic>) {
      throw StateError('scaler_params.json has no section "${spec.scalerKey}"');
    }
    final features = List<String>.from(section['features'] as List);
    final means = List<double>.from(
      (section['mean'] as List).map((e) => (e as num).toDouble()),
    );
    final stds = List<double>.from(
      (section['scale'] as List).map((e) => (e as num).toDouble()),
    );
    if (features.length != means.length || features.length != stds.length) {
      throw StateError(
        'scaler section "${spec.scalerKey}" inconsistent: '
        '${features.length} features, ${means.length} means, ${stds.length} scales',
      );
    }
    return (features, means, stds);
  }

  /// Scores [packet] through every model in [enabledIds] that is loaded.
  /// Returns a map of catalog id → 0..1 threat probability. Models that aren't
  /// enabled, aren't loaded, or error during inference are simply absent.
  Future<Map<String, double>> predictAll(
    Map<String, dynamic> packet,
    Set<String> enabledIds,
  ) async {
    if (!_initialized) await init();

    final scores = <String, double>{};
    for (final id in enabledIds) {
      final model = _models[id];
      if (model == null) continue;
      try {
        final input = [_scale(model, packet)];
        final output = [[0.0]];
        model.interpreter.run(input, output);
        scores[id] = (output[0][0] as num).toDouble().clamp(0.0, 1.0);
      } catch (e) {
        _log.e('Inference error ($id): $e');
      }
    }
    return scores;
  }

  /// Builds the standardized input vector in [model]'s feature order. A feature
  /// absent from [packet] defaults to the model's mean (neutral after scaling).
  List<double> _scale(_LoadedModel model, Map<String, dynamic> packet) {
    return List.generate(model.features.length, (i) {
      final std = model.stds[i] == 0.0 ? 1.0 : model.stds[i];
      final raw = _readFeature(packet, model.features[i], model.means[i]);
      return (raw - model.means[i]) / std;
    });
  }

  double _readFeature(
    Map<String, dynamic> packet,
    String feature,
    double fallback,
  ) {
    final keys = _featureAliases[feature] ?? [feature];
    for (final key in keys) {
      final value = packet[key];
      if (value is num) return value.toDouble();
    }
    return fallback;
  }

  void dispose() {
    for (final m in _models.values) {
      m.interpreter.close();
    }
    _models.clear();
    _initialized = false;
  }
}
