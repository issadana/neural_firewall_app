import 'package:injectable/injectable.dart';

import '../repositories/blacklist_repository.dart';

@injectable
class AddToBlacklistUseCase {
  final BlacklistRepository _repository;
  const AddToBlacklistUseCase(this._repository);

  Future<void> call(
    String ip,
    String reason, {
    double? bfScore,
    double? dosScore,
    String? notes,
  }) =>
      _repository.add(ip, reason, bfScore: bfScore, dosScore: dosScore, notes: notes);
}
