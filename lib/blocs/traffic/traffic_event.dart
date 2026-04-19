import 'package:freezed_annotation/freezed_annotation.dart';

part 'traffic_event.freezed.dart';

@freezed
class TrafficEvent with _$TrafficEvent {
  const factory TrafficEvent.packetReceived(Map<String, dynamic> rawPacket) =
      PacketReceivedEvent;
  const factory TrafficEvent.clearLogs() = ClearLogsEvent;
  const factory TrafficEvent.startListening() = StartListeningEvent;
  const factory TrafficEvent.stopListening() = StopListeningEvent;
}
