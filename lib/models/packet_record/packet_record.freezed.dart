// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'packet_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PacketRecord {

 String get id; String get srcIp; int get srcPort; String get dstIp; int get dstPort; Protocol get protocol; PacketStatus get status; int get sizeBytes; double get bruteForceScore; double get dosScore; DateTime get timestamp; bool get isBlacklisted; bool get isAclBlocked;
/// Create a copy of PacketRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PacketRecordCopyWith<PacketRecord> get copyWith => _$PacketRecordCopyWithImpl<PacketRecord>(this as PacketRecord, _$identity);

  /// Serializes this PacketRecord to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PacketRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.srcIp, srcIp) || other.srcIp == srcIp)&&(identical(other.srcPort, srcPort) || other.srcPort == srcPort)&&(identical(other.dstIp, dstIp) || other.dstIp == dstIp)&&(identical(other.dstPort, dstPort) || other.dstPort == dstPort)&&(identical(other.protocol, protocol) || other.protocol == protocol)&&(identical(other.status, status) || other.status == status)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes)&&(identical(other.bruteForceScore, bruteForceScore) || other.bruteForceScore == bruteForceScore)&&(identical(other.dosScore, dosScore) || other.dosScore == dosScore)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.isBlacklisted, isBlacklisted) || other.isBlacklisted == isBlacklisted)&&(identical(other.isAclBlocked, isAclBlocked) || other.isAclBlocked == isAclBlocked));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,srcIp,srcPort,dstIp,dstPort,protocol,status,sizeBytes,bruteForceScore,dosScore,timestamp,isBlacklisted,isAclBlocked);

@override
String toString() {
  return 'PacketRecord(id: $id, srcIp: $srcIp, srcPort: $srcPort, dstIp: $dstIp, dstPort: $dstPort, protocol: $protocol, status: $status, sizeBytes: $sizeBytes, bruteForceScore: $bruteForceScore, dosScore: $dosScore, timestamp: $timestamp, isBlacklisted: $isBlacklisted, isAclBlocked: $isAclBlocked)';
}


}

