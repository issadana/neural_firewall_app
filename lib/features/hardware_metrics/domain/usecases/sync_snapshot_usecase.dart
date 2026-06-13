import '../entities/hardware_snapshot.dart';
import '../repositories/hardware_metrics_repository.dart';

class SyncSnapshotUseCase {
  final HardwareMetricsRepository _repository;
  SyncSnapshotUseCase(this._repository);

  Future<void> call(HardwareSnapshot snapshot) => _repository.syncSnapshot(snapshot);
}
