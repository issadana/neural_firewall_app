import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Sentri/core/resources/border_radius_manager.dart';
import 'package:Sentri/core/resources/decoration_manager.dart';
import 'package:Sentri/core/resources/font_manager.dart';
import 'package:Sentri/core/resources/padding_manager.dart';
import 'package:Sentri/core/resources/spaces_manager.dart';
import 'package:Sentri/core/resources/color_manager.dart';
import 'package:Sentri/core/resources/text_style_manager.dart';
import 'package:Sentri/core/theme/app_colors.dart';
import 'package:Sentri/core/utils/service_resolver.dart';
import 'package:Sentri/features/dashboard/presentation/bloc/dashboard_cubit.dart';
import 'package:Sentri/features/hardware_metrics/presentation/bloc/hardware_metrics_cubit.dart';
import 'package:Sentri/features/hardware_metrics/presentation/widgets/hardware_stats_card.dart';
import 'package:Sentri/features/firewall_logs/presentation/bloc/firewall_logs_cubit.dart';
import 'package:Sentri/features/firewall_logs/domain/entities/firewall_log.dart';
import 'package:Sentri/features/settings/presentation/models/ai_model_catalog.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<HardwareMetricsCubit>().refresh();
    context.read<FirewallLogsCubit>().loadLogs(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    // Embedded as the "Overview" tab inside DashboardTabsScreen, which owns the
    // surrounding Scaffold/AppBar — so this returns body content only.
    return RefreshIndicator(
      onRefresh: () async {
        context.read<HardwareMetricsCubit>().refresh();
        context.read<FirewallLogsCubit>().loadLogs(refresh: true);
      },
      child: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          SpacesManager.h12,
          const _HeroSummary(),
          SpacesManager.h16,
          const HardwareStatsCard(),
          SpacesManager.h20,
          _SectionHeader(title: 'Activity'),
          _StatsGrid(),
          SpacesManager.h20,
          _RecentBlockedSection(),
          SpacesManager.h20,
          _SectionHeader(title: 'Protection Models'),
          SpacesManager.h4,
          _ActiveModelsRow(),
          SpacesManager.h100,
        ],
      ),
    );
  }
}

/// Gradient hero summarising the current protection posture.
class _HeroSummary extends StatelessWidget {
  const _HeroSummary();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        final threats = state.blockedCount + state.warnCount;
        final clear = threats == 0;
        final subtitle = clear
            ? 'All clear — no threats detected'
            : '$threats threat${threats == 1 ? '' : 's'} handled this session';

