import '../entities/firewall_log.dart';

abstract class FirewallLogRepository {
  Future<List<FirewallLog>> getLogs({
    String? action,
    String? threatType,
    String? serviceName,
    String? appName,
    DateTime? fromDate,
    DateTime? toDate,
    int limit = 20,
    int offset = 0,
  });

  Future<void> postLog(FirewallLog log);
}
