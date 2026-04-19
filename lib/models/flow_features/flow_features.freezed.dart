// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'flow_features.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FlowFeatures {

 String get srcIp; int get srcPort; String get dstIp; int get dstPort; int get packetCount; int get totalBytes; int get iatMean; int get iatStd; int get duration; bool get tcpSynFlag; bool get tcpFinFlag; bool get tcpResetFlag;
/// Create a copy of FlowFeatures
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FlowFeaturesCopyWith<FlowFeatures> get copyWith => _$FlowFeaturesCopyWithImpl<FlowFeatures>(this as FlowFeatures, _$identity);

  /// Serializes this FlowFeatures to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FlowFeatures&&(identical(other.srcIp, srcIp) || other.srcIp == srcIp)&&(identical(other.srcPort, srcPort) || other.srcPort == srcPort)&&(identical(other.dstIp, dstIp) || other.dstIp == dstIp)&&(identical(other.dstPort, dstPort) || other.dstPort == dstPort)&&(identical(other.packetCount, packetCount) || other.packetCount == packetCount)&&(identical(other.totalBytes, totalBytes) || other.totalBytes == totalBytes)&&(identical(other.iatMean, iatMean) || other.iatMean == iatMean)&&(identical(other.iatStd, iatStd) || other.iatStd == iatStd)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.tcpSynFlag, tcpSynFlag) || other.tcpSynFlag == tcpSynFlag)&&(identical(other.tcpFinFlag, tcpFinFlag) || other.tcpFinFlag == tcpFinFlag)&&(identical(other.tcpResetFlag, tcpResetFlag) || other.tcpResetFlag == tcpResetFlag));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,srcIp,srcPort,dstIp,dstPort,packetCount,totalBytes,iatMean,iatStd,duration,tcpSynFlag,tcpFinFlag,tcpResetFlag);

@override
String toString() {
  return 'FlowFeatures(srcIp: $srcIp, srcPort: $srcPort, dstIp: $dstIp, dstPort: $dstPort, packetCount: $packetCount, totalBytes: $totalBytes, iatMean: $iatMean, iatStd: $iatStd, duration: $duration, tcpSynFlag: $tcpSynFlag, tcpFinFlag: $tcpFinFlag, tcpResetFlag: $tcpResetFlag)';
}


}

