// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_stats.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DashboardStats {

 int get packetsAnalyzed; int get ipsBlacklisted; double get maxThreatPercent; int get blockedCount; int get warnCount; int get safeCount;
/// Create a copy of DashboardStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DashboardStatsCopyWith<DashboardStats> get copyWith => _$DashboardStatsCopyWithImpl<DashboardStats>(this as DashboardStats, _$identity);

  /// Serializes this DashboardStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardStats&&(identical(other.packetsAnalyzed, packetsAnalyzed) || other.packetsAnalyzed == packetsAnalyzed)&&(identical(other.ipsBlacklisted, ipsBlacklisted) || other.ipsBlacklisted == ipsBlacklisted)&&(identical(other.maxThreatPercent, maxThreatPercent) || other.maxThreatPercent == maxThreatPercent)&&(identical(other.blockedCount, blockedCount) || other.blockedCount == blockedCount)&&(identical(other.warnCount, warnCount) || other.warnCount == warnCount)&&(identical(other.safeCount, safeCount) || other.safeCount == safeCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,packetsAnalyzed,ipsBlacklisted,maxThreatPercent,blockedCount,warnCount,safeCount);

@override
String toString() {
  return 'DashboardStats(packetsAnalyzed: $packetsAnalyzed, ipsBlacklisted: $ipsBlacklisted, maxThreatPercent: $maxThreatPercent, blockedCount: $blockedCount, warnCount: $warnCount, safeCount: $safeCount)';
}


}

