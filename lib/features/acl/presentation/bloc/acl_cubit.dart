import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

import 'package:Sentri/features/acl/domain/usecases/add_acl_usecase.dart';
import 'package:Sentri/features/acl/domain/usecases/clear_acl_usecase.dart';
import 'package:Sentri/features/acl/domain/usecases/get_acl_usecase.dart';
import 'package:Sentri/features/acl/domain/usecases/remove_acl_usecase.dart';
import 'acl_state.dart';

export 'acl_state.dart';

final _log = Logger();

class AclCubit extends Cubit<AclState> {
  final GetAclUseCase _getAcl;
  final AddAclUseCase _addAcl;
  final RemoveAclUseCase _removeAcl;
  final ClearAclUseCase _clearAcl;

  AclCubit({
    required GetAclUseCase getAcl,
    required AddAclUseCase addAcl,
    required RemoveAclUseCase removeAcl,
    required ClearAclUseCase clearAcl,
  })  : _getAcl = getAcl,
        _addAcl = addAcl,
        _removeAcl = removeAcl,
        _clearAcl = clearAcl,
        super(const AclState()) {
    load();
  }

  Future<void> load() async {
    try {
      final entries = await _getAcl();
      emit(AclState(entries: entries));
    } catch (e) {
      _log.e('Error loading ACL: $e');
    }
  }

  Future<void> add(String ip, {String? notes}) async {
    try {
      await _addAcl(ip, notes: notes);
      await load();
    } catch (e) {
      _log.e('Error adding ACL entry: $e');
    }
  }

  Future<void> remove(String ip) async {
    try {
      await _removeAcl(ip);
      await load();
    } catch (e) {
      _log.e('Error removing ACL entry: $e');
    }
  }

  Future<void> clearAll() async {
    try {
      await _clearAcl();
      emit(const AclState());
    } catch (e) {
      _log.e('Error clearing ACL: $e');
    }
  }
}
