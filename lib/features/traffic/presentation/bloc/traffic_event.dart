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

/// Dispatched once on startup to restore the traffic log persisted from the
/// previous session.
class LoadPersistedLogsEvent extends TrafficEvent {
  const LoadPersistedLogsEvent();
}

class StartListeningEvent extends TrafficEvent {
  const StartListeningEvent();
}

class StopListeningEvent extends TrafficEvent {
  const StopListeningEvent();
}
