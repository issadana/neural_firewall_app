import 'package:freezed_annotation/freezed_annotation.dart';

part 'detection_result.freezed.dart';
part 'detection_result.g.dart';

@freezed
abstract class DetectionResult with _$DetectionResult {
  const factory DetectionResult({
    required String flowId,
    required double bruteForceScore,
    required double dosScore,
    required String modelVersion,
    required DateTime timestamp,
    List<String>? flaggedReasons,
  }) = _DetectionResult;

  factory DetectionResult.fromJson(Map<String, dynamic> json) =>
      _$DetectionResultFromJson(json);
}
