import 'package:logger/logger.dart';
import 'package:Sentri/core/enums.dart';
import 'package:Sentri/core/utils/network_utils.dart';
import 'package:Sentri/features/blacklist/domain/repositories/blacklist_repository.dart';
import 'package:Sentri/features/vpn/data/datasources/vpn_native_datasource.dart';
import '../../domain/entities/packet_record.dart';
import '../../domain/repositories/traffic_repository.dart';
import '../datasources/ml_datasource.dart';

final _log = Logger();

class TrafficRepositoryImpl implements TrafficRepository {
  final BlacklistRepository _blacklistRepository;
  final MlDataSource _mlDataSource;
  final VpnNativeDataSource _vpnDataSource;

  double _blockThreshold;
  double _warnThreshold;
  bool _scanSystemTraffic;
  int _packetCounter = 0;

  /// Cheap safety net for the system-traffic bypass: counts packets per
  /// destination within a 1-second window. If a "trusted" system source starts
  /// flooding a destination, the bypass is revoked and the flow is sent to ML.
  final _RateGuard _systemRateGuard = _RateGuard(1000);

  /// Destination ports for ubiquitous, benign OS chatter (DNS, NTP, web,
  /// push, local discovery). Only system-owned traffic to these is bypassed.
  static const Set<int> _benignSystemPorts = {
    53, 67, 68, 80, 123, 443, 853, 1900, 5228, 5353,
  };

  bool _isBenignSystemDestination(int dstPort) =>
      _benignSystemPorts.contains(dstPort);

  TrafficRepositoryImpl({
    required BlacklistRepository blacklistRepository,
    required MlDataSource mlDataSource,
    required VpnNativeDataSource vpnDataSource,
    double blockThreshold = 0.20,
    double warnThreshold = 0.10,
    bool scanSystemTraffic = false,
  })  : _blacklistRepository = blacklistRepository,
        _mlDataSource = mlDataSource,
        _vpnDataSource = vpnDataSource,
        _blockThreshold = blockThreshold,
        _warnThreshold = warnThreshold,
        _scanSystemTraffic = scanSystemTraffic;

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
      final appName = rawPacket['appName'] as String? ?? '';
      final appPackage = rawPacket['appPackage'] as String? ?? '';
      final isSystem = rawPacket['isSystem'] as bool? ?? false;

      final protocol = ProtocolHelper.parseProtocol(protocolNum);

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
          label: label,
          serviceName: label,
          appName: appName,
          appPackage: appPackage,
          isSystem: isSystem,
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
          label: label,
          serviceName: label,
          appName: appName,
          appPackage: appPackage,
          isSystem: isSystem,
        );
      }

      // System-owned traffic to a well-known benign service: skip ML inference
      // to save battery and cut UI noise. We still run a cheap per-destination
      // rate heuristic so a compromised system component flooding a target is
      // not handed a free pass — if it trips, we fall through to full scoring.
      if (isSystem &&
          !_scanSystemTraffic &&
          _isBenignSystemDestination(dstPort)) {
        final flooding = _systemRateGuard.exceeds(
          dstIp,
          DateTime.now().millisecondsSinceEpoch,
        );
        if (!flooding) {
          return PacketRecord(
            id: id,
            srcIp: srcIp,
            srcPort: srcPort,
            dstIp: dstIp,
            dstPort: dstPort,
            protocol: protocol,
            status: PacketStatus.system,
            sizeBytes: sizeBytes,
            bruteForceScore: 0.0,
            dosScore: 0.0,
            timestamp: DateTime.now(),
            isBlacklisted: false,
            label: label,
            serviceName: label,
            appName: appName,
            appPackage: appPackage,
            isSystem: true,
          );
        }
        _log.w(
          'System source $appPackage → $dstIp:$dstPort exceeded rate guard; scoring with ML',
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
        label: label,
        serviceName: label,
        appName: appName,
        appPackage: appPackage,
        isSystem: isSystem,
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

  @override
  void setScanSystemTraffic(bool enabled) {
    _scanSystemTraffic = enabled;
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
    );
  }
}

/// Minimal, allocation-light rate guard. Tracks a per-key count inside the
/// current 1-second window; the map is cleared whenever the window rolls over,
/// so memory stays bounded without per-entry timestamp bookkeeping.
class _RateGuard {
  final int limitPerSec;
  final Map<String, int> _counts = {};
  int _windowSec = 0;

  _RateGuard(this.limitPerSec);

  /// Records one hit for [key] and returns true if it crossed [limitPerSec]
  /// within the current second.
  bool exceeds(String key, int nowMs) {
    final sec = nowMs ~/ 1000;
    if (sec != _windowSec) {
      _windowSec = sec;
      _counts.clear();
    }
    final count = (_counts[key] ?? 0) + 1;
    _counts[key] = count;
    return count > limitPerSec;
  }
}
