// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'detection_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DetectionResult {

 String get flowId; double get bruteForceScore; double get dosScore; String get modelVersion; DateTime get timestamp; List<String>? get flaggedReasons;
/// Create a copy of DetectionResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DetectionResultCopyWith<DetectionResult> get copyWith => _$DetectionResultCopyWithImpl<DetectionResult>(this as DetectionResult, _$identity);

  /// Serializes this DetectionResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DetectionResult&&(identical(other.flowId, flowId) || other.flowId == flowId)&&(identical(other.bruteForceScore, bruteForceScore) || other.bruteForceScore == bruteForceScore)&&(identical(other.dosScore, dosScore) || other.dosScore == dosScore)&&(identical(other.modelVersion, modelVersion) || other.modelVersion == modelVersion)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&const DeepCollectionEquality().equals(other.flaggedReasons, flaggedReasons));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,flowId,bruteForceScore,dosScore,modelVersion,timestamp,const DeepCollectionEquality().hash(flaggedReasons));

@override
String toString() {
  return 'DetectionResult(flowId: $flowId, bruteForceScore: $bruteForceScore, dosScore: $dosScore, modelVersion: $modelVersion, timestamp: $timestamp, flaggedReasons: $flaggedReasons)';
}


}

/// @nodoc
abstract mixin class $DetectionResultCopyWith<$Res>  {
  factory $DetectionResultCopyWith(DetectionResult value, $Res Function(DetectionResult) _then) = _$DetectionResultCopyWithImpl;
@useResult
$Res call({
 String flowId, double bruteForceScore, double dosScore, String modelVersion, DateTime timestamp, List<String>? flaggedReasons
});




}
/// @nodoc
class _$DetectionResultCopyWithImpl<$Res>
    implements $DetectionResultCopyWith<$Res> {
  _$DetectionResultCopyWithImpl(this._self, this._then);

  final DetectionResult _self;
  final $Res Function(DetectionResult) _then;

/// Create a copy of DetectionResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? flowId = null,Object? bruteForceScore = null,Object? dosScore = null,Object? modelVersion = null,Object? timestamp = null,Object? flaggedReasons = freezed,}) {
  return _then(_self.copyWith(
flowId: null == flowId ? _self.flowId : flowId // ignore: cast_nullable_to_non_nullable
as String,bruteForceScore: null == bruteForceScore ? _self.bruteForceScore : bruteForceScore // ignore: cast_nullable_to_non_nullable
as double,dosScore: null == dosScore ? _self.dosScore : dosScore // ignore: cast_nullable_to_non_nullable
as double,modelVersion: null == modelVersion ? _self.modelVersion : modelVersion // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,flaggedReasons: freezed == flaggedReasons ? _self.flaggedReasons : flaggedReasons // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}

}


/// Adds pattern-matching-related methods to [DetectionResult].
extension DetectionResultPatterns on DetectionResult {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DetectionResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DetectionResult() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DetectionResult value)  $default,){
final _that = this;
switch (_that) {
case _DetectionResult():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DetectionResult value)?  $default,){
final _that = this;
switch (_that) {
case _DetectionResult() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String flowId,  double bruteForceScore,  double dosScore,  String modelVersion,  DateTime timestamp,  List<String>? flaggedReasons)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DetectionResult() when $default != null:
return $default(_that.flowId,_that.bruteForceScore,_that.dosScore,_that.modelVersion,_that.timestamp,_that.flaggedReasons);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String flowId,  double bruteForceScore,  double dosScore,  String modelVersion,  DateTime timestamp,  List<String>? flaggedReasons)  $default,) {final _that = this;
switch (_that) {
case _DetectionResult():
return $default(_that.flowId,_that.bruteForceScore,_that.dosScore,_that.modelVersion,_that.timestamp,_that.flaggedReasons);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String flowId,  double bruteForceScore,  double dosScore,  String modelVersion,  DateTime timestamp,  List<String>? flaggedReasons)?  $default,) {final _that = this;
switch (_that) {
case _DetectionResult() when $default != null:
return $default(_that.flowId,_that.bruteForceScore,_that.dosScore,_that.modelVersion,_that.timestamp,_that.flaggedReasons);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DetectionResult implements DetectionResult {
  const _DetectionResult({required this.flowId, required this.bruteForceScore, required this.dosScore, required this.modelVersion, required this.timestamp, final  List<String>? flaggedReasons}): _flaggedReasons = flaggedReasons;
  factory _DetectionResult.fromJson(Map<String, dynamic> json) => _$DetectionResultFromJson(json);

@override final  String flowId;
@override final  double bruteForceScore;
@override final  double dosScore;
@override final  String modelVersion;
@override final  DateTime timestamp;
 final  List<String>? _flaggedReasons;
@override List<String>? get flaggedReasons {
  final value = _flaggedReasons;
  if (value == null) return null;
  if (_flaggedReasons is EqualUnmodifiableListView) return _flaggedReasons;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of DetectionResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DetectionResultCopyWith<_DetectionResult> get copyWith => __$DetectionResultCopyWithImpl<_DetectionResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DetectionResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DetectionResult&&(identical(other.flowId, flowId) || other.flowId == flowId)&&(identical(other.bruteForceScore, bruteForceScore) || other.bruteForceScore == bruteForceScore)&&(identical(other.dosScore, dosScore) || other.dosScore == dosScore)&&(identical(other.modelVersion, modelVersion) || other.modelVersion == modelVersion)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&const DeepCollectionEquality().equals(other._flaggedReasons, _flaggedReasons));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,flowId,bruteForceScore,dosScore,modelVersion,timestamp,const DeepCollectionEquality().hash(_flaggedReasons));

@override
String toString() {
  return 'DetectionResult(flowId: $flowId, bruteForceScore: $bruteForceScore, dosScore: $dosScore, modelVersion: $modelVersion, timestamp: $timestamp, flaggedReasons: $flaggedReasons)';
}


}

/// @nodoc
abstract mixin class _$DetectionResultCopyWith<$Res> implements $DetectionResultCopyWith<$Res> {
  factory _$DetectionResultCopyWith(_DetectionResult value, $Res Function(_DetectionResult) _then) = __$DetectionResultCopyWithImpl;
@override @useResult
$Res call({
 String flowId, double bruteForceScore, double dosScore, String modelVersion, DateTime timestamp, List<String>? flaggedReasons
});




}
/// @nodoc
class __$DetectionResultCopyWithImpl<$Res>
    implements _$DetectionResultCopyWith<$Res> {
  __$DetectionResultCopyWithImpl(this._self, this._then);

  final _DetectionResult _self;
  final $Res Function(_DetectionResult) _then;

/// Create a copy of DetectionResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? flowId = null,Object? bruteForceScore = null,Object? dosScore = null,Object? modelVersion = null,Object? timestamp = null,Object? flaggedReasons = freezed,}) {
  return _then(_DetectionResult(
flowId: null == flowId ? _self.flowId : flowId // ignore: cast_nullable_to_non_nullable
as String,bruteForceScore: null == bruteForceScore ? _self.bruteForceScore : bruteForceScore // ignore: cast_nullable_to_non_nullable
as double,dosScore: null == dosScore ? _self.dosScore : dosScore // ignore: cast_nullable_to_non_nullable
as double,modelVersion: null == modelVersion ? _self.modelVersion : modelVersion // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,flaggedReasons: freezed == flaggedReasons ? _self._flaggedReasons : flaggedReasons // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}


}

// dart format on
