// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DashboardState {

 int get packetsAnalyzed; int get ipsBlacklisted; double get maxThreatPercent; int get blockedCount; int get warnCount; int get safeCount;
/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DashboardStateCopyWith<DashboardState> get copyWith => _$DashboardStateCopyWithImpl<DashboardState>(this as DashboardState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardState&&(identical(other.packetsAnalyzed, packetsAnalyzed) || other.packetsAnalyzed == packetsAnalyzed)&&(identical(other.ipsBlacklisted, ipsBlacklisted) || other.ipsBlacklisted == ipsBlacklisted)&&(identical(other.maxThreatPercent, maxThreatPercent) || other.maxThreatPercent == maxThreatPercent)&&(identical(other.blockedCount, blockedCount) || other.blockedCount == blockedCount)&&(identical(other.warnCount, warnCount) || other.warnCount == warnCount)&&(identical(other.safeCount, safeCount) || other.safeCount == safeCount));
}


@override
int get hashCode => Object.hash(runtimeType,packetsAnalyzed,ipsBlacklisted,maxThreatPercent,blockedCount,warnCount,safeCount);

@override
String toString() {
  return 'DashboardState(packetsAnalyzed: $packetsAnalyzed, ipsBlacklisted: $ipsBlacklisted, maxThreatPercent: $maxThreatPercent, blockedCount: $blockedCount, warnCount: $warnCount, safeCount: $safeCount)';
}


}

/// @nodoc
abstract mixin class $DashboardStateCopyWith<$Res>  {
  factory $DashboardStateCopyWith(DashboardState value, $Res Function(DashboardState) _then) = _$DashboardStateCopyWithImpl;
@useResult
$Res call({
 int packetsAnalyzed, int ipsBlacklisted, double maxThreatPercent, int blockedCount, int warnCount, int safeCount
});




}
/// @nodoc
class _$DashboardStateCopyWithImpl<$Res>
    implements $DashboardStateCopyWith<$Res> {
  _$DashboardStateCopyWithImpl(this._self, this._then);

  final DashboardState _self;
  final $Res Function(DashboardState) _then;

/// Create a copy of DashboardState
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


/// Adds pattern-matching-related methods to [DashboardState].
extension DashboardStatePatterns on DashboardState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DashboardState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DashboardState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DashboardState value)  $default,){
final _that = this;
switch (_that) {
case _DashboardState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DashboardState value)?  $default,){
final _that = this;
switch (_that) {
case _DashboardState() when $default != null:
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
case _DashboardState() when $default != null:
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
case _DashboardState():
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
case _DashboardState() when $default != null:
return $default(_that.packetsAnalyzed,_that.ipsBlacklisted,_that.maxThreatPercent,_that.blockedCount,_that.warnCount,_that.safeCount);case _:
  return null;

}
}

}

/// @nodoc


class _DashboardState implements DashboardState {
  const _DashboardState({this.packetsAnalyzed = 0, this.ipsBlacklisted = 0, this.maxThreatPercent = 0.0, this.blockedCount = 0, this.warnCount = 0, this.safeCount = 0});
  

@override@JsonKey() final  int packetsAnalyzed;
@override@JsonKey() final  int ipsBlacklisted;
@override@JsonKey() final  double maxThreatPercent;
@override@JsonKey() final  int blockedCount;
@override@JsonKey() final  int warnCount;
@override@JsonKey() final  int safeCount;

/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DashboardStateCopyWith<_DashboardState> get copyWith => __$DashboardStateCopyWithImpl<_DashboardState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DashboardState&&(identical(other.packetsAnalyzed, packetsAnalyzed) || other.packetsAnalyzed == packetsAnalyzed)&&(identical(other.ipsBlacklisted, ipsBlacklisted) || other.ipsBlacklisted == ipsBlacklisted)&&(identical(other.maxThreatPercent, maxThreatPercent) || other.maxThreatPercent == maxThreatPercent)&&(identical(other.blockedCount, blockedCount) || other.blockedCount == blockedCount)&&(identical(other.warnCount, warnCount) || other.warnCount == warnCount)&&(identical(other.safeCount, safeCount) || other.safeCount == safeCount));
}


@override
int get hashCode => Object.hash(runtimeType,packetsAnalyzed,ipsBlacklisted,maxThreatPercent,blockedCount,warnCount,safeCount);

@override
String toString() {
  return 'DashboardState(packetsAnalyzed: $packetsAnalyzed, ipsBlacklisted: $ipsBlacklisted, maxThreatPercent: $maxThreatPercent, blockedCount: $blockedCount, warnCount: $warnCount, safeCount: $safeCount)';
}


}

/// @nodoc
abstract mixin class _$DashboardStateCopyWith<$Res> implements $DashboardStateCopyWith<$Res> {
  factory _$DashboardStateCopyWith(_DashboardState value, $Res Function(_DashboardState) _then) = __$DashboardStateCopyWithImpl;
@override @useResult
$Res call({
 int packetsAnalyzed, int ipsBlacklisted, double maxThreatPercent, int blockedCount, int warnCount, int safeCount
});




}
/// @nodoc
class __$DashboardStateCopyWithImpl<$Res>
    implements _$DashboardStateCopyWith<$Res> {
  __$DashboardStateCopyWithImpl(this._self, this._then);

  final _DashboardState _self;
  final $Res Function(_DashboardState) _then;

/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? packetsAnalyzed = null,Object? ipsBlacklisted = null,Object? maxThreatPercent = null,Object? blockedCount = null,Object? warnCount = null,Object? safeCount = null,}) {
  return _then(_DashboardState(
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
