import 'package:injectable/injectable.dart';

import '../repositories/blacklist_repository.dart';

@injectable
class RemoveFromBlacklistUseCase {
  final BlacklistRepository _repository;
  const RemoveFromBlacklistUseCase(this._repository);

  Future<void> call(String ip) => _repository.remove(ip);
}
