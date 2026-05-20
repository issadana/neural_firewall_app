import '../entities/packet_record.dart';
import '../repositories/traffic_repository.dart';

class ProcessPacketUseCase {
  final TrafficRepository _repository;
  ProcessPacketUseCase(this._repository);

  Future<PacketRecord> call(Map<String, dynamic> rawPacket) =>
      _repository.processPacket(rawPacket);
}
