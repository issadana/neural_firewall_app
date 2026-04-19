// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detection_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DetectionResult _$DetectionResultFromJson(Map<String, dynamic> json) =>
    _DetectionResult(
      flowId: json['flowId'] as String,
      bruteForceScore: (json['bruteForceScore'] as num).toDouble(),
      dosScore: (json['dosScore'] as num).toDouble(),
      modelVersion: json['modelVersion'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      flaggedReasons: (json['flaggedReasons'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$DetectionResultToJson(_DetectionResult instance) =>
    <String, dynamic>{
      'flowId': instance.flowId,
      'bruteForceScore': instance.bruteForceScore,
      'dosScore': instance.dosScore,
      'modelVersion': instance.modelVersion,
      'timestamp': instance.timestamp.toIso8601String(),
      'flaggedReasons': instance.flaggedReasons,
    };
