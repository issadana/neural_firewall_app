import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

import '../../models/app_models.dart';
import '../../services/list_services.dart';
import 'blacklist_state.dart';

final _log = Logger();

@injectable
class BlacklistCubit extends Cubit<BlacklistState> {
  final BlacklistService _service;

  BlacklistCubit(this._service) : super(const BlacklistState(entries: [])) {
    load();
  }

  Future<void> load() async {
    try {
      await _service.init();
      final entries = await _service.getAll();
      emit(BlacklistState(entries: entries));
    } catch (e) {
      _log.e('Error loading blacklist: $e');
    }
  }

  Future<void> addAutoMl(
    String ip, {
    required double bfScore,
    required double dosScore,
  }) async {
    try {
      await _service.add(
        ip,
        BlacklistReason.autoMl,
        bfScore: bfScore,
        dosScore: dosScore,
      );
      await load();
    } catch (e) {
      _log.e('Error adding auto ML blocked IP: $e');
    }
  }

  Future<void> addManual(String ip) async {
    try {
      await _service.add(ip, BlacklistReason.manual);
      await load();
    } catch (e) {
      _log.e('Error adding manual blacklist: $e');
    }
  }

  Future<void> remove(String ip) async {
    try {
      await _service.remove(ip);
      await load();
    } catch (e) {
      _log.e('Error removing blacklist: $e');
    }
  }

  Future<void> clearAll() async {
    try {
      await _service.clearAll();
      emit(const BlacklistState(entries: []));
    } catch (e) {
      _log.e('Error clearing blacklist: $e');
    }
  }
}
