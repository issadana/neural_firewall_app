import 'package:injectable/injectable.dart';

import '../repositories/blacklist_repository.dart';

@injectable
class ClearBlacklistUseCase {
  final BlacklistRepository _repository;
  const ClearBlacklistUseCase(this._repository);

  Future<void> call() => _repository.clearAll();
}
