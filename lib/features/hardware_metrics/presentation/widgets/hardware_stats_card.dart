import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Sentri/core/resources/border_radius_manager.dart';
import 'package:Sentri/core/resources/decoration_manager.dart';
import 'package:Sentri/core/resources/font_manager.dart';
import 'package:Sentri/core/resources/padding_manager.dart';
import 'package:Sentri/core/resources/spaces_manager.dart';
import 'package:Sentri/core/resources/text_style_manager.dart';
import 'package:Sentri/core/theme/app_colors.dart';
import '../bloc/hardware_metrics_cubit.dart';

class HardwareStatsCard extends StatelessWidget {
  const HardwareStatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HardwareMetricsCubit, HardwareMetricsState>(
      builder: (context, state) {
        final s = state.latest;
        return Container(
          margin: PaddingManager.paddingH16V8,
          padding: PaddingManager.paddingAll16,
          decoration: DecorationManager.surfaceCard(
            context.appColors,
            radius: BorderRadiusManager.radiusAll20,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _Stat(
                  icon: Icons.memory,
                  label: 'CPU',
                  value: s != null ? '${s.cpuUsage.toStringAsFixed(1)}%' : '--',
                  progress: s != null ? s.cpuUsage / 100 : null,
                  color: _cpuColor(s?.cpuUsage ?? 0),
                ),
              ),
              SpacesManager.w12,
              Expanded(
                child: _Stat(
                  icon: Icons.storage,
                  label: 'RAM',
                  value:
                      s != null ? '${s.ramUsedPercent.toStringAsFixed(0)}%' : '--',
                  subtitle:
                      s != null ? '${s.ramUsedMb} / ${s.ramTotalMb} MB' : null,
                  progress: s != null ? s.ramUsedPercent / 100 : null,
                  color: _ramColor(s?.ramUsedPercent ?? 0),
                ),
              ),
              if (s?.batteryLevel != null) ...[
                SpacesManager.w12,
                Expanded(
                  child: _Stat(
                    icon: Icons.battery_std,
                    label: 'Battery',
                    value: '${s!.batteryLevel!.toStringAsFixed(0)}%',
                    progress: s.batteryLevel! / 100,
                    color: _batteryColor(s.batteryLevel!),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Color _cpuColor(double v) {
    if (v > 80) return AppColors.statusDanger;
    if (v > 50) return AppColors.statusWarning;
    return AppColors.statusNormal;
  }

  Color _ramColor(double v) {
    if (v > 85) return AppColors.statusDanger;
    if (v > 65) return AppColors.statusWarning;
    return AppColors.statusNormal;
  }

  Color _batteryColor(double v) {
    if (v < 15) return AppColors.statusDanger;
    if (v < 30) return AppColors.statusWarning;
    return AppColors.statusNormal;
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? subtitle;
  final double? progress;
  final Color color;

  const _Stat({
    required this.icon,
    required this.label,
    required this.value,
    this.subtitle,
    this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: DecorationManager.tinted(
                color,
                BorderRadiusManager.radiusAll10,
                alpha: 0.14,
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            SpacesManager.w8,
            Text(
              label,
              style: getMediumTextStyle(
                fontSize: FontSizesManager.s11,
                color: colors.textMuted,
              ),
            ),
          ],
        ),
        SpacesManager.h10,
        Text(
          value,
          style: getBoldTextStyle(fontSize: FontSizesManager.s18, color: color),
        ),
        if (subtitle != null) ...[
          SpacesManager.h2,
          Text(
            subtitle!,
            style: getRegularTextStyle(
              fontSize: FontSizesManager.s10,
              color: colors.textDisabled,
            ),
          ),
        ],
        SpacesManager.h8,
        if (progress != null)
          ClipRRect(
            borderRadius: BorderRadiusManager.radiusAll4,
            child: LinearProgressIndicator(
              value: progress!.clamp(0.0, 1.0),
              minHeight: 4,
              backgroundColor: color.withValues(alpha: 0.14),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
      ],
    );
  }
}
