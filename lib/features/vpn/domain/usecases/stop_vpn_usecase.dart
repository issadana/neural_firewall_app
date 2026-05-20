import '../repositories/vpn_repository.dart';

class StopVpnUseCase {
  final VpnRepository _repository;
  StopVpnUseCase(this._repository);

  Future<void> call() => _repository.stop();
}
