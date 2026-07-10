import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/collect_snapshot_usecase.dart';
import '../../domain/usecases/sync_snapshot_usecase.dart';
import 'hardware_metrics_state.dart';

export 'hardware_metrics_state.dart';

@lazySingleton
class HardwareMetricsCubit extends Cubit<HardwareMetricsState> {
  final CollectSnapshotUseCase _collect;
  final SyncSnapshotUseCase _sync;

  Timer? _timer;

  HardwareMetricsCubit({
    required CollectSnapshotUseCase collect,
    required SyncSnapshotUseCase sync,
  })  : _collect = collect,
        _sync = sync,
        super(const HardwareMetricsState());

  Future<void> refresh() async {
    emit(state.copyWith(status: HardwareMetricsStatus.loading));
    try {
      final snapshot = await _collect();
      emit(state.copyWith(status: HardwareMetricsStatus.loaded, latest: snapshot));
      _sync(snapshot).ignore();
    } catch (e) {
      emit(state.copyWith(
        status: HardwareMetricsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void startPeriodicSync({Duration interval = const Duration(minutes: 2)}) {
    _timer?.cancel();
    _timer = Timer.periodic(interval, (_) => refresh());
    refresh();
  }

  void stopPeriodicSync() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
