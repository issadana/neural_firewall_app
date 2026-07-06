import 'dart:async';

import 'package:injectable/injectable.dart';

/// A tiny broadcast bus that decouples "the session just died" producers from
/// consumers.
///
/// The [RefreshTokenInterceptor] is constructed long before the [AuthCubit]
/// exists and must never hold a direct reference to it (that was the old
/// forward-reference that forced the manual composition root). Instead the
/// interceptor calls [notifyExpired] when it wipes a dead session, and any
/// number of listeners — the [AuthCubit] (drop to sign-in) and the firewall
/// log WebSocket (tear down the authed socket) — react independently.
///
/// Because this depends on nothing, both the producer and the consumers can be
/// registered with the DI container in any order.
@lazySingleton
class SessionEventBus {
  final StreamController<void> _expired = StreamController<void>.broadcast();

  /// Fires once each time a session is invalidated (dead refresh token).
  Stream<void> get onExpired => _expired.stream;

  /// Announce that the session is gone. Safe to call repeatedly.
  void notifyExpired() {
    if (!_expired.isClosed) _expired.add(null);
  }

  @disposeMethod
  void dispose() => _expired.close();
}
