import '../repositories/vpn_repository.dart';

class GetPacketStreamUseCase {
  final VpnRepository _repository;
  GetPacketStreamUseCase(this._repository);

  Stream<Map<String, dynamic>> call() => _repository.packetStream;
}
