// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settings_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SettingsState {

 double get blockThreshold; double get warnThreshold; bool get floodDetection; bool get synFloodDetection; int get floodPktPerSec; int get synFloodPerSec; bool get bfModelEnabled; bool get dosModelEnabled; int get maxLogEntries; bool get darkMode;
/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SettingsStateCopyWith<SettingsState> get copyWith => _$SettingsStateCopyWithImpl<SettingsState>(this as SettingsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SettingsState&&(identical(other.blockThreshold, blockThreshold) || other.blockThreshold == blockThreshold)&&(identical(other.warnThreshold, warnThreshold) || other.warnThreshold == warnThreshold)&&(identical(other.floodDetection, floodDetection) || other.floodDetection == floodDetection)&&(identical(other.synFloodDetection, synFloodDetection) || other.synFloodDetection == synFloodDetection)&&(identical(other.floodPktPerSec, floodPktPerSec) || other.floodPktPerSec == floodPktPerSec)&&(identical(other.synFloodPerSec, synFloodPerSec) || other.synFloodPerSec == synFloodPerSec)&&(identical(other.bfModelEnabled, bfModelEnabled) || other.bfModelEnabled == bfModelEnabled)&&(identical(other.dosModelEnabled, dosModelEnabled) || other.dosModelEnabled == dosModelEnabled)&&(identical(other.maxLogEntries, maxLogEntries) || other.maxLogEntries == maxLogEntries)&&(identical(other.darkMode, darkMode) || other.darkMode == darkMode));
}


@override
int get hashCode => Object.hash(runtimeType,blockThreshold,warnThreshold,floodDetection,synFloodDetection,floodPktPerSec,synFloodPerSec,bfModelEnabled,dosModelEnabled,maxLogEntries,darkMode);

@override
String toString() {
  return 'SettingsState(blockThreshold: $blockThreshold, warnThreshold: $warnThreshold, floodDetection: $floodDetection, synFloodDetection: $synFloodDetection, floodPktPerSec: $floodPktPerSec, synFloodPerSec: $synFloodPerSec, bfModelEnabled: $bfModelEnabled, dosModelEnabled: $dosModelEnabled, maxLogEntries: $maxLogEntries, darkMode: $darkMode)';
}


}