/// @nodoc
abstract mixin class $PacketRecordCopyWith<$Res>  {
  factory $PacketRecordCopyWith(PacketRecord value, $Res Function(PacketRecord) _then) = _$PacketRecordCopyWithImpl;
@useResult
$Res call({
 String id, String srcIp, int srcPort, String dstIp, int dstPort, Protocol protocol, PacketStatus status, int sizeBytes, double bruteForceScore, double dosScore, DateTime timestamp, bool isBlacklisted, bool isAclBlocked
});




}
/// @nodoc
class _$PacketRecordCopyWithImpl<$Res>
    implements $PacketRecordCopyWith<$Res> {
  _$PacketRecordCopyWithImpl(this._self, this._then);

  final PacketRecord _self;
  final $Res Function(PacketRecord) _then;

/// Create a copy of PacketRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? srcIp = null,Object? srcPort = null,Object? dstIp = null,Object? dstPort = null,Object? protocol = null,Object? status = null,Object? sizeBytes = null,Object? bruteForceScore = null,Object? dosScore = null,Object? timestamp = null,Object? isBlacklisted = null,Object? isAclBlocked = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,srcIp: null == srcIp ? _self.srcIp : srcIp // ignore: cast_nullable_to_non_nullable
as String,srcPort: null == srcPort ? _self.srcPort : srcPort // ignore: cast_nullable_to_non_nullable
as int,dstIp: null == dstIp ? _self.dstIp : dstIp // ignore: cast_nullable_to_non_nullable
as String,dstPort: null == dstPort ? _self.dstPort : dstPort // ignore: cast_nullable_to_non_nullable
as int,protocol: null == protocol ? _self.protocol : protocol // ignore: cast_nullable_to_non_nullable
as Protocol,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PacketStatus,sizeBytes: null == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int,bruteForceScore: null == bruteForceScore ? _self.bruteForceScore : bruteForceScore // ignore: cast_nullable_to_non_nullable
as double,dosScore: null == dosScore ? _self.dosScore : dosScore // ignore: cast_nullable_to_non_nullable
as double,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,isBlacklisted: null == isBlacklisted ? _self.isBlacklisted : isBlacklisted // ignore: cast_nullable_to_non_nullable
as bool,isAclBlocked: null == isAclBlocked ? _self.isAclBlocked : isAclBlocked // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PacketRecord].
extension PacketRecordPatterns on PacketRecord {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PacketRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PacketRecord() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PacketRecord value)  $default,){
final _that = this;
switch (_that) {
case _PacketRecord():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PacketRecord value)?  $default,){
final _that = this;
switch (_that) {
case _PacketRecord() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String srcIp,  int srcPort,  String dstIp,  int dstPort,  Protocol protocol,  PacketStatus status,  int sizeBytes,  double bruteForceScore,  double dosScore,  DateTime timestamp,  bool isBlacklisted,  bool isAclBlocked)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PacketRecord() when $default != null:
return $default(_that.id,_that.srcIp,_that.srcPort,_that.dstIp,_that.dstPort,_that.protocol,_that.status,_that.sizeBytes,_that.bruteForceScore,_that.dosScore,_that.timestamp,_that.isBlacklisted,_that.isAclBlocked);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String srcIp,  int srcPort,  String dstIp,  int dstPort,  Protocol protocol,  PacketStatus status,  int sizeBytes,  double bruteForceScore,  double dosScore,  DateTime timestamp,  bool isBlacklisted,  bool isAclBlocked)  $default,) {final _that = this;
switch (_that) {
case _PacketRecord():
return $default(_that.id,_that.srcIp,_that.srcPort,_that.dstIp,_that.dstPort,_that.protocol,_that.status,_that.sizeBytes,_that.bruteForceScore,_that.dosScore,_that.timestamp,_that.isBlacklisted,_that.isAclBlocked);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String srcIp,  int srcPort,  String dstIp,  int dstPort,  Protocol protocol,  PacketStatus status,  int sizeBytes,  double bruteForceScore,  double dosScore,  DateTime timestamp,  bool isBlacklisted,  bool isAclBlocked)?  $default,) {final _that = this;
switch (_that) {
case _PacketRecord() when $default != null:
return $default(_that.id,_that.srcIp,_that.srcPort,_that.dstIp,_that.dstPort,_that.protocol,_that.status,_that.sizeBytes,_that.bruteForceScore,_that.dosScore,_that.timestamp,_that.isBlacklisted,_that.isAclBlocked);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PacketRecord implements PacketRecord {
  const _PacketRecord({required this.id, required this.srcIp, required this.srcPort, required this.dstIp, required this.dstPort, required this.protocol, required this.status, required this.sizeBytes, required this.bruteForceScore, required this.dosScore, required this.timestamp, required this.isBlacklisted, required this.isAclBlocked});
  factory _PacketRecord.fromJson(Map<String, dynamic> json) => _$PacketRecordFromJson(json);

@override final  String id;
@override final  String srcIp;
@override final  int srcPort;
@override final  String dstIp;
@override final  int dstPort;
@override final  Protocol protocol;
@override final  PacketStatus status;
@override final  int sizeBytes;
@override final  double bruteForceScore;
@override final  double dosScore;
@override final  DateTime timestamp;
@override final  bool isBlacklisted;
@override final  bool isAclBlocked;

/// Create a copy of PacketRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PacketRecordCopyWith<_PacketRecord> get copyWith => __$PacketRecordCopyWithImpl<_PacketRecord>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PacketRecordToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PacketRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.srcIp, srcIp) || other.srcIp == srcIp)&&(identical(other.srcPort, srcPort) || other.srcPort == srcPort)&&(identical(other.dstIp, dstIp) || other.dstIp == dstIp)&&(identical(other.dstPort, dstPort) || other.dstPort == dstPort)&&(identical(other.protocol, protocol) || other.protocol == protocol)&&(identical(other.status, status) || other.status == status)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes)&&(identical(other.bruteForceScore, bruteForceScore) || other.bruteForceScore == bruteForceScore)&&(identical(other.dosScore, dosScore) || other.dosScore == dosScore)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.isBlacklisted, isBlacklisted) || other.isBlacklisted == isBlacklisted)&&(identical(other.isAclBlocked, isAclBlocked) || other.isAclBlocked == isAclBlocked));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,srcIp,srcPort,dstIp,dstPort,protocol,status,sizeBytes,bruteForceScore,dosScore,timestamp,isBlacklisted,isAclBlocked);

@override
String toString() {
  return 'PacketRecord(id: $id, srcIp: $srcIp, srcPort: $srcPort, dstIp: $dstIp, dstPort: $dstPort, protocol: $protocol, status: $status, sizeBytes: $sizeBytes, bruteForceScore: $bruteForceScore, dosScore: $dosScore, timestamp: $timestamp, isBlacklisted: $isBlacklisted, isAclBlocked: $isAclBlocked)';
}


}

/// @nodoc
abstract mixin class _$PacketRecordCopyWith<$Res> implements $PacketRecordCopyWith<$Res> {
  factory _$PacketRecordCopyWith(_PacketRecord value, $Res Function(_PacketRecord) _then) = __$PacketRecordCopyWithImpl;
@override @useResult
$Res call({
 String id, String srcIp, int srcPort, String dstIp, int dstPort, Protocol protocol, PacketStatus status, int sizeBytes, double bruteForceScore, double dosScore, DateTime timestamp, bool isBlacklisted, bool isAclBlocked
});




}
/// @nodoc
class __$PacketRecordCopyWithImpl<$Res>
    implements _$PacketRecordCopyWith<$Res> {
  __$PacketRecordCopyWithImpl(this._self, this._then);

  final _PacketRecord _self;
  final $Res Function(_PacketRecord) _then;

/// Create a copy of PacketRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? srcIp = null,Object? srcPort = null,Object? dstIp = null,Object? dstPort = null,Object? protocol = null,Object? status = null,Object? sizeBytes = null,Object? bruteForceScore = null,Object? dosScore = null,Object? timestamp = null,Object? isBlacklisted = null,Object? isAclBlocked = null,}) {
  return _then(_PacketRecord(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,srcIp: null == srcIp ? _self.srcIp : srcIp // ignore: cast_nullable_to_non_nullable
as String,srcPort: null == srcPort ? _self.srcPort : srcPort // ignore: cast_nullable_to_non_nullable
as int,dstIp: null == dstIp ? _self.dstIp : dstIp // ignore: cast_nullable_to_non_nullable
as String,dstPort: null == dstPort ? _self.dstPort : dstPort // ignore: cast_nullable_to_non_nullable
as int,protocol: null == protocol ? _self.protocol : protocol // ignore: cast_nullable_to_non_nullable
as Protocol,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PacketStatus,sizeBytes: null == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int,bruteForceScore: null == bruteForceScore ? _self.bruteForceScore : bruteForceScore // ignore: cast_nullable_to_non_nullable
as double,dosScore: null == dosScore ? _self.dosScore : dosScore // ignore: cast_nullable_to_non_nullable
as double,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,isBlacklisted: null == isBlacklisted ? _self.isBlacklisted : isBlacklisted // ignore: cast_nullable_to_non_nullable
as bool,isAclBlocked: null == isAclBlocked ? _self.isAclBlocked : isAclBlocked // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
