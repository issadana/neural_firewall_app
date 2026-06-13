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
            children: [
              Expanded(
                child: _Stat(
                  icon: Icons.memory,
                  label: 'CPU',
                  value: s != null ? '${s.cpuUsage.toStringAsFixed(1)}%' : '--',
                  color: _cpuColor(s?.cpuUsage ?? 0),
                ),
              ),
              _Divider(),
              Expanded(
                child: _Stat(
                  icon: Icons.storage,
                  label: 'RAM',
                  value: s != null ? '${s.ramUsedPercent.toStringAsFixed(0)}%' : '--',
                  subtitle: s != null ? '${s.ramUsedMb} / ${s.ramTotalMb} MB' : null,
                  color: _ramColor(s?.ramUsedPercent ?? 0),
                ),
              ),
              if (s?.batteryLevel != null) ...[
                _Divider(),
                Expanded(
                  child: _Stat(
                    icon: Icons.battery_std,
                    label: 'Battery',
                    value: '${s!.batteryLevel!.toStringAsFixed(0)}%',
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
  final Color color;

  const _Stat({
    required this.icon,
    required this.label,
    required this.value,
    this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        SpacesManager.h6,
        Text(value,
            style: getBoldTextStyle(fontSize: FontSizesManager.s16, color: color)),
        if (subtitle != null)
          Text(subtitle!,
              style: getRegularTextStyle(fontSize: FontSizesManager.s10, color: colors.textDisabled)),
        SpacesManager.h2,
        Text(label, style: getRegularTextStyle(fontSize: FontSizesManager.s11, color: colors.textMuted)),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 0.5,
      height: 50,
      margin: PaddingManager.paddingHorizontal8,
      color: context.appColors.borderColor,
    );
  }
}
