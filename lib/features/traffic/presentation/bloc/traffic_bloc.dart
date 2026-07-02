import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

import 'package:Sentri/core/constants/app_constants.dart';
import 'package:Sentri/core/enums.dart';
import 'package:Sentri/core/utils/protocol_helper.dart';
import 'package:Sentri/core/websocket/firewall_log_ws_service.dart';
import 'package:Sentri/features/traffic/domain/entities/packet_record.dart';
import 'package:Sentri/features/traffic/domain/usecases/process_packet_usecase.dart';
import 'package:Sentri/features/vpn/domain/usecases/get_packet_stream_usecase.dart';
import 'traffic_event.dart';
import 'traffic_state.dart';

export 'traffic_event.dart';
export 'traffic_state.dart';

final _log = Logger();

class TrafficBloc extends Bloc<TrafficEvent, TrafficState> {
  final GetPacketStreamUseCase _getPacketStream;
  final ProcessPacketUseCase _processPacket;

  /// Streams every processed log to the backend for persistence. Optional so
  /// the bloc still runs (UI-only) when no backend/session is available.
  final FirewallLogWsService? _logWs;

  static const int _maxEntries = 200;
  static const int _sparklineLength = 60;

  StreamSubscription<Map<String, dynamic>>? _packetSub;

  TrafficBloc({
    required GetPacketStreamUseCase getPacketStream,
    required ProcessPacketUseCase processPacket,
    FirewallLogWsService? logWs,
  }) : _getPacketStream = getPacketStream,
       _processPacket = processPacket,
       _logWs = logWs,
       super(TrafficState(records: ListQueue(), sparklineData: [])) {
    on<StartListeningEvent>(_onStartListening);
    on<StopListeningEvent>(_onStopListening);
    on<PacketReceivedEvent>(_onPacketReceived);
    on<ClearLogsEvent>(_onClearLogs);
  }

  Future<void> _onStartListening(
    StartListeningEvent event,
    Emitter<TrafficState> emit,
  ) async {
    _packetSub = _getPacketStream().listen(
      (raw) => add(PacketReceivedEvent(raw)),
    );
  }

  Future<void> _onStopListening(
    StopListeningEvent event,
    Emitter<TrafficState> emit,
  ) async {
    await _packetSub?.cancel();
    _packetSub = null;
  }

  Future<void> _onPacketReceived(
    PacketReceivedEvent event,
    Emitter<TrafficState> emit,
  ) async {
    try {
      if (event.rawPacket['srcIp'] == AppConstants.tunAddress) return;

      final record = await _processPacket(event.rawPacket);

      final newQueue = ListQueue<PacketRecord>.from(state.records);
      newQueue.addFirst(record);
      if (newQueue.length > _maxEntries) newQueue.removeLast();

      // Plot the strongest signal across all enabled models for this packet.
      final maxThreat = max(
        record.selectedScore,
        max(record.bruteForceScore, record.dosScore),
      );
      final newSparkline = [...state.sparklineData, maxThreat * 100];
      if (newSparkline.length > _sparklineLength) newSparkline.removeAt(0);

      emit(TrafficState(records: newQueue, sparklineData: newSparkline));

      // Stream this log to the backend for persistence (non-blocking).
      _logWs?.enqueue(_toLogJson(record));
    } catch (e) {
      _log.e('Error processing packet: $e');
    }
  }

  /// Maps a processed [PacketRecord] to the backend `log_batch` wire shape
  /// (snake_case). `created_at` is added by the WS service on enqueue.
  Map<String, dynamic> _toLogJson(PacketRecord r) => {
    'src_ip': r.srcIp,
    'src_port': r.srcPort,
    'dst_port': r.dstPort,
    'protocol': ProtocolHelper.toInt(r.protocol),
    'size_bytes': r.sizeBytes,
    'selected_model': r.selectedModel,
    'selected_score': r.selectedScore,
    'all_model_scores': r.modelScores,
    'action': _actionOf(r.status),
    'threat_type': r.label,
    'service_name': r.serviceName,
    'app_name': r.appName,
    'app_package': r.appPackage,
    'is_system': r.isSystem,
  };

  /// Collapses the UI-oriented [PacketStatus] to the three actions the backend
  /// stores: only an AI block or an explicit warn are non-`allowed`.
  String _actionOf(PacketStatus status) => switch (status) {
    PacketStatus.aiBlock => 'blocked',
    PacketStatus.warn => 'warned',
    _ => 'allowed',
  };

  Future<void> _onClearLogs(
    ClearLogsEvent event,
    Emitter<TrafficState> emit,
  ) async {
    emit(TrafficState(records: ListQueue(), sparklineData: []));
  }

  @override
  Future<void> close() async {
    await _packetSub?.cancel();
    return super.close();
  }
}
