// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'traffic_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TrafficEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrafficEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TrafficEvent()';
}


}

/// @nodoc
class $TrafficEventCopyWith<$Res>  {
$TrafficEventCopyWith(TrafficEvent _, $Res Function(TrafficEvent) __);
}


/// Adds pattern-matching-related methods to [TrafficEvent].
extension TrafficEventPatterns on TrafficEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( PacketReceivedEvent value)?  packetReceived,TResult Function( ClearLogsEvent value)?  clearLogs,TResult Function( StartListeningEvent value)?  startListening,TResult Function( StopListeningEvent value)?  stopListening,required TResult orElse(),}){
final _that = this;
switch (_that) {
case PacketReceivedEvent() when packetReceived != null:
return packetReceived(_that);case ClearLogsEvent() when clearLogs != null:
return clearLogs(_that);case StartListeningEvent() when startListening != null:
return startListening(_that);case StopListeningEvent() when stopListening != null:
return stopListening(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( PacketReceivedEvent value)  packetReceived,required TResult Function( ClearLogsEvent value)  clearLogs,required TResult Function( StartListeningEvent value)  startListening,required TResult Function( StopListeningEvent value)  stopListening,}){
final _that = this;
switch (_that) {
case PacketReceivedEvent():
return packetReceived(_that);case ClearLogsEvent():
return clearLogs(_that);case StartListeningEvent():
return startListening(_that);case StopListeningEvent():
return stopListening(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( PacketReceivedEvent value)?  packetReceived,TResult? Function( ClearLogsEvent value)?  clearLogs,TResult? Function( StartListeningEvent value)?  startListening,TResult? Function( StopListeningEvent value)?  stopListening,}){
final _that = this;
switch (_that) {
case PacketReceivedEvent() when packetReceived != null:
return packetReceived(_that);case ClearLogsEvent() when clearLogs != null:
return clearLogs(_that);case StartListeningEvent() when startListening != null:
return startListening(_that);case StopListeningEvent() when stopListening != null:
return stopListening(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( Map<String, dynamic> rawPacket)?  packetReceived,TResult Function()?  clearLogs,TResult Function()?  startListening,TResult Function()?  stopListening,required TResult orElse(),}) {final _that = this;
switch (_that) {
case PacketReceivedEvent() when packetReceived != null:
return packetReceived(_that.rawPacket);case ClearLogsEvent() when clearLogs != null:
return clearLogs();case StartListeningEvent() when startListening != null:
return startListening();case StopListeningEvent() when stopListening != null:
return stopListening();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( Map<String, dynamic> rawPacket)  packetReceived,required TResult Function()  clearLogs,required TResult Function()  startListening,required TResult Function()  stopListening,}) {final _that = this;
switch (_that) {
case PacketReceivedEvent():
return packetReceived(_that.rawPacket);case ClearLogsEvent():
return clearLogs();case StartListeningEvent():
return startListening();case StopListeningEvent():
return stopListening();case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( Map<String, dynamic> rawPacket)?  packetReceived,TResult? Function()?  clearLogs,TResult? Function()?  startListening,TResult? Function()?  stopListening,}) {final _that = this;
switch (_that) {
case PacketReceivedEvent() when packetReceived != null:
return packetReceived(_that.rawPacket);case ClearLogsEvent() when clearLogs != null:
return clearLogs();case StartListeningEvent() when startListening != null:
return startListening();case StopListeningEvent() when stopListening != null:
return stopListening();case _:
  return null;

}
}

}

/// @nodoc


class PacketReceivedEvent implements TrafficEvent {
  const PacketReceivedEvent(final  Map<String, dynamic> rawPacket): _rawPacket = rawPacket;
  

 final  Map<String, dynamic> _rawPacket;
 Map<String, dynamic> get rawPacket {
  if (_rawPacket is EqualUnmodifiableMapView) return _rawPacket;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_rawPacket);
}


/// Create a copy of TrafficEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PacketReceivedEventCopyWith<PacketReceivedEvent> get copyWith => _$PacketReceivedEventCopyWithImpl<PacketReceivedEvent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PacketReceivedEvent&&const DeepCollectionEquality().equals(other._rawPacket, _rawPacket));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_rawPacket));

@override
String toString() {
  return 'TrafficEvent.packetReceived(rawPacket: $rawPacket)';
}


}

/// @nodoc
abstract mixin class $PacketReceivedEventCopyWith<$Res> implements $TrafficEventCopyWith<$Res> {
  factory $PacketReceivedEventCopyWith(PacketReceivedEvent value, $Res Function(PacketReceivedEvent) _then) = _$PacketReceivedEventCopyWithImpl;
@useResult
$Res call({
 Map<String, dynamic> rawPacket
});




}
/// @nodoc
class _$PacketReceivedEventCopyWithImpl<$Res>
    implements $PacketReceivedEventCopyWith<$Res> {
  _$PacketReceivedEventCopyWithImpl(this._self, this._then);

  final PacketReceivedEvent _self;
  final $Res Function(PacketReceivedEvent) _then;

/// Create a copy of TrafficEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? rawPacket = null,}) {
  return _then(PacketReceivedEvent(
null == rawPacket ? _self._rawPacket : rawPacket // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}

/// @nodoc


class ClearLogsEvent implements TrafficEvent {
  const ClearLogsEvent();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClearLogsEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TrafficEvent.clearLogs()';
}


}




/// @nodoc


class StartListeningEvent implements TrafficEvent {
  const StartListeningEvent();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StartListeningEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TrafficEvent.startListening()';
}


}




/// @nodoc


class StopListeningEvent implements TrafficEvent {
  const StopListeningEvent();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StopListeningEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TrafficEvent.stopListening()';
}


}




// dart format on
