import 'package:freezed_annotation/freezed_annotation.dart';

import '../../models/app_models.dart';

part 'acl_state.freezed.dart';

@freezed
abstract class AclState with _$AclState {
  const factory AclState({required List<AclEntry> entries}) = _AclState;
}
