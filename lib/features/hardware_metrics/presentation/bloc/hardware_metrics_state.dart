import 'package:equatable/equatable.dart';
import '../../domain/entities/hardware_snapshot.dart';

enum HardwareMetricsStatus { initial, loading, loaded, error }

class HardwareMetricsState extends Equatable {
  final HardwareMetricsStatus status;
  final HardwareSnapshot? latest;
  final String? errorMessage;

  const HardwareMetricsState({
    this.status = HardwareMetricsStatus.initial,
    this.latest,
    this.errorMessage,
  });

  HardwareMetricsState copyWith({
    HardwareMetricsStatus? status,
    HardwareSnapshot? latest,
    String? errorMessage,
  }) =>
      HardwareMetricsState(
        status: status ?? this.status,
        latest: latest ?? this.latest,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props => [status, latest, errorMessage];
}
