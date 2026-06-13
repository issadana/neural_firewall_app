import 'package:Sentri/core/utils/haptics.dart';
import 'package:flutter/widgets.dart';

class AppPressable extends StatefulWidget {
  const AppPressable({
    super.key,
    required this.child,
    required this.onPressed,
    this.pressedScale = 0.97,
  });

  final Widget child;

  final VoidCallback? onPressed;

  final double pressedScale;

  @override
  State<AppPressable> createState() => _AppPressableState();
}

class _AppPressableState extends State<AppPressable> {
  static const Duration _duration = Duration(milliseconds: 100);
  static const Curve _curve = Curves.easeOut;

  bool _pressed = false;

  bool get _enabled => widget.onPressed != null;

  void _setPressed({required bool value}) {
    if (!_enabled || _pressed == value) return;
    setState(() => _pressed = value);
  }

  void _onTap() {
    if (!_enabled) return;
    HapticsHelper.lightImpact();
    widget.onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _setPressed(value: true),
      onTapUp: (_) => _setPressed(value: false),
      onTapCancel: () => _setPressed(value: false),
      onTap: _onTap,
      child: AnimatedScale(
        scale: _pressed ? widget.pressedScale : 1,
        duration: _duration,
        curve: _curve,
        child: widget.child,
      ),
    );
  }
}
