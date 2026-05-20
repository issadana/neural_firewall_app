import '../../domain/repositories/vpn_repository.dart';
import '../datasources/vpn_native_datasource.dart';

class VpnRepositoryImpl implements VpnRepository {
  final VpnNativeDataSource _dataSource;
  VpnRepositoryImpl(this._dataSource);

  @override
  Future<void> start() => _dataSource.startVpn();

  @override
  Future<void> stop() => _dataSource.stopVpn();

  @override
  Future<bool> isRunning() => _dataSource.isVpnRunning();

  @override
  Future<List<String>> getInterfaces() => _dataSource.getInterfaces();

  @override
  Future<bool> checkPermission() => _dataSource.checkVpnPermission();

  @override
  Future<void> requestPermission() => _dataSource.requestVpnPermission();

  @override
  Stream<Map<String, dynamic>> get packetStream => _dataSource.packetStream;
}
