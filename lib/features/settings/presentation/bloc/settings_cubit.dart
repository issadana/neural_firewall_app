import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:Sentri/core/constants/app_constants.dart';
import 'package:Sentri/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:Sentri/features/settings/presentation/models/ai_model_catalog.dart';
import 'settings_state.dart';

export 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SharedPreferences _prefs;
  final SettingsRepositoryImpl _repository;

  /// Model ids that the backend tracks (the rest are local-only toggles).
  static const _bfModelId = 'bruteForce';
  static const _dosModelId = 'dos';

  /// Coalesces rapid local changes (e.g. slider drags) into one PUT.
  Timer? _pushDebounce;
  static const _pushDelay = Duration(milliseconds: 700);

  SettingsCubit(this._prefs, this._repository) : super(const SettingsState()) {
    _load();
    syncFromServer();
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
      scanSystemTraffic: _prefs.getBool('scanSystemTraffic') ?? false,
      maxLogEntries: _prefs.getInt('maxLogEntries') ?? 200,
      darkMode: _prefs.getBool('darkMode') ?? false,
      floodDetection: _prefs.getBool('floodDetection') ?? true,
      synFloodDetection: _prefs.getBool('synFloodDetection') ?? true,
      floodPktPerSec:
          _prefs.getInt('floodPktPerSec') ?? AppConstants.defaultFloodPktPerSec,
      synFloodPerSec:
          _prefs.getInt('synFloodPerSec') ?? AppConstants.defaultSynFloodPerSec,
    ));
  }

  /// Pulls the server's settings (if signed in) and overlays them on top of the
  /// local state, persisting the result so the cache stays in sync.
  Future<void> syncFromServer() async {
    final remote = await _repository.fetch();
    if (remote == null || isClosed) return;
    await _applyServerJson(remote);
  }

  // ── Local setters (persist locally, emit, then schedule a server push) ──────

  Future<void> setBlockThreshold(double v) async {
    await _prefs.setDouble('blockThreshold', v);
    emit(state.copyWith(blockThreshold: v));
    _schedulePush();
  }

  Future<void> setWarnThreshold(double v) async {
    await _prefs.setDouble('warnThreshold', v);
    emit(state.copyWith(warnThreshold: v));
    _schedulePush();
  }

  Future<void> toggleModel(String id, bool v) async {
    await _prefs.setBool(_modelKey(id), v);
    emit(state.copyWith(models: {...state.models, id: v}));
    // Only the BF/DoS models are mirrored server-side, but pushing the full
    // payload is harmless for the others.
    _schedulePush();
  }

  Future<void> toggleScanSystemTraffic(bool v) async {
    await _prefs.setBool('scanSystemTraffic', v);
    emit(state.copyWith(scanSystemTraffic: v));
    _schedulePush();
  }

  Future<void> setMaxLogEntries(int v) async {
    await _prefs.setInt('maxLogEntries', v);
    emit(state.copyWith(maxLogEntries: v));
    _schedulePush();
  }

  Future<void> toggleDarkMode(bool v) async {
    // Theme preference is local-only — not part of the backend settings.
    await _prefs.setBool('darkMode', v);
    emit(state.copyWith(darkMode: v));
  }

  Future<void> toggleFloodDetection(bool v) async {
    await _prefs.setBool('floodDetection', v);
    emit(state.copyWith(floodDetection: v));
    _schedulePush();
  }

  Future<void> toggleSynFloodDetection(bool v) async {
    await _prefs.setBool('synFloodDetection', v);
    emit(state.copyWith(synFloodDetection: v));
    _schedulePush();
  }

  Future<void> setFloodPktPerSec(int v) async {
    await _prefs.setInt('floodPktPerSec', v);
    emit(state.copyWith(floodPktPerSec: v));
    _schedulePush();
  }

  Future<void> setSynFloodPerSec(int v) async {
    await _prefs.setInt('synFloodPerSec', v);
    emit(state.copyWith(synFloodPerSec: v));
    _schedulePush();
  }

  // ── Server sync plumbing ────────────────────────────────────────────────────

  void _schedulePush() {
    _pushDebounce?.cancel();
    _pushDebounce = Timer(_pushDelay, _pushToServer);
  }

  Future<void> _pushToServer() async {
    try {
      await _repository.push(_toServerJson(state));
    } catch (_) {
      // Offline / server error — local state is already saved; sync next time.
    }
  }

  /// Maps the current state to the backend's settings payload.
  Map<String, dynamic> _toServerJson(SettingsState s) => {
        'block_threshold': s.blockThreshold,
        'warn_threshold': s.warnThreshold,
        'flood_detection': s.floodDetection,
        'syn_flood_detection': s.synFloodDetection,
        'flood_pkt_per_sec': s.floodPktPerSec,
        'syn_flood_per_sec': s.synFloodPerSec,
        'bf_model_enabled': s.isModelEnabled(_bfModelId),
        'dos_model_enabled': s.isModelEnabled(_dosModelId),
        'max_log_entries': s.maxLogEntries,
        'log_system_traffic': s.scanSystemTraffic,
      };

  /// Applies the server payload onto local state + prefs. Only keys present in
  /// [json] are applied, so partial responses don't clobber existing values.
  Future<void> _applyServerJson(Map<String, dynamic> json) async {
    double? asDouble(String k) =>
        json[k] is num ? (json[k] as num).toDouble() : null;
    int? asInt(String k) => json[k] is num ? (json[k] as num).toInt() : null;
    bool? asBool(String k) => json[k] is bool ? json[k] as bool : null;

    final blockThreshold = asDouble('block_threshold');
    final warnThreshold = asDouble('warn_threshold');
    final floodDetection = asBool('flood_detection');
    final synFloodDetection = asBool('syn_flood_detection');
    final floodPktPerSec = asInt('flood_pkt_per_sec');
    final synFloodPerSec = asInt('syn_flood_per_sec');
    final bfEnabled = asBool('bf_model_enabled');
    final dosEnabled = asBool('dos_model_enabled');
    final maxLogEntries = asInt('max_log_entries');
    final logSystemTraffic = asBool('log_system_traffic');

    // Persist each present value to the local cache.
    if (blockThreshold != null) {
      await _prefs.setDouble('blockThreshold', blockThreshold);
    }
    if (warnThreshold != null) {
      await _prefs.setDouble('warnThreshold', warnThreshold);
    }
    if (floodDetection != null) {
      await _prefs.setBool('floodDetection', floodDetection);
    }
    if (synFloodDetection != null) {
      await _prefs.setBool('synFloodDetection', synFloodDetection);
    }
    if (floodPktPerSec != null) {
      await _prefs.setInt('floodPktPerSec', floodPktPerSec);
    }
    if (synFloodPerSec != null) {
      await _prefs.setInt('synFloodPerSec', synFloodPerSec);
    }
    if (maxLogEntries != null) {
      await _prefs.setInt('maxLogEntries', maxLogEntries);
    }
    if (logSystemTraffic != null) {
      await _prefs.setBool('scanSystemTraffic', logSystemTraffic);
    }

    final models = {...state.models};
    if (bfEnabled != null) {
      models[_bfModelId] = bfEnabled;
      await _prefs.setBool(_modelKey(_bfModelId), bfEnabled);
    }
    if (dosEnabled != null) {
      models[_dosModelId] = dosEnabled;
      await _prefs.setBool(_modelKey(_dosModelId), dosEnabled);
    }

    emit(state.copyWith(
      blockThreshold: blockThreshold,
      warnThreshold: warnThreshold,
      floodDetection: floodDetection,
      synFloodDetection: synFloodDetection,
      floodPktPerSec: floodPktPerSec,
      synFloodPerSec: synFloodPerSec,
      maxLogEntries: maxLogEntries,
      scanSystemTraffic: logSystemTraffic,
      models: models,
    ));
  }

  @override
  Future<void> close() {
    _pushDebounce?.cancel();
    return super.close();
  }
}
