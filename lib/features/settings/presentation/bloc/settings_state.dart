import 'package:equatable/equatable.dart';

import 'package:Sentri/core/constants/app_constants.dart';

class SettingsState extends Equatable {
  final double blockThreshold;
  final double warnThreshold;
  final bool floodDetection;
  final bool synFloodDetection;
  final int floodPktPerSec;
  final int synFloodPerSec;
  final bool bfModelEnabled;
  final bool dosModelEnabled;
  final int maxLogEntries;
  final bool darkMode;

  const SettingsState({
    this.blockThreshold = AppConstants.defaultBlockThreshold,
    this.warnThreshold = AppConstants.defaultWarnThreshold,
    this.floodDetection = true,
    this.synFloodDetection = true,
    this.floodPktPerSec = 1000,
    this.synFloodPerSec = 100,
    this.bfModelEnabled = true,
    this.dosModelEnabled = true,
    this.maxLogEntries = 200,
    this.darkMode = true,
  });

  SettingsState copyWith({
    double? blockThreshold,
    double? warnThreshold,
    bool? floodDetection,
    bool? synFloodDetection,
    int? floodPktPerSec,
    int? synFloodPerSec,
    bool? bfModelEnabled,
    bool? dosModelEnabled,
    int? maxLogEntries,
    bool? darkMode,
  }) {
    return SettingsState(
      blockThreshold: blockThreshold ?? this.blockThreshold,
      warnThreshold: warnThreshold ?? this.warnThreshold,
      floodDetection: floodDetection ?? this.floodDetection,
      synFloodDetection: synFloodDetection ?? this.synFloodDetection,
      floodPktPerSec: floodPktPerSec ?? this.floodPktPerSec,
      synFloodPerSec: synFloodPerSec ?? this.synFloodPerSec,
      bfModelEnabled: bfModelEnabled ?? this.bfModelEnabled,
      dosModelEnabled: dosModelEnabled ?? this.dosModelEnabled,
      maxLogEntries: maxLogEntries ?? this.maxLogEntries,
      darkMode: darkMode ?? this.darkMode,
    );
  }

  @override
  List<Object?> get props => [
        blockThreshold,
        warnThreshold,
        floodDetection,
        synFloodDetection,
        floodPktPerSec,
        synFloodPerSec,
        bfModelEnabled,
        dosModelEnabled,
        maxLogEntries,
        darkMode,
      ];
}
