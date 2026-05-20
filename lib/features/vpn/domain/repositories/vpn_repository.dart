abstract class VpnRepository {
  Future<void> start();
  Future<void> stop();
  Future<bool> isRunning();
  Future<List<String>> getInterfaces();
  Future<bool> checkPermission();
  Future<void> requestPermission();
  Stream<Map<String, dynamic>> get packetStream;
}
