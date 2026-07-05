import 'package:injectable/injectable.dart';
import '../entities/firewall_log.dart';
import '../repositories/firewall_log_repository.dart';

@injectable
class PostFirewallLogUseCase {
  final FirewallLogRepository _repository;
  PostFirewallLogUseCase(this._repository);

  Future<void> call(FirewallLog log) => _repository.postLog(log);
}
