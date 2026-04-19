import 'package:freezed_annotation/freezed_annotation.dart';

part 'flow_features.freezed.dart';
part 'flow_features.g.dart';

@freezed
abstract class FlowFeatures with _$FlowFeatures {
  const factory FlowFeatures({
    required String srcIp,
    required int srcPort,
    required String dstIp,
    required int dstPort,
    required int packetCount,
    required int totalBytes,
    required int iatMean,
    required int iatStd,
    required int duration,
    required bool tcpSynFlag,
    required bool tcpFinFlag,
    required bool tcpResetFlag,
  }) = _FlowFeatures;

  factory FlowFeatures.fromJson(Map<String, dynamic> json) =>
      _$FlowFeaturesFromJson(json);
}
