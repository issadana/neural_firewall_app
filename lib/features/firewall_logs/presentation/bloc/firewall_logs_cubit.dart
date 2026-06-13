import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_firewall_logs_usecase.dart';
import '../../domain/usecases/post_firewall_log_usecase.dart';
import '../../domain/entities/firewall_log.dart';
import 'firewall_logs_state.dart';

export 'firewall_logs_state.dart';

class FirewallLogsCubit extends Cubit<FirewallLogsState> {
  final GetFirewallLogsUseCase _getLogs;
  final PostFirewallLogUseCase _postLog;

  static const _pageSize = 20;

  FirewallLogsCubit({
    required GetFirewallLogsUseCase getLogs,
    required PostFirewallLogUseCase postLog,
  })  : _getLogs = getLogs,
        _postLog = postLog,
        super(const FirewallLogsState());

  Future<void> loadLogs({bool refresh = false}) async {
    if (state.status == FirewallLogsStatus.loading) return;
    if (!refresh && !state.hasMore) return;

    emit(state.copyWith(
      status: FirewallLogsStatus.loading,
      logs: refresh ? [] : state.logs,
    ));

    try {
      final fetched = await _getLogs(
        action: state.filterAction,
        threatType: state.filterThreatType,
        serviceName: state.filterServiceName,
        appName: state.filterAppName,
        limit: _pageSize,
        offset: refresh ? 0 : state.logs.length,
      );

      final merged = refresh ? fetched : [...state.logs, ...fetched];
      emit(state.copyWith(
        status: FirewallLogsStatus.loaded,
        logs: merged,
        hasMore: fetched.length == _pageSize,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: FirewallLogsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void applyFilters({
    String? action,
    String? threatType,
    String? serviceName,
    String? appName,
  }) {
    emit(FirewallLogsState(
      filterAction: action,
      filterThreatType: threatType,
      filterServiceName: serviceName,
      filterAppName: appName,
    ));
    loadLogs(refresh: true);
  }

  void clearFilters() {
    emit(const FirewallLogsState());
    loadLogs(refresh: true);
  }

  Future<void> submitLog(FirewallLog log) async {
    try {
      await _postLog(log);
    } catch (_) {}
  }
}
