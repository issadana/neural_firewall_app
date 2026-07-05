import 'package:injectable/injectable.dart';
import '../../domain/entities/firewall_log.dart';
import '../../domain/repositories/firewall_log_repository.dart';
import '../datasources/firewall_log_remote_datasource.dart';

@LazySingleton(as: FirewallLogRepository)
class FirewallLogRepositoryImpl implements FirewallLogRepository {
  final FirewallLogRemoteDataSource _dataSource;
  FirewallLogRepositoryImpl(this._dataSource);

  @override
  Future<List<FirewallLog>> getLogs({
    String? action,
    String? threatType,
    String? serviceName,
    String? appName,
    DateTime? fromDate,
    DateTime? toDate,
    int limit = 20,
    int offset = 0,
  }) =>
      _dataSource.getLogs(
        action: action,
        threatType: threatType,
        serviceName: serviceName,
        appName: appName,
        fromDate: fromDate,
        toDate: toDate,
        limit: limit,
        offset: offset,
      );

  @override
  Future<void> postLog(FirewallLog log) => _dataSource.postLog(log);
}
