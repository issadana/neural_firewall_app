import '../repositories/blacklist_repository.dart';

class ClearBlacklistUseCase {
  final BlacklistRepository _repository;
  const ClearBlacklistUseCase(this._repository);

  Future<void> call() => _repository.clearAll();
}