/// @nodoc
abstract mixin class $FlowFeaturesCopyWith<$Res>  {
  factory $FlowFeaturesCopyWith(FlowFeatures value, $Res Function(FlowFeatures) _then) = _$FlowFeaturesCopyWithImpl;
@useResult
$Res call({
 String srcIp, int srcPort, String dstIp, int dstPort, int packetCount, int totalBytes, int iatMean, int iatStd, int duration, bool tcpSynFlag, bool tcpFinFlag, bool tcpResetFlag
});




}
/// @nodoc
class _$FlowFeaturesCopyWithImpl<$Res>
    implements $FlowFeaturesCopyWith<$Res> {
  _$FlowFeaturesCopyWithImpl(this._self, this._then);

  final FlowFeatures _self;
  final $Res Function(FlowFeatures) _then;

/// Create a copy of FlowFeatures
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? srcIp = null,Object? srcPort = null,Object? dstIp = null,Object? dstPort = null,Object? packetCount = null,Object? totalBytes = null,Object? iatMean = null,Object? iatStd = null,Object? duration = null,Object? tcpSynFlag = null,Object? tcpFinFlag = null,Object? tcpResetFlag = null,}) {
  return _then(_self.copyWith(
srcIp: null == srcIp ? _self.srcIp : srcIp // ignore: cast_nullable_to_non_nullable
as String,srcPort: null == srcPort ? _self.srcPort : srcPort // ignore: cast_nullable_to_non_nullable
as int,dstIp: null == dstIp ? _self.dstIp : dstIp // ignore: cast_nullable_to_non_nullable
as String,dstPort: null == dstPort ? _self.dstPort : dstPort // ignore: cast_nullable_to_non_nullable
as int,packetCount: null == packetCount ? _self.packetCount : packetCount // ignore: cast_nullable_to_non_nullable
as int,totalBytes: null == totalBytes ? _self.totalBytes : totalBytes // ignore: cast_nullable_to_non_nullable
as int,iatMean: null == iatMean ? _self.iatMean : iatMean // ignore: cast_nullable_to_non_nullable
as int,iatStd: null == iatStd ? _self.iatStd : iatStd // ignore: cast_nullable_to_non_nullable
as int,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as int,tcpSynFlag: null == tcpSynFlag ? _self.tcpSynFlag : tcpSynFlag // ignore: cast_nullable_to_non_nullable
as bool,tcpFinFlag: null == tcpFinFlag ? _self.tcpFinFlag : tcpFinFlag // ignore: cast_nullable_to_non_nullable
as bool,tcpResetFlag: null == tcpResetFlag ? _self.tcpResetFlag : tcpResetFlag // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [FlowFeatures].
extension FlowFeaturesPatterns on FlowFeatures {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FlowFeatures value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FlowFeatures() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FlowFeatures value)  $default,){
final _that = this;
switch (_that) {
case _FlowFeatures():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FlowFeatures value)?  $default,){
final _that = this;
switch (_that) {
case _FlowFeatures() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String srcIp,  int srcPort,  String dstIp,  int dstPort,  int packetCount,  int totalBytes,  int iatMean,  int iatStd,  int duration,  bool tcpSynFlag,  bool tcpFinFlag,  bool tcpResetFlag)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FlowFeatures() when $default != null:
return $default(_that.srcIp,_that.srcPort,_that.dstIp,_that.dstPort,_that.packetCount,_that.totalBytes,_that.iatMean,_that.iatStd,_that.duration,_that.tcpSynFlag,_that.tcpFinFlag,_that.tcpResetFlag);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String srcIp,  int srcPort,  String dstIp,  int dstPort,  int packetCount,  int totalBytes,  int iatMean,  int iatStd,  int duration,  bool tcpSynFlag,  bool tcpFinFlag,  bool tcpResetFlag)  $default,) {final _that = this;
switch (_that) {
case _FlowFeatures():
return $default(_that.srcIp,_that.srcPort,_that.dstIp,_that.dstPort,_that.packetCount,_that.totalBytes,_that.iatMean,_that.iatStd,_that.duration,_that.tcpSynFlag,_that.tcpFinFlag,_that.tcpResetFlag);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String srcIp,  int srcPort,  String dstIp,  int dstPort,  int packetCount,  int totalBytes,  int iatMean,  int iatStd,  int duration,  bool tcpSynFlag,  bool tcpFinFlag,  bool tcpResetFlag)?  $default,) {final _that = this;
switch (_that) {
case _FlowFeatures() when $default != null:
return $default(_that.srcIp,_that.srcPort,_that.dstIp,_that.dstPort,_that.packetCount,_that.totalBytes,_that.iatMean,_that.iatStd,_that.duration,_that.tcpSynFlag,_that.tcpFinFlag,_that.tcpResetFlag);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FlowFeatures implements FlowFeatures {
  const _FlowFeatures({required this.srcIp, required this.srcPort, required this.dstIp, required this.dstPort, required this.packetCount, required this.totalBytes, required this.iatMean, required this.iatStd, required this.duration, required this.tcpSynFlag, required this.tcpFinFlag, required this.tcpResetFlag});
  factory _FlowFeatures.fromJson(Map<String, dynamic> json) => _$FlowFeaturesFromJson(json);

@override final  String srcIp;
@override final  int srcPort;
@override final  String dstIp;
@override final  int dstPort;
@override final  int packetCount;
@override final  int totalBytes;
@override final  int iatMean;
@override final  int iatStd;
@override final  int duration;
@override final  bool tcpSynFlag;
@override final  bool tcpFinFlag;
@override final  bool tcpResetFlag;

/// Create a copy of FlowFeatures
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FlowFeaturesCopyWith<_FlowFeatures> get copyWith => __$FlowFeaturesCopyWithImpl<_FlowFeatures>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FlowFeaturesToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FlowFeatures&&(identical(other.srcIp, srcIp) || other.srcIp == srcIp)&&(identical(other.srcPort, srcPort) || other.srcPort == srcPort)&&(identical(other.dstIp, dstIp) || other.dstIp == dstIp)&&(identical(other.dstPort, dstPort) || other.dstPort == dstPort)&&(identical(other.packetCount, packetCount) || other.packetCount == packetCount)&&(identical(other.totalBytes, totalBytes) || other.totalBytes == totalBytes)&&(identical(other.iatMean, iatMean) || other.iatMean == iatMean)&&(identical(other.iatStd, iatStd) || other.iatStd == iatStd)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.tcpSynFlag, tcpSynFlag) || other.tcpSynFlag == tcpSynFlag)&&(identical(other.tcpFinFlag, tcpFinFlag) || other.tcpFinFlag == tcpFinFlag)&&(identical(other.tcpResetFlag, tcpResetFlag) || other.tcpResetFlag == tcpResetFlag));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,srcIp,srcPort,dstIp,dstPort,packetCount,totalBytes,iatMean,iatStd,duration,tcpSynFlag,tcpFinFlag,tcpResetFlag);

