import 'package:injectable/injectable.dart';

import '../../domain/entities/hardware_snapshot.dart';
import '../../domain/repositories/hardware_metrics_repository.dart';
import '../datasources/hardware_local_datasource.dart';
import '../datasources/hardware_remote_datasource.dart';

@LazySingleton(as: HardwareMetricsRepository)
class HardwareMetricsRepositoryImpl implements HardwareMetricsRepository {
  final HardwareLocalDataSource _local;
  final HardwareRemoteDataSource _remote;

  HardwareMetricsRepositoryImpl({
    required HardwareLocalDataSource local,
    required HardwareRemoteDataSource remote,
  })  : _local = local,
        _remote = remote;

  @override
  Future<HardwareSnapshot> collectSnapshot() => _local.collectSnapshot();

  @override
  Future<void> syncSnapshot(HardwareSnapshot snapshot) =>
      _remote.postSnapshot(snapshot);

  @override
  Future<List<HardwareSnapshot>> getHistory({DateTime? fromDate, DateTime? toDate}) =>
      _remote.getHistory(fromDate: fromDate, toDate: toDate);
}
