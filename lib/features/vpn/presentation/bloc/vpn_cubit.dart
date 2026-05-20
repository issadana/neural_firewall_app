import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:Sentri/core/enums.dart';
import '../../domain/usecases/start_vpn_usecase.dart';
import '../../domain/usecases/stop_vpn_usecase.dart';
import 'vpn_state.dart';

export 'vpn_state.dart';

class VpnCubit extends Cubit<VpnState> {
  final StartVpnUseCase _startVpn;
  final StopVpnUseCase _stopVpn;

  VpnCubit({
    required StartVpnUseCase startVpn,
    required StopVpnUseCase stopVpn,
  })  : _startVpn = startVpn,
        _stopVpn = stopVpn,
        super(const VpnState(status: VpnStatus.stopped));

  Future<void> start() async {
    try {
      emit(const VpnState(status: VpnStatus.starting));
      await _startVpn();
      emit(const VpnState(status: VpnStatus.running));
    } catch (e) {
      emit(VpnState(status: VpnStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> stop() async {
    try {
      await _stopVpn();
      emit(const VpnState(status: VpnStatus.stopped));
    } catch (e) {
      emit(VpnState(status: VpnStatus.error, errorMessage: e.toString()));
    }
  }
}
