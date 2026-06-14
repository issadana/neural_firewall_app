import '../entities/packet_record.dart';

abstract class TrafficRepository {
  Future<PacketRecord> processPacket(Map<String, dynamic> rawPacket);
  void updateThresholds(double blockThreshold, double warnThreshold);

  /// When true, OS/system-owned traffic is scored by the ML models instead of
  /// being fast-tracked with a `System` label.
  void setScanSystemTraffic(bool enabled);
}
