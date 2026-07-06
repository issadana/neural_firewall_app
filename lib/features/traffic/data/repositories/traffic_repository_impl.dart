import 'dart:io';

import 'package:logger/logger.dart';
import 'package:Sentri/core/constants/ai_models.dart';
import 'package:Sentri/core/constants/api_constants.dart';
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

  // ── Rate-based flood / SYN-flood defence (user-configurable, non-ML) ────────
  bool _floodDetection;
  int _floodPktPerSec;
  bool _synFloodDetection;
  int _synFloodPerSec;

  /// Per-remote-IP packet and SYN counters, each over a rolling one-second
  /// window. Compared against the configurable budgets above to catch floods
  /// deterministically, independent of the ML models.
  final _RateCounter _packetRate = _RateCounter();
  final _RateCounter _synRate = _RateCounter();

  /// The VPN's TUN interface address (NeuralVpnService `addAddress`). It is the
  /// source IP on every outbound packet, so it identifies "the device" — never
  /// a threat. Kept in sync with the native [TUN_ADDRESS] constant.
  static const String _deviceTunIp = '10.0.0.2';

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

  /// Well-known public DNS resolvers and infrastructure that must never be
  /// blocked. Their traffic is high-frequency, tiny, short-lived — a shape the
  /// flow-based models readily mistake for scanning/DoS, producing false
  /// positives. Worse, dropping a resolver (e.g. Google DNS 8.8.8.8) breaks
  /// name resolution device-wide, which surfaces as "no internet". These IPs
  /// are still scored and logged for visibility, but are exempt from every
  /// block path: an existing blacklist hit is ignored and an over-threshold
  /// score is downgraded to a warning rather than an auto-block.
  static const Set<String> _trustedInfraIps = {
    '8.8.8.8', '8.8.4.4', // Google Public DNS
    '1.1.1.1', '1.0.0.1', // Cloudflare
    '9.9.9.9', '149.112.112.112', // Quad9
    '208.67.222.222', '208.67.220.220', // OpenDNS
    '94.140.14.14', '94.140.15.15', // AdGuard DNS
    '4.2.2.1', '4.2.2.2', // Level3
    '64.6.64.6', '64.6.65.6', // Verisign
  };

  /// Reserved / special-use IPv4 blocks that must never be blocked: loopback,
  /// the three private LAN ranges (router/gateway lives here), link-local,
  /// carrier-grade NAT (common on mobile data), and multicast. Stored as
  /// (network, prefixLength) so [_inReservedRange] can mask-compare them.
  static const List<(String, int)> _reservedRanges = [
    ('127.0.0.0', 8), // loopback
    ('10.0.0.0', 8), // private LAN
    ('172.16.0.0', 12), // private LAN
    ('192.168.0.0', 16), // private LAN
    ('169.254.0.0', 16), // link-local
    ('100.64.0.0', 10), // carrier-grade NAT
    ('224.0.0.0', 4), // multicast
  ];

  /// Live IP(s) of our own backend ([ApiConstants.baseUrl] host), resolved at
  /// startup and refreshed periodically via [refreshTrustedBackendIps]. Blocking
  /// these would sever the app's own control channel (auth + log WebSocket),
  /// and it could not recover because the recovery push rides that same socket.
  final Set<String> _resolvedBackendIps = {};

  /// True when [ip] belongs to trusted infrastructure that is exempt from every
  /// block path: a well-known public DNS resolver, our own backend, or a
  /// reserved/special-use range (loopback, private LAN, link-local, CGNAT,
  /// multicast).
  bool _isTrustedInfra(String ip) =>
      _trustedInfraIps.contains(ip) ||
      _resolvedBackendIps.contains(ip) ||
      _inReservedRange(ip);

  /// Parses a dotted-quad IPv4 string to its 32-bit value, or null if [ip] is
  /// not a valid IPv4 address (e.g. IPv6 or garbage) — such inputs simply are
  /// not treated as reserved.
  static int? _ipv4ToInt(String ip) {
    final parts = ip.split('.');
    if (parts.length != 4) return null;
    var value = 0;
    for (final part in parts) {
      final octet = int.tryParse(part);
      if (octet == null || octet < 0 || octet > 255) return null;
      value = (value << 8) | octet;
    }
    return value;
  }

  bool _inReservedRange(String ip) {
    final addr = _ipv4ToInt(ip);
    if (addr == null) return false;
    for (final (network, prefix) in _reservedRanges) {
      final base = _ipv4ToInt(network);
      if (base == null) continue;
      // A /0 mask (not used here) would overflow the 32-bit shift; every range
      // above has prefix >= 4, so the mask is well-defined.
      final mask = (0xFFFFFFFF << (32 - prefix)) & 0xFFFFFFFF;
      if ((addr & mask) == (base & mask)) return true;
    }
    return false;
  }

  @override
  Future<void> refreshTrustedBackendIps() async {
    final host = Uri.parse(ApiConstants.baseUrl).host;
    if (host.isEmpty) return;
    // A literal-IP baseUrl (local dev) needs no lookup — trust it directly.
    if (_ipv4ToInt(host) != null) {
      _resolvedBackendIps
        ..clear()
        ..add(host);
      return;
    }
    try {
      final records = await InternetAddress.lookup(host);
      final ips = records
          .where((a) => a.type == InternetAddressType.IPv4)
          .map((a) => a.address)
          .toSet();
      if (ips.isNotEmpty) {
        _resolvedBackendIps
          ..clear()
          ..addAll(ips);
        _log.i('Trusted backend IPs for $host: $ips');
      }
    } catch (e) {
      // DNS failure: keep whatever we resolved before rather than clearing —
      // a stale trusted IP is safer than accidentally blocking the backend.
      _log.w('Could not resolve backend host $host: $e');
    }
  }

  TrafficRepositoryImpl({
    required BlacklistRepository blacklistRepository,
    required MlDataSource mlDataSource,
    required VpnNativeDataSource vpnDataSource,
    double blockThreshold = 0.20,
    double warnThreshold = 0.10,
    bool scanSystemTraffic = false,
    bool floodDetection = true,
    int floodPktPerSec = 1000,
    bool synFloodDetection = true,
    int synFloodPerSec = 100,
  }) : _blacklistRepository = blacklistRepository,
       _mlDataSource = mlDataSource,
       _vpnDataSource = vpnDataSource,
       _blockThreshold = blockThreshold,
       _warnThreshold = warnThreshold,
       _scanSystemTraffic = scanSystemTraffic,
       _floodDetection = floodDetection,
       _floodPktPerSec = floodPktPerSec,
       _synFloodDetection = synFloodDetection,
       _synFloodPerSec = synFloodPerSec;

  @override
  void updateFloodSettings({
    required bool floodDetection,
    required int floodPktPerSec,
    required bool synFloodDetection,
    required int synFloodPerSec,
  }) {
    _floodDetection = floodDetection;
    _floodPktPerSec = floodPktPerSec;
    _synFloodDetection = synFloodDetection;
    _synFloodPerSec = synFloodPerSec;
  }

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

      // CIC-style flow features from FlowTracker. Carried on every record so the
      // firewall log persisted by the backend includes them.
      final duration = (rawPacket['flowDuration'] as num?)?.toDouble() ?? 0.0;
      final fwdPkts = rawPacket['flowFwdPkts'] as int? ?? 0;
      final bwdPkts = rawPacket['flowBwdPkts'] as int? ?? 0;
      final fwdRate = (rawPacket['flowFwdRate'] as num?)?.toDouble() ?? 0.0;

      final protocol = ProtocolHelper.parseProtocol(protocolNum);

      // The threat is always the REMOTE endpoint. On an outbound packet srcIp is
      // the device's own TUN address, so blacklisting srcIp blindly would block
      // the device itself; pick whichever endpoint isn't the device.
      final remoteIp = srcIp == _deviceTunIp ? dstIp : srcIp;

      // Trusted infrastructure (public DNS resolvers, etc.) is never blocked —
      // not even if a stale blacklist entry exists — so name resolution keeps
      // working. It still falls through to scoring/logging below for visibility.
      final isTrusted = _isTrustedInfra(remoteIp);

      final isBlacklisted =
          !isTrusted && await _blacklistRepository.isBlocked(remoteIp);
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
          duration: duration,
          fwdPkts: fwdPkts,
          bwdPkts: bwdPkts,
          fwdRate: fwdRate,
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
          duration: duration,
          fwdPkts: fwdPkts,
          bwdPkts: bwdPkts,
          fwdRate: fwdRate,
          timestamp: DateTime.now(),
          isBlacklisted: false,
          label: label,
          serviceName: label,
          appName: appName,
          appPackage: appPackage,
          isSystem: isSystem,
        );
      }

      // When the user has "scan system traffic" turned off, OS-owned traffic is
      // skipped entirely — it never reaches the ML models, regardless of the
      // destination, and is simply labelled System. This honours the setting
      // literally: to have system traffic inspected, turn the toggle on. (No
      // rate heuristic here — legitimate bulk system flows like OS/app updates
      // routinely run at high packet rates and would otherwise be mis-scored as
      // a DoS and auto-blocked.)
      if (isSystem && !_scanSystemTraffic) {
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
          duration: duration,
          fwdPkts: fwdPkts,
          bwdPkts: bwdPkts,
          fwdRate: fwdRate,
          timestamp: DateTime.now(),
          isBlacklisted: false,
          label: label,
          serviceName: label,
          appName: appName,
          appPackage: appPackage,
          isSystem: true,
        );
      }

      // Rate-based flood / SYN-flood defence (non-ML, user-configurable). Only
      // user-app traffic reaches here — trusted infrastructure and skipped
      // system traffic have already returned above — and each guard is gated by
      // its Settings toggle. Enforcement is matched to the confidence of each
      // signal: a SYN flood is blocked outright, while a coarse packet-rate
      // flood is only warned. Both thresholds are user-tunable, giving a
      // deterministic complement to the probabilistic models.
      if (!isTrusted) {
        final now = DateTime.now().millisecondsSinceEpoch;
        final isSynOnly = (flags & 0x02) != 0 && (flags & 0x10) == 0;

        final synHit = _synFloodDetection &&
            isSynOnly &&
            _synRate.hit(remoteIp, now) > _synFloodPerSec;
        final floodHit =
            _floodDetection && _packetRate.hit(remoteIp, now) > _floodPktPerSec;

        // SYN flood — a high-confidence, specific signal: legitimate clients do
        // not open 100+ new connections/sec to one host, and a warning would not
        // stop the connection storm. So it is blocked at the source, exactly
        // like an ML auto-block. Checked first so it wins if both guards trip.
        if (synHit) {
          final reason = 'SYN flood detected (> $_synFloodPerSec SYN/s)';
          await _blacklistRepository.add(remoteIp, reason, dosScore: 1.0);
          await _vpnDataSource.blockIp(remoteIp);
          _log.w('SYN-flood block of $remoteIp — $reason');

          return PacketRecord(
            id: id,
            srcIp: srcIp,
            srcPort: srcPort,
            dstIp: dstIp,
            dstPort: dstPort,
            protocol: protocol,
            status: PacketStatus.aiBlock,
            sizeBytes: sizeBytes,
            bruteForceScore: 0.0,
            dosScore: 1.0,
            duration: duration,
            fwdPkts: fwdPkts,
            bwdPkts: bwdPkts,
            fwdRate: fwdRate,
            timestamp: DateTime.now(),
            isBlacklisted: true,
            label: label,
            serviceName: label,
            appName: appName,
            appPackage: appPackage,
            isSystem: isSystem,
          );
        }

        // Raw packet-rate flood — a coarse signal: legitimate bulk transfers on
        // a client (e.g. a fast download) can themselves be high-rate, so this
        // is surfaced as a warning rather than an auto-block, avoiding a
        // false-positive that would black-hole a legitimate host. No blacklist
        // entry and no network-level block are applied.
        if (floodHit) {
          _log.w(
            'High packet rate from $remoteIp (> $_floodPktPerSec pkt/s) — warning',
          );
          return PacketRecord(
            id: id,
            srcIp: srcIp,
            srcPort: srcPort,
            dstIp: dstIp,
            dstPort: dstPort,
            protocol: protocol,
            status: PacketStatus.warn,
            sizeBytes: sizeBytes,
            bruteForceScore: 0.0,
            dosScore: 0.0,
            duration: duration,
            fwdPkts: fwdPkts,
            bwdPkts: bwdPkts,
            fwdRate: fwdRate,
            timestamp: DateTime.now(),
            isBlacklisted: false,
            label: label,
            serviceName: label,
            appName: appName,
            appPackage: appPackage,
            isSystem: isSystem,
          );
        }
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
      final modelScores = await _mlDataSource.predictAll(
        features,
        _enabledModels,
      );

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

      if (selectedScore >= _blockThreshold && isTrusted) {
        // Trusted infra scored high — a known false-positive shape. Surface it
        // as a warning for visibility, but never add it to the blacklist or
        // drop it at the network level.
        status = PacketStatus.warn;
        _log.w(
          'Skipped auto-block of trusted infra $remoteIp — '
          '$selectedModel=$selectedScore (downgraded to warn)',
        );
      } else if (selectedScore >= _blockThreshold) {
        status = PacketStatus.aiBlock;

        // Auto-block: persist to blacklist so future packets from this IP
        // are caught before the ML models even run. The score goes to the
        // matching field — only the brute-force model maps to bf_score; every
        // DoS-family model (dos, HULK, LOIC, HOIC) maps to dos_score.
        final isBruteForce = selectedModel == 'bruteForce';
        await _blacklistRepository.add(
          remoteIp,
          'AI flagged by "$selectedModel" (score: ${selectedScore.toStringAsFixed(2)})',
          bfScore: isBruteForce ? selectedScore : null,
          dosScore: isBruteForce ? null : selectedScore,
        );
        autoBlacklisted = true;

        // Push the block to the Kotlin VPN service so it drops packets to/from
        // this IP at the network level — they never reach the internet.
        await _vpnDataSource.blockIp(remoteIp);

        _log.w(
          'Auto-blocked $remoteIp — $selectedModel=$selectedScore — $modelScores',
        );
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
        duration: duration,
        fwdPkts: fwdPkts,
        bwdPkts: bwdPkts,
        fwdRate: fwdRate,
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

  PacketStatus? _checkSpecialPackets(
    Protocol protocol,
    int flags,
    int dstPort,
  ) {
    if (protocol == Protocol.tcp &&
        (flags & 0x02) != 0 &&
        (flags & 0x10) == 0) {
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

/// Per-key hit counter over a rolling one-second window. [hit] records one hit
/// for [key] and returns its running count within the current second; the map
/// is cleared whenever the window rolls over, so memory stays bounded without
/// per-entry timestamp bookkeeping. Used for flood / SYN-flood rate limiting.
class _RateCounter {
  final Map<String, int> _counts = {};
  int _windowSec = 0;

  int hit(String key, int nowMs) {
    final sec = nowMs ~/ 1000;
    if (sec != _windowSec) {
      _windowSec = sec;
      _counts.clear();
    }
    final count = (_counts[key] ?? 0) + 1;
    _counts[key] = count;
    return count;
  }
}
