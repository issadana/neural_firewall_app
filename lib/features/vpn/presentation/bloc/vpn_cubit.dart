import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:Sentri/core/enums.dart';
import '../../domain/usecases/is_vpn_running_usecase.dart';
import '../../domain/usecases/start_vpn_usecase.dart';
import '../../domain/usecases/stop_vpn_usecase.dart';
import 'vpn_state.dart';

export 'vpn_state.dart';

class VpnCubit extends Cubit<VpnState> {
  final StartVpnUseCase _startVpn;
  final StopVpnUseCase _stopVpn;
  final IsVpnRunningUseCase _isVpnRunning;

  VpnCubit({
    required StartVpnUseCase startVpn,
    required StopVpnUseCase stopVpn,
    required IsVpnRunningUseCase isVpnRunning,
  })  : _startVpn = startVpn,
        _stopVpn = stopVpn,
        _isVpnRunning = isVpnRunning,
        super(const VpnState(status: VpnStatus.stopped));

  /// Re-syncs the UI with the native service on app startup. The VPN service is
  /// START_STICKY + foreground, so it can already be running when the app is
  /// relaunched after a swipe-away or restart. Returns true if it was running,
  /// so the caller can also resume packet listening/detection.
  Future<bool> restore() async {
    try {
      final running = await _isVpnRunning();
      if (running) emit(const VpnState(status: VpnStatus.running));
      return running;
    } catch (_) {
      return false;
    }
  }

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
