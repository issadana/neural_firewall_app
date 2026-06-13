import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:Sentri/core/constants/app_constants.dart';
import 'package:Sentri/features/settings/presentation/models/ai_model_catalog.dart';
import 'settings_state.dart';

export 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SharedPreferences _prefs;

  SettingsCubit(this._prefs) : super(const SettingsState()) {
    _load();
  }

  static String _modelKey(String id) => 'model_$id';

  void _load() {
    final models = <String, bool>{
      for (final m in kAiModelCatalog)
        m.id: _prefs.getBool(_modelKey(m.id)) ?? true,
    };
    emit(SettingsState(
      blockThreshold:
          _prefs.getDouble('blockThreshold') ?? AppConstants.defaultBlockThreshold,
      warnThreshold:
          _prefs.getDouble('warnThreshold') ?? AppConstants.defaultWarnThreshold,
      models: models,
      maxLogEntries: _prefs.getInt('maxLogEntries') ?? 200,
      darkMode: _prefs.getBool('darkMode') ?? true,
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

  Future<void> toggleModel(String id, bool v) async {
    await _prefs.setBool(_modelKey(id), v);
    emit(state.copyWith(models: {...state.models, id: v}));
  }

  Future<void> setMaxLogEntries(int v) async {
    await _prefs.setInt('maxLogEntries', v);
    emit(state.copyWith(maxLogEntries: v));
  }

  Future<void> toggleDarkMode(bool v) async {
    await _prefs.setBool('darkMode', v);
    emit(state.copyWith(darkMode: v));
  }
}
