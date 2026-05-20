import '../repositories/blacklist_repository.dart';

class RemoveFromBlacklistUseCase {
  final BlacklistRepository _repository;
  const RemoveFromBlacklistUseCase(this._repository);

  Future<void> call(String ip) => _repository.remove(ip);
}
