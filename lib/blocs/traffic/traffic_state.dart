import 'dart:collection';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../models/app_models.dart';

part 'traffic_state.freezed.dart';

@freezed
abstract class TrafficState with _$TrafficState {
  const factory TrafficState({
    required ListQueue<PacketRecord> records,
    required List<double> sparklineData,
  }) = _TrafficState;
}
