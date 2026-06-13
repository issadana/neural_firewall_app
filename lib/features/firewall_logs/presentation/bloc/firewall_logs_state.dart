import 'package:equatable/equatable.dart';
import '../../domain/entities/firewall_log.dart';

enum FirewallLogsStatus { initial, loading, loaded, error }

class FirewallLogsState extends Equatable {
  final FirewallLogsStatus status;
  final List<FirewallLog> logs;
  final bool hasMore;
  final String? filterAction;
  final String? filterThreatType;
  final String? filterServiceName;
  final String? filterAppName;
  final String? errorMessage;

  const FirewallLogsState({
    this.status = FirewallLogsStatus.initial,
    this.logs = const [],
    this.hasMore = true,
    this.filterAction,
    this.filterThreatType,
    this.filterServiceName,
    this.filterAppName,
    this.errorMessage,
  });

  FirewallLogsState copyWith({
    FirewallLogsStatus? status,
    List<FirewallLog>? logs,
    bool? hasMore,
    String? filterAction,
    String? filterThreatType,
    String? filterServiceName,
    String? filterAppName,
    String? errorMessage,
  }) =>
      FirewallLogsState(
        status: status ?? this.status,
        logs: logs ?? this.logs,
        hasMore: hasMore ?? this.hasMore,
        filterAction: filterAction,
        filterThreatType: filterThreatType,
        filterServiceName: filterServiceName,
        filterAppName: filterAppName,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props => [
        status,
        logs,
        hasMore,
        filterAction,
        filterThreatType,
        filterServiceName,
        filterAppName,
        errorMessage,
      ];
}
