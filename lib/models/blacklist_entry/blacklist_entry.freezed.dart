// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'blacklist_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BlacklistEntry {

 String get ip; DateTime get addedAt; String get reason; double? get bruteForceScore; double? get dosScore; String? get notes;
/// Create a copy of BlacklistEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BlacklistEntryCopyWith<BlacklistEntry> get copyWith => _$BlacklistEntryCopyWithImpl<BlacklistEntry>(this as BlacklistEntry, _$identity);

  /// Serializes this BlacklistEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BlacklistEntry&&(identical(other.ip, ip) || other.ip == ip)&&(identical(other.addedAt, addedAt) || other.addedAt == addedAt)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.bruteForceScore, bruteForceScore) || other.bruteForceScore == bruteForceScore)&&(identical(other.dosScore, dosScore) || other.dosScore == dosScore)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ip,addedAt,reason,bruteForceScore,dosScore,notes);

@override
String toString() {
  return 'BlacklistEntry(ip: $ip, addedAt: $addedAt, reason: $reason, bruteForceScore: $bruteForceScore, dosScore: $dosScore, notes: $notes)';
}


}

/// @nodoc
abstract mixin class $BlacklistEntryCopyWith<$Res>  {
  factory $BlacklistEntryCopyWith(BlacklistEntry value, $Res Function(BlacklistEntry) _then) = _$BlacklistEntryCopyWithImpl;
@useResult
$Res call({
 String ip, DateTime addedAt, String reason, double? bruteForceScore, double? dosScore, String? notes
});




}
/// @nodoc
class _$BlacklistEntryCopyWithImpl<$Res>
    implements $BlacklistEntryCopyWith<$Res> {
  _$BlacklistEntryCopyWithImpl(this._self, this._then);

  final BlacklistEntry _self;
  final $Res Function(BlacklistEntry) _then;

/// Create a copy of BlacklistEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ip = null,Object? addedAt = null,Object? reason = null,Object? bruteForceScore = freezed,Object? dosScore = freezed,Object? notes = freezed,}) {
  return _then(_self.copyWith(
ip: null == ip ? _self.ip : ip // ignore: cast_nullable_to_non_nullable
as String,addedAt: null == addedAt ? _self.addedAt : addedAt // ignore: cast_nullable_to_non_nullable
as DateTime,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,bruteForceScore: freezed == bruteForceScore ? _self.bruteForceScore : bruteForceScore // ignore: cast_nullable_to_non_nullable
as double?,dosScore: freezed == dosScore ? _self.dosScore : dosScore // ignore: cast_nullable_to_non_nullable
as double?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [BlacklistEntry].
extension BlacklistEntryPatterns on BlacklistEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BlacklistEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BlacklistEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BlacklistEntry value)  $default,){
final _that = this;
switch (_that) {
case _BlacklistEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BlacklistEntry value)?  $default,){
final _that = this;
switch (_that) {
case _BlacklistEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String ip,  DateTime addedAt,  String reason,  double? bruteForceScore,  double? dosScore,  String? notes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BlacklistEntry() when $default != null:
return $default(_that.ip,_that.addedAt,_that.reason,_that.bruteForceScore,_that.dosScore,_that.notes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String ip,  DateTime addedAt,  String reason,  double? bruteForceScore,  double? dosScore,  String? notes)  $default,) {final _that = this;
switch (_that) {
case _BlacklistEntry():
return $default(_that.ip,_that.addedAt,_that.reason,_that.bruteForceScore,_that.dosScore,_that.notes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String ip,  DateTime addedAt,  String reason,  double? bruteForceScore,  double? dosScore,  String? notes)?  $default,) {final _that = this;
switch (_that) {
case _BlacklistEntry() when $default != null:
return $default(_that.ip,_that.addedAt,_that.reason,_that.bruteForceScore,_that.dosScore,_that.notes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BlacklistEntry implements BlacklistEntry {
  const _BlacklistEntry({required this.ip, required this.addedAt, required this.reason, this.bruteForceScore, this.dosScore, this.notes});
  factory _BlacklistEntry.fromJson(Map<String, dynamic> json) => _$BlacklistEntryFromJson(json);

@override final  String ip;
@override final  DateTime addedAt;
@override final  String reason;
@override final  double? bruteForceScore;
@override final  double? dosScore;
@override final  String? notes;

/// Create a copy of BlacklistEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BlacklistEntryCopyWith<_BlacklistEntry> get copyWith => __$BlacklistEntryCopyWithImpl<_BlacklistEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BlacklistEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BlacklistEntry&&(identical(other.ip, ip) || other.ip == ip)&&(identical(other.addedAt, addedAt) || other.addedAt == addedAt)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.bruteForceScore, bruteForceScore) || other.bruteForceScore == bruteForceScore)&&(identical(other.dosScore, dosScore) || other.dosScore == dosScore)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ip,addedAt,reason,bruteForceScore,dosScore,notes);

@override
String toString() {
  return 'BlacklistEntry(ip: $ip, addedAt: $addedAt, reason: $reason, bruteForceScore: $bruteForceScore, dosScore: $dosScore, notes: $notes)';
}


}

/// @nodoc
abstract mixin class _$BlacklistEntryCopyWith<$Res> implements $BlacklistEntryCopyWith<$Res> {
  factory _$BlacklistEntryCopyWith(_BlacklistEntry value, $Res Function(_BlacklistEntry) _then) = __$BlacklistEntryCopyWithImpl;
@override @useResult
$Res call({
 String ip, DateTime addedAt, String reason, double? bruteForceScore, double? dosScore, String? notes
});




}
/// @nodoc
class __$BlacklistEntryCopyWithImpl<$Res>
    implements _$BlacklistEntryCopyWith<$Res> {
  __$BlacklistEntryCopyWithImpl(this._self, this._then);

  final _BlacklistEntry _self;
  final $Res Function(_BlacklistEntry) _then;

/// Create a copy of BlacklistEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ip = null,Object? addedAt = null,Object? reason = null,Object? bruteForceScore = freezed,Object? dosScore = freezed,Object? notes = freezed,}) {
  return _then(_BlacklistEntry(
ip: null == ip ? _self.ip : ip // ignore: cast_nullable_to_non_nullable
as String,addedAt: null == addedAt ? _self.addedAt : addedAt // ignore: cast_nullable_to_non_nullable
as DateTime,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,bruteForceScore: freezed == bruteForceScore ? _self.bruteForceScore : bruteForceScore // ignore: cast_nullable_to_non_nullable
as double?,dosScore: freezed == dosScore ? _self.dosScore : dosScore // ignore: cast_nullable_to_non_nullable
as double?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
