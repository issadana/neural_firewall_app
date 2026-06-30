import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

import 'package:Sentri/core/constants/app_constants.dart';
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

  static const int _maxEntries = 200;
  static const int _sparklineLength = 60;

  StreamSubscription<Map<String, dynamic>>? _packetSub;

  TrafficBloc({
    required GetPacketStreamUseCase getPacketStream,
    required ProcessPacketUseCase processPacket,
  })  : _getPacketStream = getPacketStream,
        _processPacket = processPacket,
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
    } catch (e) {
      _log.e('Error processing packet: $e');
    }
  }

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
