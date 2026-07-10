import 'package:injectable/injectable.dart';

import '../entities/packet_record.dart';
import '../repositories/traffic_repository.dart';

@injectable
class ProcessPacketUseCase {
  final TrafficRepository _repository;
  ProcessPacketUseCase(this._repository);

  Future<PacketRecord> call(Map<String, dynamic> rawPacket) =>
      _repository.processPacket(rawPacket);
}
