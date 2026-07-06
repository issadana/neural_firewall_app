import 'package:injectable/injectable.dart';

import '../repositories/vpn_repository.dart';

/// Queries the native service for whether the VPN is currently running. Used on
/// app startup to re-attach the UI to a session that survived a process kill
/// (the service is START_STICKY + foreground, so it keeps running).
@injectable
class IsVpnRunningUseCase {
  final VpnRepository _repository;
  IsVpnRunningUseCase(this._repository);

  Future<bool> call() => _repository.isRunning();
}
