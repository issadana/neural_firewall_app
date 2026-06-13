import '../entities/hardware_snapshot.dart';

abstract class HardwareMetricsRepository {
  Future<HardwareSnapshot> collectSnapshot();
  Future<void> syncSnapshot(HardwareSnapshot snapshot);
  Future<List<HardwareSnapshot>> getHistory({DateTime? fromDate, DateTime? toDate});
}
