import 'package:injectable/injectable.dart';

import '../repositories/vpn_repository.dart';

@injectable
class StopVpnUseCase {
  final VpnRepository _repository;
  StopVpnUseCase(this._repository);

  Future<void> call() => _repository.stop();
}
