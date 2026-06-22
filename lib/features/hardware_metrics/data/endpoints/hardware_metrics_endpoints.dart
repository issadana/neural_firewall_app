/// Endpoint paths for the hardware metrics feature.
class HardwareMetricsEndpoints {
  HardwareMetricsEndpoints._();

  /// POST — save a snapshot. GET — list history (optional from_date/to_date).
  static const String metrics = '/hardware-metrics';
}
