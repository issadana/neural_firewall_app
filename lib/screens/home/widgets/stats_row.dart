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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StatCard(
                    label: 'PACKETS',
                    value: stats.packetsAnalyzed.toString(),
                    subtitle: 'Analyzed',
                    icon: Icons.analytics_outlined,
                    color: AppColors.accentBlue,
                  ),
                  const SizedBox(width: 8),
                  _StatCard(
                    label: 'BLACKLISTED',
                    value: stats.ipsBlacklisted.toString(),
                    subtitle: 'Auto-blocked',
                    icon: Icons.block_outlined,
                    color: AppColors.statusDanger,
                  ),
                ],
              ),
              const SizedBox(height: 15),
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
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary,
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
    final pct = (threatPercent / 100).clamp(0.0, 1.0);
    final color = pct >= 0.20
        ? AppColors.statusDanger
        : pct >= 0.10
            ? AppColors.statusWarning
            : AppColors.statusNormal;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.security_outlined, size: 14, color: color),
                const SizedBox(width: 4),
                Text(
                  'MAX THREAT',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Center(
              child: CircularPercentIndicator(
                radius: 28,
                lineWidth: 4,
                percent: pct,
                center: Text(
                  '${threatPercent.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                progressColor: color,
                backgroundColor: AppColors.borderColor,
                circularStrokeCap: CircularStrokeCap.round,
              ),
            ),
            const Center(
              child: Text(
                'Highest detected',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
    );
  }
}