@override
String toString() {
  return 'FlowFeatures(srcIp: $srcIp, srcPort: $srcPort, dstIp: $dstIp, dstPort: $dstPort, packetCount: $packetCount, totalBytes: $totalBytes, iatMean: $iatMean, iatStd: $iatStd, duration: $duration, tcpSynFlag: $tcpSynFlag, tcpFinFlag: $tcpFinFlag, tcpResetFlag: $tcpResetFlag)';
}


}

/// @nodoc
abstract mixin class _$FlowFeaturesCopyWith<$Res> implements $FlowFeaturesCopyWith<$Res> {
  factory _$FlowFeaturesCopyWith(_FlowFeatures value, $Res Function(_FlowFeatures) _then) = __$FlowFeaturesCopyWithImpl;
@override @useResult
$Res call({
 String srcIp, int srcPort, String dstIp, int dstPort, int packetCount, int totalBytes, int iatMean, int iatStd, int duration, bool tcpSynFlag, bool tcpFinFlag, bool tcpResetFlag
});




}
/// @nodoc
class __$FlowFeaturesCopyWithImpl<$Res>
    implements _$FlowFeaturesCopyWith<$Res> {
  __$FlowFeaturesCopyWithImpl(this._self, this._then);

  final _FlowFeatures _self;
  final $Res Function(_FlowFeatures) _then;

/// Create a copy of FlowFeatures
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? srcIp = null,Object? srcPort = null,Object? dstIp = null,Object? dstPort = null,Object? packetCount = null,Object? totalBytes = null,Object? iatMean = null,Object? iatStd = null,Object? duration = null,Object? tcpSynFlag = null,Object? tcpFinFlag = null,Object? tcpResetFlag = null,}) {
  return _then(_FlowFeatures(
srcIp: null == srcIp ? _self.srcIp : srcIp // ignore: cast_nullable_to_non_nullable
as String,srcPort: null == srcPort ? _self.srcPort : srcPort // ignore: cast_nullable_to_non_nullable
as int,dstIp: null == dstIp ? _self.dstIp : dstIp // ignore: cast_nullable_to_non_nullable
as String,dstPort: null == dstPort ? _self.dstPort : dstPort // ignore: cast_nullable_to_non_nullable
as int,packetCount: null == packetCount ? _self.packetCount : packetCount // ignore: cast_nullable_to_non_nullable
as int,totalBytes: null == totalBytes ? _self.totalBytes : totalBytes // ignore: cast_nullable_to_non_nullable
as int,iatMean: null == iatMean ? _self.iatMean : iatMean // ignore: cast_nullable_to_non_nullable
as int,iatStd: null == iatStd ? _self.iatStd : iatStd // ignore: cast_nullable_to_non_nullable
as int,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as int,tcpSynFlag: null == tcpSynFlag ? _self.tcpSynFlag : tcpSynFlag // ignore: cast_nullable_to_non_nullable
as bool,tcpFinFlag: null == tcpFinFlag ? _self.tcpFinFlag : tcpFinFlag // ignore: cast_nullable_to_non_nullable
as bool,tcpResetFlag: null == tcpResetFlag ? _self.tcpResetFlag : tcpResetFlag // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
