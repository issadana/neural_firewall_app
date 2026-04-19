import 'package:freezed_annotation/freezed_annotation.dart';

import '../../models/app_models.dart';

part 'vpn_state.freezed.dart';

@freezed
abstract class VpnState with _$VpnState {
  const factory VpnState({
    required VpnStatus status,
    String? errorMessage,
  }) = _VpnState;
}