/// @nodoc
abstract mixin class $SettingsStateCopyWith<$Res>  {
  factory $SettingsStateCopyWith(SettingsState value, $Res Function(SettingsState) _then) = _$SettingsStateCopyWithImpl;
@useResult
$Res call({
 double blockThreshold, double warnThreshold, bool floodDetection, bool synFloodDetection, int floodPktPerSec, int synFloodPerSec, bool bfModelEnabled, bool dosModelEnabled, int maxLogEntries, bool darkMode
});




}
/// @nodoc
class _$SettingsStateCopyWithImpl<$Res>
    implements $SettingsStateCopyWith<$Res> {
  _$SettingsStateCopyWithImpl(this._self, this._then);

  final SettingsState _self;
  final $Res Function(SettingsState) _then;

/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? blockThreshold = null,Object? warnThreshold = null,Object? floodDetection = null,Object? synFloodDetection = null,Object? floodPktPerSec = null,Object? synFloodPerSec = null,Object? bfModelEnabled = null,Object? dosModelEnabled = null,Object? maxLogEntries = null,Object? darkMode = null,}) {
  return _then(_self.copyWith(
blockThreshold: null == blockThreshold ? _self.blockThreshold : blockThreshold // ignore: cast_nullable_to_non_nullable
as double,warnThreshold: null == warnThreshold ? _self.warnThreshold : warnThreshold // ignore: cast_nullable_to_non_nullable
as double,floodDetection: null == floodDetection ? _self.floodDetection : floodDetection // ignore: cast_nullable_to_non_nullable
as bool,synFloodDetection: null == synFloodDetection ? _self.synFloodDetection : synFloodDetection // ignore: cast_nullable_to_non_nullable
as bool,floodPktPerSec: null == floodPktPerSec ? _self.floodPktPerSec : floodPktPerSec // ignore: cast_nullable_to_non_nullable
as int,synFloodPerSec: null == synFloodPerSec ? _self.synFloodPerSec : synFloodPerSec // ignore: cast_nullable_to_non_nullable
as int,bfModelEnabled: null == bfModelEnabled ? _self.bfModelEnabled : bfModelEnabled // ignore: cast_nullable_to_non_nullable
as bool,dosModelEnabled: null == dosModelEnabled ? _self.dosModelEnabled : dosModelEnabled // ignore: cast_nullable_to_non_nullable
as bool,maxLogEntries: null == maxLogEntries ? _self.maxLogEntries : maxLogEntries // ignore: cast_nullable_to_non_nullable
as int,darkMode: null == darkMode ? _self.darkMode : darkMode // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SettingsState].
extension SettingsStatePatterns on SettingsState {
/// A variant of `map` that fallback to returning `orElse`.
@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SettingsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SettingsState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SettingsState value)  $default,){
final _that = this;
switch (_that) {
case _SettingsState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SettingsState value)?  $default,){
final _that = this;
switch (_that) {
case _SettingsState() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double blockThreshold,  double warnThreshold,  bool floodDetection,  bool synFloodDetection,  int floodPktPerSec,  int synFloodPerSec,  bool bfModelEnabled,  bool dosModelEnabled,  int maxLogEntries,  bool darkMode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SettingsState() when $default != null:
return $default(_that.blockThreshold,_that.warnThreshold,_that.floodDetection,_that.synFloodDetection,_that.floodPktPerSec,_that.synFloodPerSec,_that.bfModelEnabled,_that.dosModelEnabled,_that.maxLogEntries,_that.darkMode);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double blockThreshold,  double warnThreshold,  bool floodDetection,  bool synFloodDetection,  int floodPktPerSec,  int synFloodPerSec,  bool bfModelEnabled,  bool dosModelEnabled,  int maxLogEntries,  bool darkMode)  $default,) {final _that = this;
switch (_that) {
case _SettingsState():
return $default(_that.blockThreshold,_that.warnThreshold,_that.floodDetection,_that.synFloodDetection,_that.floodPktPerSec,_that.synFloodPerSec,_that.bfModelEnabled,_that.dosModelEnabled,_that.maxLogEntries,_that.darkMode);case _:
  throw StateError('Unexpected subclass');

}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double blockThreshold,  double warnThreshold,  bool floodDetection,  bool synFloodDetection,  int floodPktPerSec,  int synFloodPerSec,  bool bfModelEnabled,  bool dosModelEnabled,  int maxLogEntries,  bool darkMode)?  $default,) {final _that = this;
switch (_that) {
case _SettingsState() when $default != null:
return $default(_that.blockThreshold,_that.warnThreshold,_that.floodDetection,_that.synFloodDetection,_that.floodPktPerSec,_that.synFloodPerSec,_that.bfModelEnabled,_that.dosModelEnabled,_that.maxLogEntries,_that.darkMode);case _:
  return null;

}
}

}

/// @nodoc


class _SettingsState implements SettingsState {
  const _SettingsState({this.blockThreshold = 0.20, this.warnThreshold = 0.10, this.floodDetection = true, this.synFloodDetection = true, this.floodPktPerSec = 1000, this.synFloodPerSec = 100, this.bfModelEnabled = true, this.dosModelEnabled = true, this.maxLogEntries = 200, this.darkMode = true});


@override@JsonKey() final  double blockThreshold;
@override@JsonKey() final  double warnThreshold;
@override@JsonKey() final  bool floodDetection;
@override@JsonKey() final  bool synFloodDetection;
@override@JsonKey() final  int floodPktPerSec;
@override@JsonKey() final  int synFloodPerSec;
@override@JsonKey() final  bool bfModelEnabled;
@override@JsonKey() final  bool dosModelEnabled;
@override@JsonKey() final  int maxLogEntries;
@override@JsonKey() final  bool darkMode;

/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SettingsStateCopyWith<_SettingsState> get copyWith => __$SettingsStateCopyWithImpl<_SettingsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SettingsState&&(identical(other.blockThreshold, blockThreshold) || other.blockThreshold == blockThreshold)&&(identical(other.warnThreshold, warnThreshold) || other.warnThreshold == warnThreshold)&&(identical(other.floodDetection, floodDetection) || other.floodDetection == floodDetection)&&(identical(other.synFloodDetection, synFloodDetection) || other.synFloodDetection == synFloodDetection)&&(identical(other.floodPktPerSec, floodPktPerSec) || other.floodPktPerSec == floodPktPerSec)&&(identical(other.synFloodPerSec, synFloodPerSec) || other.synFloodPerSec == synFloodPerSec)&&(identical(other.bfModelEnabled, bfModelEnabled) || other.bfModelEnabled == bfModelEnabled)&&(identical(other.dosModelEnabled, dosModelEnabled) || other.dosModelEnabled == dosModelEnabled)&&(identical(other.maxLogEntries, maxLogEntries) || other.maxLogEntries == maxLogEntries)&&(identical(other.darkMode, darkMode) || other.darkMode == darkMode));
}