        return Container(
          margin: PaddingManager.paddingHorizontal16,
          padding: PaddingManager.paddingAll16,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadiusManager.radiusAll24,
            boxShadow: AppColors.glowShadow(AppColors.primary),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: DecorationManager.circleIcon(
                  ColorManager.white,
                  alpha: 0.18,
                ),
                child: Icon(
                  clear ? Icons.verified_user_rounded : Icons.gpp_maybe_rounded,
                  color: ColorManager.white,
                  size: 26,
                ),
              ),
              SpacesManager.w16,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      clear ? "You're Protected" : 'Threats Mitigated',
                      style: getBoldTextStyle(
                        fontSize: FontSizesManager.s18,
                        color: ColorManager.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                    SpacesManager.h4,
                    Text(
                      subtitle,
                      style: getRegularTextStyle(
                        fontSize: FontSizesManager.s12,
                        color: ColorManager.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
              SpacesManager.w12,
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${state.blockedCount}',
                    style: getBoldTextStyle(
                      fontSize: FontSizesManager.s30,
                      color: ColorManager.white,
                      letterSpacing: -1,
                    ),
                  ),
                  Text(
                    'BLOCKED',
                    style: getBoldTextStyle(
                      fontSize: FontSizesManager.s9,
                      color: ColorManager.white.withValues(alpha: 0.85),
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const _SectionHeader({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: PaddingManager.paddingLTRB16_4_16_8,
      child: Row(
        children: [
          Container(
            width: 3,
            height: 14,
            decoration: DecorationManager.sectionAccentBar,
          ),
          SpacesManager.w8,
          Text(
            title.toUpperCase(),
            style: getBoldTextStyle(
              fontSize: FontSizesManager.s11,
              color: colors.textMuted,
              letterSpacing: 1.0,
            ),
          ),
          const Spacer(),
          ?trailing,
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        return Padding(
          padding: PaddingManager.paddingHorizontal16,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Packets Analyzed',
                      value: '${state.packetsAnalyzed}',
                      icon: Icons.analytics_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  SpacesManager.w12,
                  Expanded(
                    child: _StatCard(
                      label: 'Blocked',
                      value: '${state.blockedCount}',
                      icon: Icons.block_rounded,
                      color: AppColors.statusDanger,
                    ),
                  ),
                ],
              ),
              SpacesManager.h12,
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Warned',
                      value: '${state.warnCount}',
                      icon: Icons.warning_amber_rounded,
                      color: AppColors.statusWarning,
                    ),
                  ),
                  SpacesManager.w12,
                  Expanded(
                    child: _StatCard(
                      label: 'Blacklisted',
                      value: '${state.ipsBlacklisted}',
                      icon: Icons.gpp_bad_rounded,
                      color: AppColors.statusCritical,
                    ),
                  ),
                ],
              ),
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
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: PaddingManager.paddingAll16,
      decoration: DecorationManager.surfaceCard(
        colors,
        radius: BorderRadiusManager.radiusAll20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: DecorationManager.tinted(
              color,
              BorderRadiusManager.radiusAll12,
              alpha: 0.14,
            ),
            child: Icon(icon, color: color, size: 19),
          ),
          SpacesManager.h12,
          Text(
            value,
            style: getBoldTextStyle(
              fontSize: FontSizesManager.s22,
              color: colors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          SpacesManager.h2,
          Text(
            label,
            style: getRegularTextStyle(
              fontSize: FontSizesManager.s11,
              color: colors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentBlockedSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FirewallLogsCubit, FirewallLogsState>(
      builder: (context, state) {
        final blocked = state.logs
            .where((l) => l.action == 'blocked')
            .take(5)
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(
              title: 'Recent Blocked',
              trailing: blocked.isEmpty ? null : _CountPill(count: blocked.length),
            ),
            if (blocked.isEmpty)
              Padding(
                padding: PaddingManager.paddingH16V8,
                child: Text(
                  'No blocked IPs yet',
                  style: getRegularTextStyle(
                    fontSize: FontSizesManager.s13,
                    color: context.appColors.textDisabled,
                  ),
                ),
              )
            else
              ...blocked.map((log) => _BlockedRow(log: log)),
          ],
        );
      },
    );
  }
}

class _CountPill extends StatelessWidget {
  final int count;
  const _CountPill({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: PaddingManager.paddingH8V2,
      decoration: DecorationManager.tinted(
        AppColors.statusDanger,
        BorderRadiusManager.radiusAll20,
        alpha: 0.14,
      ),
      child: Text(
        '$count',
        style: getBoldTextStyle(
          fontSize: FontSizesManager.s11,
          color: AppColors.statusDanger,
        ),
      ),
    );
  }
}

class _BlockedRow extends StatelessWidget {
  final FirewallLog log;
  const _BlockedRow({required this.log});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      margin: PaddingManager.paddingH16V3,
      padding: PaddingManager.paddingH14V10,
      decoration: DecorationManager.surfaceCardBare(
        colors,
        radius: BorderRadiusManager.radiusAll12,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: DecorationManager.tinted(
              AppColors.statusDanger,
              BorderRadiusManager.radiusAll10,
              alpha: 0.14,
            ),
            child: const Icon(
              Icons.block_rounded,
              color: AppColors.statusDanger,
              size: 18,
            ),
          ),
          SpacesManager.w12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        log.srcIp.isEmpty ? 'Unknown' : log.srcIp,
                        style: getSemiBoldTextStyle(
                          fontSize: FontSizesManager.s13,
                          color: colors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (log.isSystem) ...[
                      SpacesManager.w6,
                      const _SystemChip(),
                    ],
                  ],
                ),
                SpacesManager.h5,
                Row(
                  children: [
                    _ServiceChip(
                      label: ServiceResolver.label(
                        serviceName: log.serviceName,
                        dstPort: log.dstPort,
                      ),
                    ),
                    if (log.appName.isNotEmpty) ...[
                      SpacesManager.w6,
                      Flexible(
                        child: Text(
                          log.appName,
                          style: getRegularTextStyle(
                            fontSize: FontSizesManager.s11,
                            color: colors.textMuted,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          SpacesManager.w8,
          if (log.selectedModel.isNotEmpty)
            Container(
              padding: PaddingManager.paddingH8V3,
              decoration: DecorationManager.statusBadge(AppColors.statusDanger),
              child: Text(
                log.selectedModel,
                style: getSemiBoldTextStyle(
                  fontSize: FontSizesManager.s11,
                  color: AppColors.statusDanger,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ServiceChip extends StatelessWidget {
  final String label;
  const _ServiceChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: PaddingManager.paddingH8V3,
      decoration: DecorationManager.serviceChip,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lan_rounded, size: 11, color: ColorManager.serviceCyan),
          SpacesManager.w4,
          Text(
            label,
            style: getSemiBoldTextStyle(
              fontSize: FontSizesManager.s10,
              color: ColorManager.serviceCyan,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _SystemChip extends StatelessWidget {
  const _SystemChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: PaddingManager.paddingH8V3,
      decoration: DecorationManager.tinted(
        AppColors.primary,
        BorderRadiusManager.radiusAll6,
      ),
      child: Text(
        'System',
        style: getBoldTextStyle(
          fontSize: FontSizesManager.s10,
          color: AppColors.primary,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _ActiveModelsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: PaddingManager.paddingHorizontal16,
      child: Wrap(
        spacing: PaddingManager.p8,
        runSpacing: PaddingManager.p8,
        children: kAiModelCatalog
            .map(
              (m) => Container(
                padding: PaddingManager.paddingH12V7,
                decoration: DecorationManager.coloredChip(
                  m.accent,
                  BorderRadiusManager.radiusAll10,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: DecorationManager.colorDot(m.accent),
                    ),
                    SpacesManager.w6,
                    Text(
                      m.name,
                      style: getSemiBoldTextStyle(
                        fontSize: FontSizesManager.s12,
                        color: m.accent,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
