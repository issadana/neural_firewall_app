import 'package:injectable/injectable.dart';

import '../entities/blacklist_entry.dart';
import '../repositories/blacklist_repository.dart';

@injectable
class GetBlacklistUseCase {
  final BlacklistRepository _repository;
  const GetBlacklistUseCase(this._repository);

  Future<List<BlacklistEntry>> call() => _repository.getAll();
}