@override
int get hashCode => Object.hash(runtimeType,blockThreshold,warnThreshold,floodDetection,synFloodDetection,floodPktPerSec,synFloodPerSec,bfModelEnabled,dosModelEnabled,maxLogEntries,darkMode);

@override
String toString() {
  return 'SettingsState(blockThreshold: $blockThreshold, warnThreshold: $warnThreshold, floodDetection: $floodDetection, synFloodDetection: $synFloodDetection, floodPktPerSec: $floodPktPerSec, synFloodPerSec: $synFloodPerSec, bfModelEnabled: $bfModelEnabled, dosModelEnabled: $dosModelEnabled, maxLogEntries: $maxLogEntries, darkMode: $darkMode)';
}


}

/// @nodoc
abstract mixin class _$SettingsStateCopyWith<$Res> implements $SettingsStateCopyWith<$Res> {
  factory _$SettingsStateCopyWith(_SettingsState value, $Res Function(_SettingsState) _then) = __$SettingsStateCopyWithImpl;
@override @useResult
$Res call({
 double blockThreshold, double warnThreshold, bool floodDetection, bool synFloodDetection, int floodPktPerSec, int synFloodPerSec, bool bfModelEnabled, bool dosModelEnabled, int maxLogEntries, bool darkMode
});




}
/// @nodoc
class __$SettingsStateCopyWithImpl<$Res>
    implements _$SettingsStateCopyWith<$Res> {
  __$SettingsStateCopyWithImpl(this._self, this._then);

  final _SettingsState _self;
  final $Res Function(_SettingsState) _then;

/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? blockThreshold = null,Object? warnThreshold = null,Object? floodDetection = null,Object? synFloodDetection = null,Object? floodPktPerSec = null,Object? synFloodPerSec = null,Object? bfModelEnabled = null,Object? dosModelEnabled = null,Object? maxLogEntries = null,Object? darkMode = null,}) {
  return _then(_SettingsState(
blockThreshold: null == blockThreshold ? _self.blockThreshold : blockThreshold // ignore: cast_nullable_to_non_nullable
as double,warnThreshold: null == warnThreshold ? _self.warnThreshold : warnThreshold // ignore: cast_nullable_to_non_nullable
as double,floodDetection: null == floodDetection ? _self.floodDetection : floodDetection // ignore: cast_nullable_to_non_nullable
as bool,synFloodDetection: null == synFloodDetection ? _self.synFloodDetection : synFloodDetection // ignore: cast_nullable_to_non_nullable
as bool,floodPktPerSec: null == floodPktPerSec ? _self.floodPktPerSec : floodPktPerSec // ignore: cast_nullable_to_non_nullable
as int,synFloodPerSec: null == synFloodPerSec ? _self.synFloodPerSec : synFloodPerSec // ignore: cast_nullable_to_non_nullable
as int,bfModelEnabled: null == bfModelEnabled ? _self.bfModelEnabled : bfModelEnabled // ignore: cast_nullable_to_non_nullable
as bool,dosModelEnabled: null == dosModelEnabled ? _self.dosModelEnabled : dosModelEnabled // ignore: cast_nullable_to_non_nullable
as bool,maxLogEntries: null == maxLogEntries ? _self.maxLogEntries : maxLogEntries // ignore: cast_nullable_to_non_nullable
as int,darkMode: null == darkMode ? _self.darkMode : darkMode // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
