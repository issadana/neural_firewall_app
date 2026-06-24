import 'package:equatable/equatable.dart';

import 'package:Sentri/core/constants/app_constants.dart';

class SettingsState extends Equatable {
  final double blockThreshold;
  final double warnThreshold;

  /// Enabled state per AI model, keyed by [AiModelInfo.id].
  /// A missing key is treated as enabled (see [isModelEnabled]).
  final Map<String, bool> models;

  /// When true, OS/system-owned traffic is also sent through the ML models
  /// instead of being fast-tracked with a `System` label. Off by default —
  /// benign system chatter is bypassed to save battery and reduce noise.
  final bool scanSystemTraffic;

  final int maxLogEntries;
  final bool darkMode;

  /// Rate-based flood/SYN-flood detection (synced with the backend `/settings`).
  final bool floodDetection;
  final bool synFloodDetection;
  final int floodPktPerSec;
  final int synFloodPerSec;

  const SettingsState({
    this.blockThreshold = AppConstants.defaultBlockThreshold,
    this.warnThreshold = AppConstants.defaultWarnThreshold,
    this.models = const {},
    this.scanSystemTraffic = false,
    this.maxLogEntries = 200,
    this.darkMode = false,
    this.floodDetection = true,
    this.synFloodDetection = true,
    this.floodPktPerSec = AppConstants.defaultFloodPktPerSec,
    this.synFloodPerSec = AppConstants.defaultSynFloodPerSec,
  });

  /// Whether a given model is switched on. Defaults to `true` when unknown so
  /// freshly-added models are protective out of the box.
  bool isModelEnabled(String id) => models[id] ?? true;

  /// How many models in [ids] are currently enabled.
  int activeModelCount(Iterable<String> ids) =>
      ids.where(isModelEnabled).length;

  SettingsState copyWith({
    double? blockThreshold,
    double? warnThreshold,
    Map<String, bool>? models,
    bool? scanSystemTraffic,
    int? maxLogEntries,
    bool? darkMode,
    bool? floodDetection,
    bool? synFloodDetection,
    int? floodPktPerSec,
    int? synFloodPerSec,
  }) {
    return SettingsState(
      blockThreshold: blockThreshold ?? this.blockThreshold,
      warnThreshold: warnThreshold ?? this.warnThreshold,
      models: models ?? this.models,
      scanSystemTraffic: scanSystemTraffic ?? this.scanSystemTraffic,
      maxLogEntries: maxLogEntries ?? this.maxLogEntries,
      darkMode: darkMode ?? this.darkMode,
      floodDetection: floodDetection ?? this.floodDetection,
      synFloodDetection: synFloodDetection ?? this.synFloodDetection,
      floodPktPerSec: floodPktPerSec ?? this.floodPktPerSec,
      synFloodPerSec: synFloodPerSec ?? this.synFloodPerSec,
    );
  }

  @override
  List<Object?> get props => [
        blockThreshold,
        warnThreshold,
        models,
        scanSystemTraffic,
        maxLogEntries,
        darkMode,
        floodDetection,
        synFloodDetection,
        floodPktPerSec,
        synFloodPerSec,
      ];
}
