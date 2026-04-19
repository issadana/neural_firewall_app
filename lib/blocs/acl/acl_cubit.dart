import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

import '../../services/list_services.dart';
import 'acl_state.dart';

final _log = Logger();


@injectable
class AclCubit extends Cubit<AclState> {
  final AclService _service;

  AclCubit(this._service) : super(const AclState(entries: [])) {
    load();
  }

  Future<void> load() async {
    try {
      await _service.init();
      final entries = await _service.getAll();
      emit(AclState(entries: entries));
    } catch (e) {
      _log.e('Error loading ACL: $e');
    }
  }

  Future<void> add(String ip, {String? notes}) async {
    try {
      await _service.add(ip, notes: notes);
      await load();
    } catch (e) {
      _log.e('Error adding ACL: $e');
    }
  }

  Future<void> remove(String ip) async {
    try {
      await _service.remove(ip);
      await load();
    } catch (e) {
      _log.e('Error removing ACL: $e');
    }
  }

  Future<void> clearAll() async {
    try {
      await _service.clearAll();
      emit(const AclState(entries: []));
    } catch (e) {
      _log.e('Error clearing ACL: $e');
    }
  }
}
