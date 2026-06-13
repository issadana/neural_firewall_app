import 'package:Sentri/core/injection/injection.dart';
import 'package:Sentri/core/services/toast/toast_service.dart';
import 'package:flutter/material.dart';

/// Mounts the app-wide toast [Overlay] just above the router so toasts float
/// over every route, sheet, and dialog and can be shown from anywhere without
/// a [BuildContext]. Wrap the app's content with it inside
/// `MaterialApp.builder`.
class AppToastOverlay extends StatefulWidget {
  const AppToastOverlay({required this.child, super.key});

  final Widget child;

  @override
  State<AppToastOverlay> createState() => _AppToastOverlayState();
}

class _AppToastOverlayState extends State<AppToastOverlay> {
  final GlobalKey<OverlayState> _overlayKey = getIt<ToastService>().overlayKey;
  late final OverlayEntry _appEntry = OverlayEntry(
    builder: (_) => widget.child,
  );

  @override
  void didUpdateWidget(covariant AppToastOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    // `MaterialApp.builder` hands us a fresh child subtree on every rebuild;
    // repaint the hosting entry so the overlay always shows the latest one.
    _appEntry.markNeedsBuild();
  }

  @override
  Widget build(BuildContext context) =>
      Overlay(key: _overlayKey, initialEntries: [_appEntry]);
}
