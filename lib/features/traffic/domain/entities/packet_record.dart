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
    required this.timestamp,
    required this.isBlacklisted,
    this.label = '',
    this.serviceName = '',
    this.appName = '',
    this.appPackage = '',
    this.isSystem = false,
  });
}
