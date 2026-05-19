import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_state.freezed.dart';

@freezed
abstract class SettingsState with _$SettingsState {
  const factory SettingsState({
    @Default(0.20) double blockThreshold,
    @Default(0.10) double warnThreshold,
    @Default(true) bool floodDetection,
    @Default(true) bool synFloodDetection,
    @Default(1000) int floodPktPerSec,
    @Default(100) int synFloodPerSec,
    @Default(true) bool bfModelEnabled,
    @Default(true) bool dosModelEnabled,
    @Default(200) int maxLogEntries,
    @Default(true) bool darkMode,
  }) = _SettingsState;
}
