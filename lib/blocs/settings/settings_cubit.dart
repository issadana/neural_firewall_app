import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/app_models.dart';
import 'settings_state.dart';

@injectable
class SettingsCubit extends Cubit<SettingsState> {
  final SharedPreferences _prefs;

  SettingsCubit(this._prefs) : super(const SettingsState()) {
    _loadFromPrefs();
  }

  void _loadFromPrefs() {
    emit(SettingsState(
      blockThreshold: _prefs.getDouble('blockThreshold') ?? AppConstants.defaultBlockThreshold,
      warnThreshold: _prefs.getDouble('warnThreshold') ?? AppConstants.defaultWarnThreshold,
      floodDetection: _prefs.getBool('floodDetection') ?? true,
      synFloodDetection: _prefs.getBool('synFloodDetection') ?? true,
      floodPktPerSec: _prefs.getInt('floodPktPerSec') ?? 1000,
      synFloodPerSec: _prefs.getInt('synFloodPerSec') ?? 100,
      bfModelEnabled: _prefs.getBool('bfModelEnabled') ?? true,
      dosModelEnabled: _prefs.getBool('dosModelEnabled') ?? true,
      maxLogEntries: _prefs.getInt('maxLogEntries') ?? 200,
    ));
  }

  Future<void> setBlockThreshold(double v) async {
    await _prefs.setDouble('blockThreshold', v);
    emit(state.copyWith(blockThreshold: v));
  }

  Future<void> setWarnThreshold(double v) async {
    await _prefs.setDouble('warnThreshold', v);
    emit(state.copyWith(warnThreshold: v));
  }

  Future<void> toggleFloodDetection(bool v) async {
    await _prefs.setBool('floodDetection', v);
    emit(state.copyWith(floodDetection: v));
  }

  Future<void> toggleSynFloodDetection(bool v) async {
    await _prefs.setBool('synFloodDetection', v);
    emit(state.copyWith(synFloodDetection: v));
  }

  Future<void> setFloodPktPerSec(int v) async {
    await _prefs.setInt('floodPktPerSec', v);
    emit(state.copyWith(floodPktPerSec: v));
  }

  Future<void> setSynFloodPerSec(int v) async {
    await _prefs.setInt('synFloodPerSec', v);
    emit(state.copyWith(synFloodPerSec: v));
  }

  Future<void> toggleBfModel(bool v) async {
    await _prefs.setBool('bfModelEnabled', v);
    emit(state.copyWith(bfModelEnabled: v));
  }

  Future<void> toggleDosModel(bool v) async {
    await _prefs.setBool('dosModelEnabled', v);
    emit(state.copyWith(dosModelEnabled: v));
  }

  Future<void> setMaxLogEntries(int v) async {
    await _prefs.setInt('maxLogEntries', v);
    emit(state.copyWith(maxLogEntries: v));
  }
}
