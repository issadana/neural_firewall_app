import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:percent_indicator/percent_indicator.dart';

import 'package:Sentri/core/resources/border_radius_manager.dart';
import 'package:Sentri/core/resources/decoration_manager.dart';
import 'package:Sentri/core/resources/font_manager.dart';
import 'package:Sentri/core/resources/padding_manager.dart';
import 'package:Sentri/core/resources/spaces_manager.dart';
import 'package:Sentri/core/resources/text_style_manager.dart';
import 'package:Sentri/core/theme/app_colors.dart';
import 'package:Sentri/features/dashboard/presentation/bloc/dashboard_cubit.dart';

/// Home view: the two headline metrics as large stat cards.
class StatsRow extends StatelessWidget {
  const StatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, stats) {
        return Padding(
          padding: PaddingManager.paddingLTRB16_16_16_8,
          child: Row(
            children: [
              _StatCard(
                label: 'Packets',
                value: stats.packetsAnalyzed.toString(),
                subtitle: 'Analyzed',
                icon: Icons.analytics_rounded,
                color: AppColors.primary,
              ),
              SpacesManager.w12,
              _StatCard(
                label: 'Blocked',
                value: stats.ipsBlacklisted.toString(),
                subtitle: 'Auto-blocked IPs',
                icon: Icons.block_rounded,
                color: AppColors.statusDanger,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Analytics view: the same two metrics as compact horizontal tiles, followed
/// by the threat-level gauge.
class AnalyticsStats extends StatelessWidget {
  const AnalyticsStats({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, stats) {
        return Padding(
          padding: PaddingManager.paddingLTRB16_16_16_8,
          child: Column(
            children: [
              Row(
                children: [
                  _MiniStat(
                    label: 'Packets Analyzed',
                    value: stats.packetsAnalyzed.toString(),
                    icon: Icons.analytics_rounded,
                    color: AppColors.primary,
                  ),
                  SpacesManager.w12,
                  _MiniStat(
                    label: 'Auto-blocked IPs',
                    value: stats.ipsBlacklisted.toString(),
                    icon: Icons.block_rounded,
                    color: AppColors.statusDanger,
                  ),
                ],
              ),
              SpacesManager.h12,
              _ThreatGaugeCard(threatPercent: stats.maxThreatPercent),
            ],
          ),
        );
      },
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Expanded(
      child: Container(
        padding: PaddingManager.paddingH14V10,
        decoration: DecorationManager.surfaceCard(
          colors,
          radius: BorderRadiusManager.radiusAll16,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: DecorationManager.tinted(
                color,
                BorderRadiusManager.radiusAll10,
                alpha: 0.15,
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            SpacesManager.w10,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    value,
                    style: getBoldTextStyle(
                      fontSize: FontSizesManager.s18,
                      color: colors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SpacesManager.h2,
                  Text(
                    label,
                    style: getRegularTextStyle(
                      fontSize: FontSizesManager.s11,
                      color: colors.textDisabled,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Expanded(
      child: Container(
        padding: PaddingManager.paddingAll16,
        decoration: DecorationManager.surfaceCard(
          colors,
          radius: BorderRadiusManager.radiusAll20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: DecorationManager.tinted(
                    color,
                    BorderRadiusManager.radiusAll10,
                    alpha: 0.15,
                  ),
                  child: Icon(icon, size: 17, color: color),
                ),
                const Spacer(),
                Container(
                  padding: PaddingManager.paddingH8V2,
                  decoration: DecorationManager.tinted(
                    color,
                    BorderRadiusManager.radiusAll20,
                    alpha: 0.10,
                  ),
                  child: Text(
                    label,
                    style: getBoldTextStyle(
                      fontSize: FontSizesManager.s10,
                      color: color,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ],
            ),
            SpacesManager.h12,
            Text(
              value,
              style: getBoldTextStyle(
                fontSize: FontSizesManager.s28,
                color: colors.textPrimary,
                letterSpacing: -1,
              ),
            ),
            SpacesManager.h2,
            Text(
              subtitle,
              style: getRegularTextStyle(
                fontSize: FontSizesManager.s12,
                color: colors.textDisabled,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThreatGaugeCard extends StatelessWidget {
  final double threatPercent;

  const _ThreatGaugeCard({required this.threatPercent});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final pct = (threatPercent / 100).clamp(0.0, 1.0);
    final color = pct >= 0.20
        ? AppColors.statusDanger
        : pct >= 0.10
        ? AppColors.statusWarning
        : AppColors.accent;

    final levelLabel = pct >= 0.20
        ? 'HIGH'
        : pct >= 0.10
        ? 'MEDIUM'
        : 'LOW';

    return Container(
      width: double.infinity,
      padding: PaddingManager.paddingAll16,
      decoration: DecorationManager.surfaceCard(
        colors,
        radius: BorderRadiusManager.radiusAll20,
      ),
      child: Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: AppColors.glowShadow(color),
            ),
            child: CircularPercentIndicator(
              radius: 34,
              lineWidth: 5,
              percent: pct,
              center: Text(
                '${threatPercent.toStringAsFixed(0)}%',
                style: getBoldTextStyle(
                  fontSize: FontSizesManager.s12,
                  color: color,
                ),
              ),
              progressColor: color,
              backgroundColor: colors.borderColor,
              circularStrokeCap: CircularStrokeCap.round,
              animation: true,
              animationDuration: 600,
            ),
          ),
          SpacesManager.w16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.security_rounded, size: 14, color: color),
                    SpacesManager.w6,
                    Text(
                      'THREAT LEVEL',
                      style: getBoldTextStyle(
                        fontSize: FontSizesManager.s11,
                        color: colors.textMuted,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                SpacesManager.h6,
                Container(
                  padding: PaddingManager.paddingH10V3,
                  decoration: DecorationManager.tinted(
                    color,
                    BorderRadiusManager.radiusAll20,
                  ),
                  child: Text(
                    levelLabel,
                    style: getBoldTextStyle(
                      fontSize: FontSizesManager.s13,
                      color: color,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                SpacesManager.h4,
                Text(
                  'Highest score detected',
                  style: getRegularTextStyle(
                    fontSize: FontSizesManager.s12,
                    color: colors.textDisabled,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