/// @nodoc
abstract mixin class $DashboardStatsCopyWith<$Res>  {
  factory $DashboardStatsCopyWith(DashboardStats value, $Res Function(DashboardStats) _then) = _$DashboardStatsCopyWithImpl;
@useResult
$Res call({
 int packetsAnalyzed, int ipsBlacklisted, double maxThreatPercent, int blockedCount, int warnCount, int safeCount
});




}
/// @nodoc
class _$DashboardStatsCopyWithImpl<$Res>
    implements $DashboardStatsCopyWith<$Res> {
  _$DashboardStatsCopyWithImpl(this._self, this._then);

  final DashboardStats _self;
  final $Res Function(DashboardStats) _then;

/// Create a copy of DashboardStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? packetsAnalyzed = null,Object? ipsBlacklisted = null,Object? maxThreatPercent = null,Object? blockedCount = null,Object? warnCount = null,Object? safeCount = null,}) {
  return _then(_self.copyWith(
packetsAnalyzed: null == packetsAnalyzed ? _self.packetsAnalyzed : packetsAnalyzed // ignore: cast_nullable_to_non_nullable
as int,ipsBlacklisted: null == ipsBlacklisted ? _self.ipsBlacklisted : ipsBlacklisted // ignore: cast_nullable_to_non_nullable
as int,maxThreatPercent: null == maxThreatPercent ? _self.maxThreatPercent : maxThreatPercent // ignore: cast_nullable_to_non_nullable
as double,blockedCount: null == blockedCount ? _self.blockedCount : blockedCount // ignore: cast_nullable_to_non_nullable
as int,warnCount: null == warnCount ? _self.warnCount : warnCount // ignore: cast_nullable_to_non_nullable
as int,safeCount: null == safeCount ? _self.safeCount : safeCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [DashboardStats].
extension DashboardStatsPatterns on DashboardStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DashboardStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DashboardStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DashboardStats value)  $default,){
final _that = this;
switch (_that) {
case _DashboardStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DashboardStats value)?  $default,){
final _that = this;
switch (_that) {
case _DashboardStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int packetsAnalyzed,  int ipsBlacklisted,  double maxThreatPercent,  int blockedCount,  int warnCount,  int safeCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DashboardStats() when $default != null:
return $default(_that.packetsAnalyzed,_that.ipsBlacklisted,_that.maxThreatPercent,_that.blockedCount,_that.warnCount,_that.safeCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int packetsAnalyzed,  int ipsBlacklisted,  double maxThreatPercent,  int blockedCount,  int warnCount,  int safeCount)  $default,) {final _that = this;
switch (_that) {
case _DashboardStats():
return $default(_that.packetsAnalyzed,_that.ipsBlacklisted,_that.maxThreatPercent,_that.blockedCount,_that.warnCount,_that.safeCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int packetsAnalyzed,  int ipsBlacklisted,  double maxThreatPercent,  int blockedCount,  int warnCount,  int safeCount)?  $default,) {final _that = this;
switch (_that) {
case _DashboardStats() when $default != null:
return $default(_that.packetsAnalyzed,_that.ipsBlacklisted,_that.maxThreatPercent,_that.blockedCount,_that.warnCount,_that.safeCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DashboardStats implements DashboardStats {
  const _DashboardStats({required this.packetsAnalyzed, required this.ipsBlacklisted, required this.maxThreatPercent, required this.blockedCount, required this.warnCount, required this.safeCount});
  factory _DashboardStats.fromJson(Map<String, dynamic> json) => _$DashboardStatsFromJson(json);

@override final  int packetsAnalyzed;
@override final  int ipsBlacklisted;
@override final  double maxThreatPercent;
@override final  int blockedCount;
@override final  int warnCount;
@override final  int safeCount;

/// Create a copy of DashboardStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DashboardStatsCopyWith<_DashboardStats> get copyWith => __$DashboardStatsCopyWithImpl<_DashboardStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DashboardStatsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DashboardStats&&(identical(other.packetsAnalyzed, packetsAnalyzed) || other.packetsAnalyzed == packetsAnalyzed)&&(identical(other.ipsBlacklisted, ipsBlacklisted) || other.ipsBlacklisted == ipsBlacklisted)&&(identical(other.maxThreatPercent, maxThreatPercent) || other.maxThreatPercent == maxThreatPercent)&&(identical(other.blockedCount, blockedCount) || other.blockedCount == blockedCount)&&(identical(other.warnCount, warnCount) || other.warnCount == warnCount)&&(identical(other.safeCount, safeCount) || other.safeCount == safeCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,packetsAnalyzed,ipsBlacklisted,maxThreatPercent,blockedCount,warnCount,safeCount);

@override
String toString() {
  return 'DashboardStats(packetsAnalyzed: $packetsAnalyzed, ipsBlacklisted: $ipsBlacklisted, maxThreatPercent: $maxThreatPercent, blockedCount: $blockedCount, warnCount: $warnCount, safeCount: $safeCount)';
}


}

/// @nodoc
abstract mixin class _$DashboardStatsCopyWith<$Res> implements $DashboardStatsCopyWith<$Res> {
  factory _$DashboardStatsCopyWith(_DashboardStats value, $Res Function(_DashboardStats) _then) = __$DashboardStatsCopyWithImpl;
@override @useResult
$Res call({
 int packetsAnalyzed, int ipsBlacklisted, double maxThreatPercent, int blockedCount, int warnCount, int safeCount
});




}
/// @nodoc
class __$DashboardStatsCopyWithImpl<$Res>
    implements _$DashboardStatsCopyWith<$Res> {
  __$DashboardStatsCopyWithImpl(this._self, this._then);

  final _DashboardStats _self;
  final $Res Function(_DashboardStats) _then;

/// Create a copy of DashboardStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? packetsAnalyzed = null,Object? ipsBlacklisted = null,Object? maxThreatPercent = null,Object? blockedCount = null,Object? warnCount = null,Object? safeCount = null,}) {
  return _then(_DashboardStats(
packetsAnalyzed: null == packetsAnalyzed ? _self.packetsAnalyzed : packetsAnalyzed // ignore: cast_nullable_to_non_nullable
as int,ipsBlacklisted: null == ipsBlacklisted ? _self.ipsBlacklisted : ipsBlacklisted // ignore: cast_nullable_to_non_nullable
as int,maxThreatPercent: null == maxThreatPercent ? _self.maxThreatPercent : maxThreatPercent // ignore: cast_nullable_to_non_nullable
as double,blockedCount: null == blockedCount ? _self.blockedCount : blockedCount // ignore: cast_nullable_to_non_nullable
as int,warnCount: null == warnCount ? _self.warnCount : warnCount // ignore: cast_nullable_to_non_nullable
as int,safeCount: null == safeCount ? _self.safeCount : safeCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
