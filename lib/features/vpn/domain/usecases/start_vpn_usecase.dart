import 'package:injectable/injectable.dart';

import '../repositories/vpn_repository.dart';

@injectable
class StartVpnUseCase {
  final VpnRepository _repository;
  StartVpnUseCase(this._repository);

  Future<void> call() => _repository.start();
}
