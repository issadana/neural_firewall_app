import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:Sentri/core/theme/app_colors.dart';

/// Ambient auth backdrop: the theme gradient with two softly-breathing colour
/// orbs behind the content for a modern, alive feel. Purely decorative.
class AuthBackground extends StatelessWidget {
  final Widget child;
  const AuthBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return DecoratedBox(
      decoration: BoxDecoration(gradient: colors.authBackground),
      child: Stack(
        children: [
          Positioned(
            top: -110,
            left: -90,
            child: _Orb(color: AppColors.primary, size: 290, period: 4600),
          ),
          Positioned(
            bottom: -150,
            right: -110,
            child: _Orb(color: AppColors.accent, size: 340, period: 5400),
          ),
          child,
        ],
      ),
    );
  }
}

class _Orb extends StatelessWidget {
  final Color color;
  final double size;
  final int period;
  const _Orb({required this.color, required this.size, required this.period});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child:
          Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      color.withValues(alpha: 0.20),
                      color.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scaleXY(
                begin: 0.9,
                end: 1.12,
                duration: period.ms,
                curve: Curves.easeInOut,
              )
              .fade(
                begin: 0.55,
                end: 1.0,
                duration: period.ms,
                curve: Curves.easeInOut,
              ),
    );
  }
}
