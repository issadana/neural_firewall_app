import 'package:injectable/injectable.dart';

import '../repositories/blacklist_repository.dart';

@injectable
class AddToBlacklistUseCase {
  final BlacklistRepository _repository;
  const AddToBlacklistUseCase(this._repository);

  Future<void> call(
    String ip,
    String reason, {
    String? selectedModel,
    double? selectedScore,
    Map<String, double>? allModelScores,
    String? notes,
  }) =>
      _repository.add(
        ip,
        reason,
        selectedModel: selectedModel,
        selectedScore: selectedScore,
        allModelScores: allModelScores,
        notes: notes,
      );
}
