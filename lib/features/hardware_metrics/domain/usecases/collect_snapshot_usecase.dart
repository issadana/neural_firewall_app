import 'package:injectable/injectable.dart';

import '../entities/hardware_snapshot.dart';
import '../repositories/hardware_metrics_repository.dart';

@injectable
class CollectSnapshotUseCase {
  final HardwareMetricsRepository _repository;
  CollectSnapshotUseCase(this._repository);

  Future<HardwareSnapshot> call() => _repository.collectSnapshot();
}
