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

  /// Applies the user's flood / SYN-flood rate-limit settings to the live
  /// pipeline. When enabled, a remote endpoint that exceeds the configured
  /// packets-per-second (or SYN-packets-per-second) budget is treated as a
  /// flood and blocked at the source — a deterministic, non-ML defence that
  /// complements the probabilistic models.
  void updateFloodSettings({
    required bool floodDetection,
    required int floodPktPerSec,
    required bool synFloodDetection,
    required int synFloodPerSec,
  });

  /// Resolves the backend host to its current IP(s) and marks them as trusted
  /// infrastructure so the firewall never blocks the app's own control channel.
  /// Call once at startup and periodically thereafter (IPs can change).
  Future<void> refreshTrustedBackendIps();
}
