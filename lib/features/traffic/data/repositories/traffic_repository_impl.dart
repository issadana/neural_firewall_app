import 'package:logger/logger.dart';
import 'package:Sentri/core/constants/ai_models.dart';
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

  /// Catalog ids of the models that score each packet. Defaults to all shipped
  /// models; kept in sync with the user's settings via [setEnabledModels].
  Set<String> _enabledModels = AiModels.all.map((m) => m.id).toSet();

  /// Feature names the live packet pipeline can actually supply with real data.
  /// A model that needs anything outside this set would be scored on
  /// mean-defaults (out-of-distribution noise), so it is allowed to *display* a
  /// score but NOT to drive a block — otherwise normal traffic gets blocked.
  /// FlowTracker now computes the full CIC-style set, so all five models are
  /// covered (HULK/LOIC/HOIC need bwd_pkts/fwd_rate/fwd_max/idle_mean/fwd_mean).
  static const Set<String> _providedFeatures = {
    'protocol',
    'iat_mean',
    'iat_std',
    'duration',
    'fwd_pkts',
    'bwd_pkts',
    'fwd_max',
    'fwd_mean',
    'fwd_rate',
    'idle_mean',
    'pkt_size_avg',
  };

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

      // Feature map shared by every model. Each model picks the features it was
      // trained on (by name) and defaults any it can't find to its own mean, so
      // we can supply a superset here regardless of which models are enabled.
      // The flow* values are computed natively by FlowTracker (CIC-IDS style).
      final features = {
        'protocol': protocolNum,
        'iat_mean': rawPacket['flowIatMean'] ?? 0.0,
        'iat_std': rawPacket['flowIatStd'] ?? 0.0,
        'duration': rawPacket['flowDuration'] ?? 0.0,
        'fwd_pkts': rawPacket['flowFwdPkts'] ?? 1,
        'bwd_pkts': rawPacket['flowBwdPkts'] ?? 0,
        'fwd_max': rawPacket['flowFwdMax'] ?? 0,
        'fwd_mean': rawPacket['flowFwdMean'] ?? 0.0,
        'fwd_rate': rawPacket['flowFwdRate'] ?? 0.0,
        'idle_mean': rawPacket['flowIdleMean'] ?? 0.0,
        'pkt_size_avg': rawPacket['flowPktSizeAvg'] ?? sizeBytes.toDouble(),
      };

      // Pass the packet through every enabled model — all five by default — and
      // let the single strongest signal decide the verdict:
      //   • safe  — every model scored below the warn threshold
      //   • warn  — the highest-scoring model is in [warn, block)
      //   • block — the highest-scoring model is at or above block
      // So a packet is "safe" only when it is safe across all five models, and
      // the chosen ("used") model is always the highest-probability one — the
      // same rule for the safe, warn and block cases alike.
      final modelScores = await _mlDataSource.predictAll(features, _enabledModels);

      // Argmax over the models allowed to drive the decision. Only models whose
      // features the pipeline actually supplies may set the verdict; any model
      // scored on mean-defaults still appears in [modelScores] for display but
      // must not be able to block normal traffic. (All five ship fully
      // supported today, so all five take part in the vote.)
      //
      // Start below zero and use a strict `>` so the result is a true argmax:
      // when every model agrees the packet is safe (scores tie, often 0.0) we
      // still report the genuine top model in catalog order, not whichever one
      // happened to be iterated last.
      var selectedModel = '';
      var selectedScore = -1.0;
      modelScores.forEach((modelId, score) {
        if (!_mlDataSource.hasFullFeatureSupport(modelId, _providedFeatures)) {
          return;
        }
        if (score > selectedScore) {
          selectedScore = score;
          selectedModel = modelId;
        }
      });
      // No model could score the packet (none enabled / all errored): treat as
      // safe with a zero score rather than carrying the -1.0 sentinel forward.
      if (selectedScore < 0.0) selectedScore = 0.0;

      final PacketStatus status;
      bool autoBlacklisted = false;

      if (selectedScore >= _blockThreshold) {
        status = PacketStatus.aiBlock;

        // Auto-block: persist to blacklist so future packets from this IP
        // are caught before the ML models even run. The score goes to the
        // matching field — only the brute-force model maps to bf_score; every
        // DoS-family model (dos, HULK, LOIC, HOIC) maps to dos_score.
        final isBruteForce = selectedModel == 'bruteForce';
        await _blacklistRepository.add(
          srcIp,
          'AI flagged by "$selectedModel" (score: ${selectedScore.toStringAsFixed(2)})',
          bfScore: isBruteForce ? selectedScore : null,
          dosScore: isBruteForce ? null : selectedScore,
        );
        autoBlacklisted = true;

        // Push the block to the Kotlin VPN service so it drops packets from
        // this IP at the network level — they never reach the internet.
        await _vpnDataSource.blockIp(srcIp);

        _log.w('Auto-blocked $srcIp — $selectedModel=$selectedScore — $modelScores');
      } else if (selectedScore >= _warnThreshold) {
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
        bruteForceScore: modelScores['bruteForce'] ?? 0.0,
        dosScore: modelScores['dos'] ?? 0.0,
        modelScores: modelScores,
        selectedModel: selectedModel,
        selectedScore: selectedScore,
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

  @override
  void setEnabledModels(Set<String> modelIds) {
    _enabledModels = modelIds;
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
