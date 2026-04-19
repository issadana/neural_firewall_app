import 'package:freezed_annotation/freezed_annotation.dart';

import '../../models/app_models.dart';

part 'blacklist_state.freezed.dart';

@freezed
abstract class BlacklistState with _$BlacklistState {
  const factory BlacklistState({required List<BlacklistEntry> entries}) =
      _BlacklistState;
}
