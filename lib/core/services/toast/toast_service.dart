import 'package:Sentri/core/injection/injection.dart';
import 'package:Sentri/core/services/toast/toast_variant.dart';
import 'package:Sentri/core/widgets/toast/app_toast_card.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

/// Default time a toast stays on screen before it auto-dismisses.
const Duration _kDefaultToastDuration = Duration(seconds: 4);

/// Drives the global, context-free toast overlay.
///
/// A single [ToastService] owns the app-wide [Overlay] — its [overlayKey] is
/// mounted once by `AppToastOverlay` in `main.dart`, just above the router —
/// so a toast can be shown from anywhere (BLoC listeners, async callbacks,
/// services) without a [BuildContext]. Toasts are shown one at a time; any
/// that arrive while one is on screen are queued and drained in order.
@lazySingleton
class ToastService {
  final GlobalKey<OverlayState> overlayKey = GlobalKey<OverlayState>();

  final List<_ToastRequest> _queue = <_ToastRequest>[];
  OverlayEntry? _current;

  void info(String message, {String? title, Duration? duration}) =>
      _enqueue(ToastVariant.info, message, title, duration);

  void success(String message, {String? title, Duration? duration}) =>
      _enqueue(ToastVariant.success, message, title, duration);

  void warning(String message, {String? title, Duration? duration}) =>
      _enqueue(ToastVariant.warning, message, title, duration);

  void error(String message, {String? title, Duration? duration}) =>
      _enqueue(ToastVariant.error, message, title, duration);

  void _enqueue(
    ToastVariant variant,
    String message,
    String? title,
    Duration? duration,
  ) {
    _queue.add(
      _ToastRequest(
        variant: variant,
        message: message,
        title: title,
        duration: duration ?? _kDefaultToastDuration,
      ),
    );
    _pump();
  }

  void _pump() {
    if (_current != null || _queue.isEmpty) return;
    final overlay = overlayKey.currentState;
    // No overlay mounted yet (e.g. toast fired before first frame) — leave the
    // request queued; the next _pump() drains it once the overlay exists.
    if (overlay == null) return;

    final request = _queue.removeAt(0);
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => AppToastCard(
        variant: request.variant,
        title: request.title,
        message: request.message,
        duration: request.duration,
        onDismissed: () {
          entry.remove();
          _current = null;
          _pump();
        },
      ),
    );
    _current = entry;
    overlay.insert(entry);
  }
}

class _ToastRequest {
  const _ToastRequest({
    required this.variant,
    required this.message,
    required this.title,
    required this.duration,
  });

  final ToastVariant variant;
  final String message;
  final String? title;
  final Duration duration;
}

/// Ergonomic, context-free facade over [ToastService]. Call from anywhere:
///
/// ```dart
/// AppToast.error(NetworkExceptions.getErrorMessage(error));
/// AppToast.success(l10n.changesSaved, title: l10n.allDone);
/// ```
class AppToast {
  AppToast._();

  static ToastService get _service => getIt<ToastService>();

  static void info(String message, {String? title, Duration? duration}) =>
      _service.info(message, title: title, duration: duration);

  static void success(String message, {String? title, Duration? duration}) =>
      _service.success(message, title: title, duration: duration);

  static void warning(String message, {String? title, Duration? duration}) =>
      _service.warning(message, title: title, duration: duration);

  static void error(String message, {String? title, Duration? duration}) =>
      _service.error(message, title: title, duration: duration);
}
