// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'traffic_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TrafficState {

 ListQueue<PacketRecord> get records; List<double> get sparklineData;
/// Create a copy of TrafficState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrafficStateCopyWith<TrafficState> get copyWith => _$TrafficStateCopyWithImpl<TrafficState>(this as TrafficState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrafficState&&const DeepCollectionEquality().equals(other.records, records)&&const DeepCollectionEquality().equals(other.sparklineData, sparklineData));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(records),const DeepCollectionEquality().hash(sparklineData));

@override
String toString() {
  return 'TrafficState(records: $records, sparklineData: $sparklineData)';
}


}

/// @nodoc
abstract mixin class $TrafficStateCopyWith<$Res>  {
  factory $TrafficStateCopyWith(TrafficState value, $Res Function(TrafficState) _then) = _$TrafficStateCopyWithImpl;
@useResult
$Res call({
 ListQueue<PacketRecord> records, List<double> sparklineData
});




}
/// @nodoc
class _$TrafficStateCopyWithImpl<$Res>
    implements $TrafficStateCopyWith<$Res> {
  _$TrafficStateCopyWithImpl(this._self, this._then);

  final TrafficState _self;
  final $Res Function(TrafficState) _then;

/// Create a copy of TrafficState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? records = null,Object? sparklineData = null,}) {
  return _then(_self.copyWith(
records: null == records ? _self.records : records // ignore: cast_nullable_to_non_nullable
as ListQueue<PacketRecord>,sparklineData: null == sparklineData ? _self.sparklineData : sparklineData // ignore: cast_nullable_to_non_nullable
as List<double>,
  ));
}

}


/// Adds pattern-matching-related methods to [TrafficState].
extension TrafficStatePatterns on TrafficState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrafficState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrafficState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrafficState value)  $default,){
final _that = this;
switch (_that) {
case _TrafficState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrafficState value)?  $default,){
final _that = this;
switch (_that) {
case _TrafficState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ListQueue<PacketRecord> records,  List<double> sparklineData)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrafficState() when $default != null:
return $default(_that.records,_that.sparklineData);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ListQueue<PacketRecord> records,  List<double> sparklineData)  $default,) {final _that = this;
switch (_that) {
case _TrafficState():
return $default(_that.records,_that.sparklineData);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ListQueue<PacketRecord> records,  List<double> sparklineData)?  $default,) {final _that = this;
switch (_that) {
case _TrafficState() when $default != null:
return $default(_that.records,_that.sparklineData);case _:
  return null;

}
}

}

/// @nodoc


class _TrafficState implements TrafficState {
  const _TrafficState({required this.records, required final  List<double> sparklineData}): _sparklineData = sparklineData;
  

@override final  ListQueue<PacketRecord> records;
 final  List<double> _sparklineData;
@override List<double> get sparklineData {
  if (_sparklineData is EqualUnmodifiableListView) return _sparklineData;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sparklineData);
}


/// Create a copy of TrafficState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrafficStateCopyWith<_TrafficState> get copyWith => __$TrafficStateCopyWithImpl<_TrafficState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrafficState&&const DeepCollectionEquality().equals(other.records, records)&&const DeepCollectionEquality().equals(other._sparklineData, _sparklineData));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(records),const DeepCollectionEquality().hash(_sparklineData));

@override
String toString() {
  return 'TrafficState(records: $records, sparklineData: $sparklineData)';
}


}

/// @nodoc
abstract mixin class _$TrafficStateCopyWith<$Res> implements $TrafficStateCopyWith<$Res> {
  factory _$TrafficStateCopyWith(_TrafficState value, $Res Function(_TrafficState) _then) = __$TrafficStateCopyWithImpl;
@override @useResult
$Res call({
 ListQueue<PacketRecord> records, List<double> sparklineData
});




}
/// @nodoc
class __$TrafficStateCopyWithImpl<$Res>
    implements _$TrafficStateCopyWith<$Res> {
  __$TrafficStateCopyWithImpl(this._self, this._then);

  final _TrafficState _self;
  final $Res Function(_TrafficState) _then;

/// Create a copy of TrafficState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? records = null,Object? sparklineData = null,}) {
  return _then(_TrafficState(
records: null == records ? _self.records : records // ignore: cast_nullable_to_non_nullable
as ListQueue<PacketRecord>,sparklineData: null == sparklineData ? _self._sparklineData : sparklineData // ignore: cast_nullable_to_non_nullable
as List<double>,
  ));
}


}

// dart format on
