// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'acl_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AclEntry {

 String get ip; DateTime get addedAt; String? get notes;
/// Create a copy of AclEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AclEntryCopyWith<AclEntry> get copyWith => _$AclEntryCopyWithImpl<AclEntry>(this as AclEntry, _$identity);

  /// Serializes this AclEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AclEntry&&(identical(other.ip, ip) || other.ip == ip)&&(identical(other.addedAt, addedAt) || other.addedAt == addedAt)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ip,addedAt,notes);

@override
String toString() {
  return 'AclEntry(ip: $ip, addedAt: $addedAt, notes: $notes)';
}


}

/// @nodoc
abstract mixin class $AclEntryCopyWith<$Res>  {
  factory $AclEntryCopyWith(AclEntry value, $Res Function(AclEntry) _then) = _$AclEntryCopyWithImpl;
@useResult
$Res call({
 String ip, DateTime addedAt, String? notes
});




}
/// @nodoc
class _$AclEntryCopyWithImpl<$Res>
    implements $AclEntryCopyWith<$Res> {
  _$AclEntryCopyWithImpl(this._self, this._then);

  final AclEntry _self;
  final $Res Function(AclEntry) _then;

/// Create a copy of AclEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ip = null,Object? addedAt = null,Object? notes = freezed,}) {
  return _then(_self.copyWith(
ip: null == ip ? _self.ip : ip // ignore: cast_nullable_to_non_nullable
as String,addedAt: null == addedAt ? _self.addedAt : addedAt // ignore: cast_nullable_to_non_nullable
as DateTime,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AclEntry].
extension AclEntryPatterns on AclEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AclEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AclEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AclEntry value)  $default,){
final _that = this;
switch (_that) {
case _AclEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AclEntry value)?  $default,){
final _that = this;
switch (_that) {
case _AclEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String ip,  DateTime addedAt,  String? notes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AclEntry() when $default != null:
return $default(_that.ip,_that.addedAt,_that.notes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String ip,  DateTime addedAt,  String? notes)  $default,) {final _that = this;
switch (_that) {
case _AclEntry():
return $default(_that.ip,_that.addedAt,_that.notes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String ip,  DateTime addedAt,  String? notes)?  $default,) {final _that = this;
switch (_that) {
case _AclEntry() when $default != null:
return $default(_that.ip,_that.addedAt,_that.notes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AclEntry implements AclEntry {
  const _AclEntry({required this.ip, required this.addedAt, this.notes});
  factory _AclEntry.fromJson(Map<String, dynamic> json) => _$AclEntryFromJson(json);

@override final  String ip;
@override final  DateTime addedAt;
@override final  String? notes;

/// Create a copy of AclEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AclEntryCopyWith<_AclEntry> get copyWith => __$AclEntryCopyWithImpl<_AclEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AclEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AclEntry&&(identical(other.ip, ip) || other.ip == ip)&&(identical(other.addedAt, addedAt) || other.addedAt == addedAt)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ip,addedAt,notes);

@override
String toString() {
  return 'AclEntry(ip: $ip, addedAt: $addedAt, notes: $notes)';
}


}

/// @nodoc
abstract mixin class _$AclEntryCopyWith<$Res> implements $AclEntryCopyWith<$Res> {
  factory _$AclEntryCopyWith(_AclEntry value, $Res Function(_AclEntry) _then) = __$AclEntryCopyWithImpl;
@override @useResult
$Res call({
 String ip, DateTime addedAt, String? notes
});




}
/// @nodoc
class __$AclEntryCopyWithImpl<$Res>
    implements _$AclEntryCopyWith<$Res> {
  __$AclEntryCopyWithImpl(this._self, this._then);

  final _AclEntry _self;
  final $Res Function(_AclEntry) _then;

/// Create a copy of AclEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ip = null,Object? addedAt = null,Object? notes = freezed,}) {
  return _then(_AclEntry(
ip: null == ip ? _self.ip : ip // ignore: cast_nullable_to_non_nullable
as String,addedAt: null == addedAt ? _self.addedAt : addedAt // ignore: cast_nullable_to_non_nullable
as DateTime,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
