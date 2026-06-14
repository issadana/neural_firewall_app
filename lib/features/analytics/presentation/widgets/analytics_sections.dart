import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:Sentri/core/enums.dart';
import 'package:Sentri/core/resources/border_radius_manager.dart';
import 'package:Sentri/core/resources/decoration_manager.dart';
import 'package:Sentri/core/resources/font_manager.dart';
import 'package:Sentri/core/resources/padding_manager.dart';
import 'package:Sentri/core/resources/spaces_manager.dart';
import 'package:Sentri/core/resources/text_style_manager.dart';
import 'package:Sentri/core/theme/app_colors.dart';
import 'package:Sentri/features/dashboard/presentation/bloc/dashboard_cubit.dart';
import 'package:Sentri/features/traffic/presentation/bloc/traffic_bloc.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Shared building blocks
// ─────────────────────────────────────────────────────────────────────────────

/// A titled surface card used for every analytics section.
class _SectionCard extends StatelessWidget {
  final String title;
  final Color accent;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.accent,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: double.infinity,
      margin: PaddingManager.paddingLTRB16_0_16_12,
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
                width: 3,
                height: 14,
                decoration: DecorationManager.colorBar(
                  accent,
                  radius: BorderRadiusManager.radiusAll2,
                ),
              ),
              SpacesManager.w8,
              Text(
                title,
                style: getBoldTextStyle(
                  fontSize: FontSizesManager.s11,
                  color: colors.textMuted,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          SpacesManager.h12,
          child,
        ],
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final String message;
  const _EmptyHint(this.message);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: PaddingManager.paddingVertical8,
      child: Text(
        message,
        style: getRegularTextStyle(
          fontSize: FontSizesManager.s12,
          color: context.appColors.textDisabled,
        ),
      ),
    );
  }
}

/// A horizontal progress track filled to [fraction] (0..1) in [color].
class _ProgressBar extends StatelessWidget {
  final double fraction;
  final Color color;

