abstract class TrafficEvent {
  const TrafficEvent();
}

class PacketReceivedEvent extends TrafficEvent {
  final Map<String, dynamic> rawPacket;
  const PacketReceivedEvent(this.rawPacket);
}

class ClearLogsEvent extends TrafficEvent {
  const ClearLogsEvent();
}

class StartListeningEvent extends TrafficEvent {
  const StartListeningEvent();
}

class StopListeningEvent extends TrafficEvent {
  const StopListeningEvent();
}
