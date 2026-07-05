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

  /// CIC-style flow features computed natively by FlowTracker. Carried on the
  /// record so they can be persisted with the firewall log the backend stores.
  final double duration;
  final int fwdPkts;
  final int bwdPkts;
  final double fwdRate;

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
    this.duration = 0.0,
    this.fwdPkts = 0,
    this.bwdPkts = 0,
    this.fwdRate = 0.0,
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

  /// Serialises the record for local persistence (SharedPreferences JSON).
  /// Enums are stored by name and the timestamp as ISO-8601 so the format is
  /// stable across app versions.
  Map<String, dynamic> toJson() => {
    'id': id,
    'srcIp': srcIp,
    'srcPort': srcPort,
    'dstIp': dstIp,
    'dstPort': dstPort,
    'protocol': protocol.name,
    'status': status.name,
    'sizeBytes': sizeBytes,
    'bruteForceScore': bruteForceScore,
    'dosScore': dosScore,
    'duration': duration,
    'fwdPkts': fwdPkts,
    'bwdPkts': bwdPkts,
    'fwdRate': fwdRate,
    'modelScores': modelScores,
    'selectedModel': selectedModel,
    'selectedScore': selectedScore,
    'timestamp': timestamp.toIso8601String(),
    'isBlacklisted': isBlacklisted,
    'label': label,
    'serviceName': serviceName,
    'appName': appName,
    'appPackage': appPackage,
    'isSystem': isSystem,
  };

  factory PacketRecord.fromJson(Map<String, dynamic> json) => PacketRecord(
    id: json['id'] as String? ?? '',
    srcIp: json['srcIp'] as String? ?? 'unknown',
    srcPort: json['srcPort'] as int? ?? 0,
    dstIp: json['dstIp'] as String? ?? 'unknown',
    dstPort: json['dstPort'] as int? ?? 0,
    protocol: Protocol.values.firstWhere(
      (p) => p.name == json['protocol'],
      orElse: () => Protocol.unknown,
    ),
    status: PacketStatus.values.firstWhere(
      (s) => s.name == json['status'],
      orElse: () => PacketStatus.err,
    ),
    sizeBytes: json['sizeBytes'] as int? ?? 0,
    bruteForceScore: (json['bruteForceScore'] as num?)?.toDouble() ?? 0.0,
    dosScore: (json['dosScore'] as num?)?.toDouble() ?? 0.0,
    duration: (json['duration'] as num?)?.toDouble() ?? 0.0,
    fwdPkts: json['fwdPkts'] as int? ?? 0,
    bwdPkts: json['bwdPkts'] as int? ?? 0,
    fwdRate: (json['fwdRate'] as num?)?.toDouble() ?? 0.0,
    modelScores:
        (json['modelScores'] as Map<String, dynamic>?)?.map(
          (k, v) => MapEntry(k, (v as num).toDouble()),
        ) ??
        const {},
    selectedModel: json['selectedModel'] as String? ?? '',
    selectedScore: (json['selectedScore'] as num?)?.toDouble() ?? 0.0,
    timestamp:
        DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
    isBlacklisted: json['isBlacklisted'] as bool? ?? false,
    label: json['label'] as String? ?? '',
    serviceName: json['serviceName'] as String? ?? '',
    appName: json['appName'] as String? ?? '',
    appPackage: json['appPackage'] as String? ?? '',
    isSystem: json['isSystem'] as bool? ?? false,
  );
}
