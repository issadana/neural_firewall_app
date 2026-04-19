// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'blacklist_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BlacklistState {

 List<BlacklistEntry> get entries;
/// Create a copy of BlacklistState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BlacklistStateCopyWith<BlacklistState> get copyWith => _$BlacklistStateCopyWithImpl<BlacklistState>(this as BlacklistState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BlacklistState&&const DeepCollectionEquality().equals(other.entries, entries));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(entries));

@override
String toString() {
  return 'BlacklistState(entries: $entries)';
}


}

/// @nodoc
abstract mixin class $BlacklistStateCopyWith<$Res>  {
  factory $BlacklistStateCopyWith(BlacklistState value, $Res Function(BlacklistState) _then) = _$BlacklistStateCopyWithImpl;
@useResult
$Res call({
 List<BlacklistEntry> entries
});




}
/// @nodoc
class _$BlacklistStateCopyWithImpl<$Res>
    implements $BlacklistStateCopyWith<$Res> {
  _$BlacklistStateCopyWithImpl(this._self, this._then);

  final BlacklistState _self;
  final $Res Function(BlacklistState) _then;

/// Create a copy of BlacklistState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? entries = null,}) {
  return _then(_self.copyWith(
entries: null == entries ? _self.entries : entries // ignore: cast_nullable_to_non_nullable
as List<BlacklistEntry>,
  ));
}

}


/// Adds pattern-matching-related methods to [BlacklistState].
extension BlacklistStatePatterns on BlacklistState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BlacklistState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BlacklistState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BlacklistState value)  $default,){
final _that = this;
switch (_that) {
case _BlacklistState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BlacklistState value)?  $default,){
final _that = this;
switch (_that) {
case _BlacklistState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<BlacklistEntry> entries)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BlacklistState() when $default != null:
return $default(_that.entries);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<BlacklistEntry> entries)  $default,) {final _that = this;
switch (_that) {
case _BlacklistState():
return $default(_that.entries);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<BlacklistEntry> entries)?  $default,) {final _that = this;
switch (_that) {
case _BlacklistState() when $default != null:
return $default(_that.entries);case _:
  return null;

}
}

}

/// @nodoc


class _BlacklistState implements BlacklistState {
  const _BlacklistState({required final  List<BlacklistEntry> entries}): _entries = entries;
  

 final  List<BlacklistEntry> _entries;
@override List<BlacklistEntry> get entries {
  if (_entries is EqualUnmodifiableListView) return _entries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_entries);
}


/// Create a copy of BlacklistState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BlacklistStateCopyWith<_BlacklistState> get copyWith => __$BlacklistStateCopyWithImpl<_BlacklistState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BlacklistState&&const DeepCollectionEquality().equals(other._entries, _entries));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_entries));

@override
String toString() {
  return 'BlacklistState(entries: $entries)';
}


}

/// @nodoc
abstract mixin class _$BlacklistStateCopyWith<$Res> implements $BlacklistStateCopyWith<$Res> {
  factory _$BlacklistStateCopyWith(_BlacklistState value, $Res Function(_BlacklistState) _then) = __$BlacklistStateCopyWithImpl;
@override @useResult
$Res call({
 List<BlacklistEntry> entries
});




}
/// @nodoc
class __$BlacklistStateCopyWithImpl<$Res>
    implements _$BlacklistStateCopyWith<$Res> {
  __$BlacklistStateCopyWithImpl(this._self, this._then);

  final _BlacklistState _self;
  final $Res Function(_BlacklistState) _then;

/// Create a copy of BlacklistState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? entries = null,}) {
  return _then(_BlacklistState(
entries: null == entries ? _self._entries : entries // ignore: cast_nullable_to_non_nullable
as List<BlacklistEntry>,
  ));
}


}

// dart format on
