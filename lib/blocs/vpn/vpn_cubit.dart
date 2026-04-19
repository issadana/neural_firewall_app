import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../models/app_models.dart';
import '../../services/vpn_bridge_service.dart';
import 'vpn_state.dart';

@injectable
class VpnCubit extends Cubit<VpnState> {
  final VpnBridgeService _bridge;

  VpnCubit(this._bridge) : super(const VpnState(status: VpnStatus.stopped));

  Future<void> start() async {
    try {
      emit(const VpnState(status: VpnStatus.starting));
      await _bridge.startVpn();
      emit(const VpnState(status: VpnStatus.running));
    } catch (e) {
      emit(VpnState(
        status: VpnStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> stop() async {
    try {
      await _bridge.stopVpn();
      emit(const VpnState(status: VpnStatus.stopped));
    } catch (e) {
      emit(VpnState(
        status: VpnStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> checkStatus() async {
    try {
      final isRunning = await _bridge.isVpnRunning();
      emit(VpnState(
        status: isRunning ? VpnStatus.running : VpnStatus.stopped,
      ));
    } catch (e) {
      emit(VpnState(
        status: VpnStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
