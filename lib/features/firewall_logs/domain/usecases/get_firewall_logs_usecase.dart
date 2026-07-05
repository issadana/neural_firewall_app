import 'package:injectable/injectable.dart';
import '../entities/firewall_log.dart';
import '../repositories/firewall_log_repository.dart';

@injectable
class GetFirewallLogsUseCase {
  final FirewallLogRepository _repository;
  GetFirewallLogsUseCase(this._repository);

  Future<List<FirewallLog>> call({
    String? action,
    String? threatType,
    String? serviceName,
    String? appName,
    DateTime? fromDate,
    DateTime? toDate,
    int limit = 20,
    int offset = 0,
  }) =>
      _repository.getLogs(
        action: action,
        threatType: threatType,
        serviceName: serviceName,
        appName: appName,
        fromDate: fromDate,
        toDate: toDate,
        limit: limit,
        offset: offset,
      );
}
