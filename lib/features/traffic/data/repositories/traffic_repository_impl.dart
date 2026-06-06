import 'package:logger/logger.dart';

import 'package:Sentri/core/enums.dart';
import 'package:Sentri/core/utils/network_utils.dart';
import 'package:Sentri/features/blacklist/domain/repositories/blacklist_repository.dart';
import 'package:Sentri/features/acl/domain/repositories/acl_repository.dart';
import 'package:Sentri/features/vpn/data/datasources/vpn_native_datasource.dart';
import '../../domain/entities/packet_record.dart';
import '../../domain/repositories/traffic_repository.dart';
import '../datasources/ml_datasource.dart';

final _log = Logger();

class TrafficRepositoryImpl implements TrafficRepository {
  final BlacklistRepository _blacklistRepository;
  final AclRepository _aclRepository;
  final MlDataSource _mlDataSource;
  final VpnNativeDataSource _vpnDataSource;

  double _blockThreshold;
  double _warnThreshold;
  int _packetCounter = 0;

  TrafficRepositoryImpl({
    required BlacklistRepository blacklistRepository,
    required AclRepository aclRepository,
    required MlDataSource mlDataSource,
    required VpnNativeDataSource vpnDataSource,
    double blockThreshold = 0.20,
    double warnThreshold = 0.10,
  })  : _blacklistRepository = blacklistRepository,
        _aclRepository = aclRepository,
        _mlDataSource = mlDataSource,
        _vpnDataSource = vpnDataSource,
        _blockThreshold = blockThreshold,
        _warnThreshold = warnThreshold;

  @override
  Future<PacketRecord> processPacket(Map<String, dynamic> rawPacket) async {
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
      final label = rawPacket['label'] as String? ?? '';

      final protocol = ProtocolHelper.parseProtocol(protocolNum);

      final isAclBlocked = await _aclRepository.isBlocked(srcIp);
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
          label: label,
        );
      }

      final isBlacklisted = await _blacklistRepository.isBlocked(srcIp);
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
          label: label,
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
          label: label,
        );
      }

      final features = {
        'proto': protocolNum,
        'iat_mean': rawPacket['flowIatMean'] ?? 0.0,
        'fwd_pkts': 1,
        'pkt_size_avg': sizeBytes.toDouble(),
      };

      final bfScore = await _mlDataSource.predict(features);

      final PacketStatus status;
      bool autoBlacklisted = false;

      if (bfScore >= _blockThreshold) {
        status = PacketStatus.aiBlock;

        // Auto-block: persist to blacklist so future packets from this IP
        // are caught before the ML model even runs.
        await _blacklistRepository.add(
          srcIp,
          'AI detected brute-force (score: ${bfScore.toStringAsFixed(2)})',
          bfScore: bfScore,
        );
        autoBlacklisted = true;

        // Push the block to the Kotlin VPN service so it drops packets from
        // this IP at the network level — they never reach the internet.
        await _vpnDataSource.blockIp(srcIp);

        _log.w('Auto-blocked $srcIp — bfScore=$bfScore');
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
        isBlacklisted: autoBlacklisted,
        isAclBlocked: false,
        label: label,
      );
    } catch (e) {
      _log.e('Error processing packet: $e');
      return _createErrorRecord();
    }
  }

  @override
  void updateThresholds(double blockThreshold, double warnThreshold) {
    _blockThreshold = blockThreshold;
    _warnThreshold = warnThreshold;
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
}
