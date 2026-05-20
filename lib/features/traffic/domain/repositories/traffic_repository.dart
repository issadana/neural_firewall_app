import '../entities/packet_record.dart';

abstract class TrafficRepository {
  Future<PacketRecord> processPacket(Map<String, dynamic> rawPacket);
  void updateThresholds(double blockThreshold, double warnThreshold);
}
