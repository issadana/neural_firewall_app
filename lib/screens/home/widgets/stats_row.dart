import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../../../blocs/dashboard/dashboard_cubit.dart';
import '../../../blocs/dashboard/dashboard_state.dart';
import '../../../core/theme/app_colors.dart';

class StatsRow extends StatelessWidget {
  const StatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, stats) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            children: [
              Row(
                children: [
                  _StatCard(
                    label: 'Packets',
                    value: stats.packetsAnalyzed.toString(),
                    subtitle: 'Analyzed',
                    icon: Icons.analytics_rounded,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 12),
                  _StatCard(
                    label: 'Blocked',
                    value: stats.ipsBlacklisted.toString(),
                    subtitle: 'Auto-blocked IPs',
                    icon: Icons.block_rounded,
                    color: AppColors.statusDanger,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _ThreatGaugeCard(threatPercent: stats.maxThreatPercent),
            ],
          ),
        );
      },
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surfaceLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.borderColor, width: 0.5),
          boxShadow: colors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 17, color: color),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: color,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
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

    final levelLabel = pct >= 0.20 ? 'HIGH' : pct >= 0.10 ? 'MEDIUM' : 'LOW';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.borderColor, width: 0.5),
        boxShadow: colors.cardShadow,
      ),
      child: Row(
        children: [
          CircularPercentIndicator(
            radius: 34,
            lineWidth: 5,
            percent: pct,
            center: Text(
              '${threatPercent.toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            progressColor: color,
            backgroundColor: colors.borderColor,
            circularStrokeCap: CircularStrokeCap.round,
            animation: true,
            animationDuration: 600,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.security_rounded, size: 14, color: color),
                    const SizedBox(width: 6),
                    Text(
                      'THREAT LEVEL',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: colors.textMuted,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    levelLabel,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: color,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Highest score detected',
                  style: TextStyle(fontSize: 12, color: colors.textDisabled),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