  const _ProgressBar({required this.fraction, required this.color});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return ClipRRect(
      borderRadius: BorderRadiusManager.radiusAll99,
      child: Container(
        height: 8,
        color: colors.borderColor,
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: fraction.clamp(0.0, 1.0),
          child: DecoratedBox(
            decoration: BoxDecoration(color: color),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 1. Traffic verdict breakdown (Safe / Warn / Blocked)
// ─────────────────────────────────────────────────────────────────────────────

class TrafficBreakdownCard extends StatelessWidget {
  const TrafficBreakdownCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, stats) {
        final safe = stats.safeCount;
        final warn = stats.warnCount;
        final blocked = stats.blockedCount;
        final total = safe + warn + blocked;

        return _SectionCard(
          title: 'TRAFFIC VERDICTS',
          accent: AppColors.primary,
          child: total == 0
              ? const _EmptyHint('No classified traffic yet')
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadiusManager.radiusAll99,
                      child: SizedBox(
                        height: 10,
                        child: Row(
                          children: [
                            if (safe > 0)
                              Expanded(
                                flex: safe,
                                child: ColoredBox(color: AppColors.accent),
                              ),
                            if (warn > 0)
                              Expanded(
                                flex: warn,
                                child: ColoredBox(color: AppColors.statusWarning),
                              ),
                            if (blocked > 0)
                              Expanded(
                                flex: blocked,
                                child: ColoredBox(color: AppColors.statusDanger),
                              ),
                          ],
                        ),
                      ),
                    ),
                    SpacesManager.h12,
                    _LegendRow(
                      color: AppColors.accent,
                      label: 'Safe',
                      count: safe,
                      total: total,
                    ),
                    SpacesManager.h8,
                    _LegendRow(
                      color: AppColors.statusWarning,
                      label: 'Warned',
                      count: warn,
                      total: total,
                    ),
                    SpacesManager.h8,
                    _LegendRow(
                      color: AppColors.statusDanger,
                      label: 'Blocked',
                      count: blocked,
                      total: total,
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;
  final int count;
  final int total;

  const _LegendRow({
    required this.color,
    required this.label,
    required this.count,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final pct = total == 0 ? 0 : (count / total * 100).round();
    return Row(
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: DecorationManager.colorDot(color),
        ),
        SpacesManager.w8,
        Text(
          label,
          style: getMediumTextStyle(
            fontSize: FontSizesManager.s13,
            color: colors.textSecondary,
          ),
        ),
        const Spacer(),
        Text(
          '$count',
          style: getBoldTextStyle(
            fontSize: FontSizesManager.s13,
            color: colors.textPrimary,
          ),
        ),
        SpacesManager.w6,
        Text(
          '· $pct%',
          style: getRegularTextStyle(
            fontSize: FontSizesManager.s12,
            color: colors.textDisabled,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. Threat vectors (avg + peak brute-force vs DoS)
// ─────────────────────────────────────────────────────────────────────────────

class ThreatVectorsCard extends StatelessWidget {
  const ThreatVectorsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TrafficBloc, TrafficState>(
      builder: (context, state) {
        final records = state.records;
        return _SectionCard(
          title: 'THREAT VECTORS',
          accent: AppColors.statusDanger,
          child: records.isEmpty
              ? const _EmptyHint('Start capture to measure threat vectors')
              : Column(
                  children: [
                    _VectorBar(
                      label: 'Brute Force',
                      avg: _avg(records.map((r) => r.bruteForceScore)),
                      peak: records.map((r) => r.bruteForceScore).reduce(max),
                      color: AppColors.statusDanger,
                    ),
                    SpacesManager.h16,
                    _VectorBar(
                      label: 'DoS / Flood',
                      avg: _avg(records.map((r) => r.dosScore)),
                      peak: records.map((r) => r.dosScore).reduce(max),
                      color: AppColors.statusWarning,
                    ),
                  ],
                ),
        );
      },
    );
  }

  double _avg(Iterable<double> values) {
    if (values.isEmpty) return 0;
    return values.reduce((a, b) => a + b) / values.length;
  }
}

class _VectorBar extends StatelessWidget {
  final String label;
  final double avg;
  final double peak;
  final Color color;

  const _VectorBar({
    required this.label,
    required this.avg,
    required this.peak,
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
            Text(
              label,
              style: getMediumTextStyle(
                fontSize: FontSizesManager.s13,
                color: colors.textSecondary,
              ),
            ),
            const Spacer(),
            Text(
              'avg ${(avg * 100).toStringAsFixed(0)}%',
              style: getBoldTextStyle(
                fontSize: FontSizesManager.s12,
                color: color,
              ),
            ),
            SpacesManager.w8,
            Text(
              'peak ${(peak * 100).toStringAsFixed(0)}%',
              style: getRegularTextStyle(
                fontSize: FontSizesManager.s11,
                color: colors.textDisabled,
              ),
            ),
          ],
        ),
        SpacesManager.h6,
        _ProgressBar(fraction: avg, color: color),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. Top talking source IPs
// ─────────────────────────────────────────────────────────────────────────────

class TopSourcesCard extends StatelessWidget {
  const TopSourcesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TrafficBloc, TrafficState>(
      builder: (context, state) {
        final counts = <String, int>{};
        for (final r in state.records) {
          if (r.srcIp.isEmpty) continue;
          counts[r.srcIp] = (counts[r.srcIp] ?? 0) + 1;
        }
        final sorted = counts.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        final top = sorted.take(5).toList();
        final maxCount = top.isEmpty ? 1 : top.first.value;

        return _SectionCard(
          title: 'TOP SOURCES',
          accent: AppColors.primary,
          child: top.isEmpty
              ? const _EmptyHint('No sources captured yet')
              : Column(
                  children: [
                    for (int i = 0; i < top.length; i++) ...[
                      if (i > 0) SpacesManager.h12,
                      _SourceRow(
                        ip: top[i].key,
                        count: top[i].value,
                        fraction: top[i].value / maxCount,
                      ),
                    ],
                  ],
                ),
        );
      },
    );
  }
}

class _SourceRow extends StatelessWidget {
  final String ip;
  final int count;
  final double fraction;

  const _SourceRow({
    required this.ip,
    required this.count,
    required this.fraction,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                ip,
                style: getSemiBoldTextStyle(
                  fontSize: FontSizesManager.s13,
                  color: colors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SpacesManager.w8,
            Text(
              '$count pkts',
              style: getMediumTextStyle(
                fontSize: FontSizesManager.s12,
                color: colors.textMuted,
              ),
            ),
          ],
        ),
        SpacesManager.h6,
        _ProgressBar(fraction: fraction, color: AppColors.primary),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 4. Protocol mix
// ─────────────────────────────────────────────────────────────────────────────

class ProtocolMixCard extends StatelessWidget {
  const ProtocolMixCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TrafficBloc, TrafficState>(
      builder: (context, state) {
        final counts = <Protocol, int>{};
        for (final r in state.records) {
          counts[r.protocol] = (counts[r.protocol] ?? 0) + 1;
        }
        final entries = counts.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        return _SectionCard(
          title: 'PROTOCOL MIX',
          accent: AppColors.accent,
          child: entries.isEmpty
              ? const _EmptyHint('No protocol data yet')
              : Wrap(
                  spacing: PaddingManager.p8,
                  runSpacing: PaddingManager.p8,
                  children: [
                    for (final e in entries)
                      _ProtoPill(
                        protocol: e.key,
                        count: e.value,
                      ),
                  ],
                ),
        );
      },
    );
  }
}

class _ProtoPill extends StatelessWidget {
  final Protocol protocol;
  final int count;

  const _ProtoPill({required this.protocol, required this.count});

  @override
  Widget build(BuildContext context) {
    final color = switch (protocol) {
      Protocol.tcp => AppColors.primary,
      Protocol.udp => AppColors.accent,
      Protocol.icmp => AppColors.statusWarning,
      Protocol.unknown => AppColors.textMuted,
    };

    return Container(
      padding: PaddingManager.paddingH12V7,
      decoration: DecorationManager.coloredChip(
        color,
        BorderRadiusManager.radiusAll10,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: DecorationManager.colorDot(color),
          ),
          SpacesManager.w6,
          Text(
            protocol.name.toUpperCase(),
            style: getBoldTextStyle(
              fontSize: FontSizesManager.s11,
              color: color,
              letterSpacing: 0.4,
            ),
          ),
          SpacesManager.w6,
          Text(
            '$count',
            style: getSemiBoldTextStyle(
              fontSize: FontSizesManager.s12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
