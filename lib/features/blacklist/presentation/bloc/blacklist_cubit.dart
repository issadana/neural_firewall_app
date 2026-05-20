import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

import 'package:Sentri/core/enums.dart';
import 'package:Sentri/features/blacklist/domain/usecases/add_to_blacklist_usecase.dart';
import 'package:Sentri/features/blacklist/domain/usecases/clear_blacklist_usecase.dart';
import 'package:Sentri/features/blacklist/domain/usecases/get_blacklist_usecase.dart';
import 'package:Sentri/features/blacklist/domain/usecases/remove_from_blacklist_usecase.dart';
import 'blacklist_state.dart';

export 'blacklist_state.dart';

final _log = Logger();

class BlacklistCubit extends Cubit<BlacklistState> {
  final GetBlacklistUseCase _getBlacklist;
  final AddToBlacklistUseCase _addToBlacklist;
  final RemoveFromBlacklistUseCase _removeFromBlacklist;
  final ClearBlacklistUseCase _clearBlacklist;

  BlacklistCubit({
    required GetBlacklistUseCase getBlacklist,
    required AddToBlacklistUseCase addToBlacklist,
    required RemoveFromBlacklistUseCase removeFromBlacklist,
    required ClearBlacklistUseCase clearBlacklist,
  })  : _getBlacklist = getBlacklist,
        _addToBlacklist = addToBlacklist,
        _removeFromBlacklist = removeFromBlacklist,
        _clearBlacklist = clearBlacklist,
        super(const BlacklistState()) {
    load();
  }

  Future<void> load() async {
    try {
      final entries = await _getBlacklist();
      emit(BlacklistState(entries: entries));
    } catch (e) {
      _log.e('Error loading blacklist: $e');
    }
  }

  Future<void> addManual(String ip) async {
    try {
      await _addToBlacklist(ip, BlacklistReason.manual.name);
      await load();
    } catch (e) {
      _log.e('Error adding manual entry: $e');
    }
  }

  Future<void> addAutoMl(String ip, {required double bfScore, required double dosScore}) async {
    try {
      await _addToBlacklist(ip, BlacklistReason.autoMl.name, bfScore: bfScore, dosScore: dosScore);
      await load();
    } catch (e) {
      _log.e('Error adding auto ML entry: $e');
    }
  }

  Future<void> remove(String ip) async {
    try {
      await _removeFromBlacklist(ip);
      await load();
    } catch (e) {
      _log.e('Error removing entry: $e');
    }
  }

  Future<void> clearAll() async {
    try {
      await _clearBlacklist();
      emit(const BlacklistState());
    } catch (e) {
      _log.e('Error clearing blacklist: $e');
    }
  }
}
