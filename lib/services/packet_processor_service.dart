import 'package:logger/logger.dart';

import '../core/utils/network_utils.dart';
import '../models/app_models.dart';
import 'list_services.dart';
import 'ml_services.dart';

final _log = Logger();

class PacketProcessorService {
  final BlacklistService _blacklist;
  final AclService _acl;
  final BruteForceDetector _detector;

  late double _blockThreshold;
  late double _warnThreshold;

  int _packetCounter = 0;

  PacketProcessorService({
    required BlacklistService blacklist,
    required AclService acl,
    required BruteForceDetector detector,
    double blockThreshold = 0.20,
    double warnThreshold = 0.10,
  })  : _blacklist = blacklist,
        _acl = acl,
        _detector = detector,
        _blockThreshold = blockThreshold,
        _warnThreshold = warnThreshold;

  Future<PacketRecord> process(Map<String, dynamic> rawPacket) async {
    try {
      _packetCounter++;
      final id = 'pkt_$_packetCounter';

      final srcIp = rawPacket['srcIp'] as String? ?? 'unknown';
      final srcPort = rawPacket['srcPort'] as int? ?? 0;
      final dstIp = rawPacket['dstIp'] as String? ?? 'unknown';
      final dstPort = rawPacket['dstPort'] as int? ?? 0;
      final protocolNum = rawPacket['protocol'] as int? ?? 0;
      final sizeBytes = rawPacket['sizeBytes'] as int? ?? 0;
      final flags = rawPacket['flags'] as int? ?? 0;

      final protocol = ProtocolHelper.parseProtocol(protocolNum);

      final isAclBlocked = await _acl.isBlocked(srcIp);
      if (isAclBlocked) {
        return PacketRecord(
          id: id,
          srcIp: srcIp,
          srcPort: srcPort,
          dstIp: dstIp,
          dstPort: dstPort,
          protocol: protocol,
          status: PacketStatus.aiBlock,
          sizeBytes: sizeBytes,
          bruteForceScore: 1.0,
          dosScore: 0.0,
          timestamp: DateTime.now(),
          isBlacklisted: true,
          isAclBlocked: true,
        );
      }

      final isBlacklisted = await _blacklist.isBlocked(srcIp);
      if (isBlacklisted) {
        return PacketRecord(
          id: id,
          srcIp: srcIp,
          srcPort: srcPort,
          dstIp: dstIp,
          dstPort: dstPort,
          protocol: protocol,
          status: PacketStatus.aiBlock,
          sizeBytes: sizeBytes,
          bruteForceScore: 0.5,
          dosScore: 0.0,
          timestamp: DateTime.now(),
          isBlacklisted: true,
          isAclBlocked: false,
        );
      }

      final specialStatus = _checkSpecialPackets(protocol, flags, dstPort);
      if (specialStatus != null) {
        return PacketRecord(
          id: id,
          srcIp: srcIp,
          srcPort: srcPort,
          dstIp: dstIp,
          dstPort: dstPort,
          protocol: protocol,
          status: specialStatus,
          sizeBytes: sizeBytes,
          bruteForceScore: 0.0,
          dosScore: 0.0,
          timestamp: DateTime.now(),
          isBlacklisted: false,
          isAclBlocked: false,
        );
      }

      // Feature order must match model: proto, iat_mean, fwd_pkts, pkt_size_avg
      final features = {
        'proto': protocolNum,
        'iat_mean': rawPacket['flowIatMean'] ?? 0.0,
        'fwd_pkts': 1,
        'pkt_size_avg': sizeBytes.toDouble(),
      };

      final bfScore = await _detector.predict(features);

      PacketStatus status;
      if (bfScore >= _blockThreshold) {
        status = PacketStatus.aiBlock;
      } else if (bfScore >= _warnThreshold) {
        status = PacketStatus.warn;
      } else {
        status = PacketStatus.safe;
      }

      return PacketRecord(
        id: id,
        srcIp: srcIp,
        srcPort: srcPort,
        dstIp: dstIp,
        dstPort: dstPort,
        protocol: protocol,
        status: status,
        sizeBytes: sizeBytes,
        bruteForceScore: bfScore,
        dosScore: 0.0,
        timestamp: DateTime.now(),
        isBlacklisted: false,
        isAclBlocked: false,
      );
    } catch (e) {
      _log.e('Error processing packet: $e');
      return _createErrorRecord();
    }
  }

  PacketStatus? _checkSpecialPackets(Protocol protocol, int flags, int dstPort) {
    if (protocol == Protocol.tcp && (flags & 0x02) != 0 && (flags & 0x10) == 0) {
      return PacketStatus.tcp;
    }

    if (protocol == Protocol.udp && dstPort == 443) {
      return PacketStatus.quic;
    }

    if (protocol == Protocol.icmp) {
      return PacketStatus.ping;
    }

    return null;
  }

  PacketRecord _createErrorRecord() {
    return PacketRecord(
      id: 'err_${DateTime.now().millisecondsSinceEpoch}',
      srcIp: 'unknown',
      srcPort: 0,
      dstIp: 'unknown',
      dstPort: 0,
      protocol: Protocol.unknown,
      status: PacketStatus.err,
      sizeBytes: 0,
      bruteForceScore: 0.0,
      dosScore: 0.0,
      timestamp: DateTime.now(),
      isBlacklisted: false,
      isAclBlocked: false,
    );
  }

  void updateThresholds(double blockThreshold, double warnThreshold) {
    _blockThreshold = blockThreshold;
    _warnThreshold = warnThreshold;
  }
}
