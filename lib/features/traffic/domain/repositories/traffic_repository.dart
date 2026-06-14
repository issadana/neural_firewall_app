import '../entities/packet_record.dart';

abstract class TrafficRepository {
  Future<PacketRecord> processPacket(Map<String, dynamic> rawPacket);
  void updateThresholds(double blockThreshold, double warnThreshold);

  /// When true, OS/system-owned traffic is scored by the ML models instead of
  /// being fast-tracked with a `System` label.
  void setScanSystemTraffic(bool enabled);

  /// The set of model catalog ids (matching `kAiModelCatalog`) that should
  /// score each packet. Every enabled model runs; the block/warn decision uses
  /// the highest score across them.
  void setEnabledModels(Set<String> modelIds);
}
