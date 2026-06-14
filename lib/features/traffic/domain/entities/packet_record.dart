import 'package:Sentri/core/enums.dart';

class PacketRecord {
  final String id;
  final String srcIp;
  final int srcPort;
  final String dstIp;
  final int dstPort;
  final Protocol protocol;
  final PacketStatus status;
  final int sizeBytes;
  final double bruteForceScore;
  final double dosScore;

  /// Score from every enabled model that ran on this packet (catalog id → 0..1).
  final Map<String, double> modelScores;

  /// Catalog id of the model that produced the highest score (the one the
  /// block/warn decision is based on); empty if no model ran.
  final String selectedModel;

  /// The highest score across all enabled models — the value compared against
  /// the block/warn thresholds.
  final double selectedScore;

  final DateTime timestamp;
  final bool isBlacklisted;
  final String label;
  final String serviceName;
  final String appName;
  final String appPackage;
  final bool isSystem;

  const PacketRecord({
    required this.id,
    required this.srcIp,
    required this.srcPort,
    required this.dstIp,
    required this.dstPort,
    required this.protocol,
    required this.status,
    required this.sizeBytes,
    required this.bruteForceScore,
    required this.dosScore,
    this.modelScores = const {},
    this.selectedModel = '',
    this.selectedScore = 0.0,
    required this.timestamp,
    required this.isBlacklisted,
    this.label = '',
    this.serviceName = '',
    this.appName = '',
    this.appPackage = '',
    this.isSystem = false,
  });
}
