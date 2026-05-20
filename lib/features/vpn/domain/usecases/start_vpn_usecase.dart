import '../repositories/vpn_repository.dart';

class StartVpnUseCase {
  final VpnRepository _repository;
  StartVpnUseCase(this._repository);

  Future<void> call() => _repository.start();
}
