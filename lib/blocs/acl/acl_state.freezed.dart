// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'acl_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AclState {

 List<AclEntry> get entries;
/// Create a copy of AclState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AclStateCopyWith<AclState> get copyWith => _$AclStateCopyWithImpl<AclState>(this as AclState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AclState&&const DeepCollectionEquality().equals(other.entries, entries));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(entries));

@override
String toString() {
  return 'AclState(entries: $entries)';
}


}

/// @nodoc
abstract mixin class $AclStateCopyWith<$Res>  {
  factory $AclStateCopyWith(AclState value, $Res Function(AclState) _then) = _$AclStateCopyWithImpl;
@useResult
$Res call({
 List<AclEntry> entries
});




}
/// @nodoc
class _$AclStateCopyWithImpl<$Res>
    implements $AclStateCopyWith<$Res> {
  _$AclStateCopyWithImpl(this._self, this._then);

  final AclState _self;
  final $Res Function(AclState) _then;

/// Create a copy of AclState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? entries = null,}) {
  return _then(_self.copyWith(
entries: null == entries ? _self.entries : entries // ignore: cast_nullable_to_non_nullable
as List<AclEntry>,
  ));
}

}


/// Adds pattern-matching-related methods to [AclState].
extension AclStatePatterns on AclState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AclState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AclState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AclState value)  $default,){
final _that = this;
switch (_that) {
case _AclState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AclState value)?  $default,){
final _that = this;
switch (_that) {
case _AclState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<AclEntry> entries)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AclState() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<AclEntry> entries)  $default,) {final _that = this;
switch (_that) {
case _AclState():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<AclEntry> entries)?  $default,) {final _that = this;
switch (_that) {
case _AclState() when $default != null:
return $default(_that.entries);case _:
  return null;

}
}

}

/// @nodoc


class _AclState implements AclState {
  const _AclState({required final  List<AclEntry> entries}): _entries = entries;
  

 final  List<AclEntry> _entries;
@override List<AclEntry> get entries {
  if (_entries is EqualUnmodifiableListView) return _entries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_entries);
}


/// Create a copy of AclState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AclStateCopyWith<_AclState> get copyWith => __$AclStateCopyWithImpl<_AclState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AclState&&const DeepCollectionEquality().equals(other._entries, _entries));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_entries));

@override
String toString() {
  return 'AclState(entries: $entries)';
}


}

/// @nodoc
abstract mixin class _$AclStateCopyWith<$Res> implements $AclStateCopyWith<$Res> {
  factory _$AclStateCopyWith(_AclState value, $Res Function(_AclState) _then) = __$AclStateCopyWithImpl;
@override @useResult
$Res call({
 List<AclEntry> entries
});




}
/// @nodoc
class __$AclStateCopyWithImpl<$Res>
    implements _$AclStateCopyWith<$Res> {
  __$AclStateCopyWithImpl(this._self, this._then);

  final _AclState _self;
  final $Res Function(_AclState) _then;

/// Create a copy of AclState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? entries = null,}) {
  return _then(_AclState(
entries: null == entries ? _self._entries : entries // ignore: cast_nullable_to_non_nullable
as List<AclEntry>,
  ));
}


}

// dart format on
