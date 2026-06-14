import '../repositories/blacklist_repository.dart';

/// Streams change notifications for the blacklist so the UI can refresh when
/// entries are added/removed from anywhere — including auto-blocks raised by
/// the traffic pipeline.
class WatchBlacklistUseCase {
  final BlacklistRepository _repository;
  const WatchBlacklistUseCase(this._repository);

  Stream<void> call() => _repository.changes;
}
