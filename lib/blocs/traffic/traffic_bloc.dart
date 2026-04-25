import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

import '../../models/app_models.dart';
import '../../services/packet_processor_service.dart';
import '../../services/vpn_bridge_service.dart';
import 'traffic_event.dart';
import 'traffic_state.dart';

final _log = Logger();

@injectable
class TrafficBloc extends Bloc<TrafficEvent, TrafficState> {
  final VpnBridgeService _bridge;
  final PacketProcessorService _processor;

  static const int _maxEntries = 200;
  static const int _sparklineLength = 60;

  StreamSubscription<Map<String, dynamic>>? _packetSub;

  TrafficBloc(this._bridge, this._processor)
      : super(TrafficState(
          records: ListQueue(),
          sparklineData: [],
        )) {
    on<StartListeningEvent>(_onStartListening);
    on<StopListeningEvent>(_onStopListening);
    on<PacketReceivedEvent>(_onPacketReceived);
    on<ClearLogsEvent>(_onClearLogs);
  }

  Future<void> _onStartListening(
    StartListeningEvent event,
    Emitter<TrafficState> emit,
  ) async {
    _packetSub = _bridge.packetStream.listen(
      (raw) => add(TrafficEvent.packetReceived(raw)),
    );
  }

  Future<void> _onStopListening(
    StopListeningEvent event,
    Emitter<TrafficState> emit,
  ) async {
    if (_packetSub != null) {
      await _packetSub!.cancel();
    }
    _packetSub = null;
  }

  Future<void> _onPacketReceived(
    PacketReceivedEvent event,
    Emitter<TrafficState> emit,
  ) async {
    try {
      // Drop packets originating from the TUN interface itself (own-device outbound traffic)
      if (event.rawPacket['srcIp'] == AppConstants.tunAddress) return;

      final record = await _processor.process(event.rawPacket);

      final newQueue = ListQueue<PacketRecord>.from(state.records);
      newQueue.addFirst(record);

      if (newQueue.length > _maxEntries) {
        newQueue.removeLast();
      }

      final maxThreat = max(record.bruteForceScore, record.dosScore);
      final newSparkline = [...state.sparklineData, maxThreat * 100];

      if (newSparkline.length > _sparklineLength) {
        newSparkline.removeAt(0);
      }

      emit(TrafficState(records: newQueue, sparklineData: newSparkline));
    } catch (e) {
      _log.e('Error processing packet: $e');
    }
  }

  Future<void> _onClearLogs(
    ClearLogsEvent event,
    Emitter<TrafficState> emit,
  ) async {
    emit(TrafficState(
      records: ListQueue(),
      sparklineData: [],
    ));
  }

  @override
  Future<void> close() async {
    if (_packetSub != null) {
      await _packetSub!.cancel();
      _packetSub = null;
    }
    return super.close();
  }
}
