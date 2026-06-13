import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Sentri/core/resources/border_radius_manager.dart';
import 'package:Sentri/core/resources/decoration_manager.dart';
import 'package:Sentri/core/resources/font_manager.dart';
import 'package:Sentri/core/resources/padding_manager.dart';
import 'package:Sentri/core/resources/spaces_manager.dart';
import 'package:Sentri/core/resources/text_style_manager.dart';
import 'package:Sentri/core/theme/app_colors.dart';
import 'package:Sentri/features/dashboard/presentation/bloc/dashboard_cubit.dart';
import 'package:Sentri/features/hardware_metrics/presentation/bloc/hardware_metrics_cubit.dart';
import 'package:Sentri/features/hardware_metrics/presentation/widgets/hardware_stats_card.dart';
import 'package:Sentri/features/firewall_logs/presentation/bloc/firewall_logs_cubit.dart';
import 'package:Sentri/features/firewall_logs/domain/entities/firewall_log.dart';

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
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        centerTitle: false,
        title: const Text('Dashboard'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: colors.borderColor),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<HardwareMetricsCubit>().refresh();
          context.read<FirewallLogsCubit>().loadLogs(refresh: true);
        },
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: PaddingManager.paddingBottom32,
          children: [
            SpacesManager.h8,
            const HardwareStatsCard(),
            SpacesManager.h8,
            _StatsRow(),
            SpacesManager.h16,
            _SectionHeader(title: 'Recent Blocked'),
            _RecentBlockedList(),
            SpacesManager.h16,
            _SectionHeader(title: 'Active Models'),
            _ActiveModelsRow(),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

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
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        return Padding(
          padding: PaddingManager.paddingHorizontal16,
          child: Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Packets',
                  value: '${state.packetsAnalyzed}',
                  icon: Icons.analytics_outlined,
                  color: AppColors.primary,
                ),
              ),
              SpacesManager.w8,
              Expanded(
                child: _StatCard(
                  label: 'Blocked',
                  value: '${state.blockedCount}',
                  icon: Icons.block_outlined,
                  color: AppColors.statusDanger,
                ),
              ),
              SpacesManager.w8,
              Expanded(
                child: _StatCard(
                  label: 'Warned',
                  value: '${state.warnCount}',
                  icon: Icons.warning_amber_outlined,
                  color: AppColors.statusWarning,
                ),
              ),
              SpacesManager.w8,
              Expanded(
                child: _StatCard(
                  label: 'Blacklisted',
                  value: '${state.ipsBlacklisted}',
                  icon: Icons.gpp_bad_outlined,
                  color: AppColors.statusCritical,
                ),
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
      padding: PaddingManager.paddingH8V14,
      decoration: DecorationManager.surfaceCard(
        colors,
        radius: BorderRadiusManager.radiusAll16,
      ),
      child: Column(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: DecorationManager.tinted(
              color,
              BorderRadiusManager.radiusAll10,
              alpha: 0.14,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          SpacesManager.h8,
          Text(value,
              style: getBoldTextStyle(
                  fontSize: FontSizesManager.s18, color: color)),
          SpacesManager.h2,
          Text(label,
              style: getRegularTextStyle(fontSize: FontSizesManager.s10, color: colors.textMuted)),
        ],
      ),
    );
  }
}

class _RecentBlockedList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FirewallLogsCubit, FirewallLogsState>(
      builder: (context, state) {
        final blocked = state.logs
            .where((l) => l.action == 'blocked')
            .take(5)
            .toList();

        if (blocked.isEmpty) {
          return Padding(
            padding: PaddingManager.paddingH16V8,
            child: Text('No blocked IPs yet',
                style: getRegularTextStyle(fontSize: FontSizesManager.s13, color: context.appColors.textDisabled)),
          );
        }

        return Column(
          children: blocked.map((log) => _BlockedRow(log: log)).toList(),
        );
      },
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
                Text(
                  log.srcIp.isEmpty ? 'Unknown' : log.srcIp,
                  style: getSemiBoldTextStyle(
                      fontSize: FontSizesManager.s13, color: colors.textPrimary),
                ),
                Text(
                  [
                    if (log.serviceName.isNotEmpty) log.serviceName,
                    if (log.appName.isNotEmpty) log.appName,
                  ].join(' · '),
                  style: getRegularTextStyle(fontSize: FontSizesManager.s11, color: colors.textMuted),
                ),
              ],
            ),
          ),
          if (log.selectedModel.isNotEmpty)
            Container(
              padding: PaddingManager.paddingH8V3,
              decoration: DecorationManager.statusBadge(AppColors.statusDanger),
              child: Text(
                log.selectedModel,
                style: getSemiBoldTextStyle(
                    fontSize: FontSizesManager.s11, color: AppColors.statusDanger),
              ),
            ),
        ],
      ),
    );
  }
}

class _ActiveModelsRow extends StatelessWidget {
  static const _models = ['BF_v1', 'DoS_Hulk', 'Model3', 'Model4', 'Model5'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: PaddingManager.paddingHorizontal16,
      child: Wrap(
        spacing: PaddingManager.p8,
        runSpacing: PaddingManager.p8,
        children: _models
            .map((m) => Container(
                  padding: PaddingManager.paddingH12V7,
                  decoration: DecorationManager.coloredChip(
                    AppColors.primary,
                    BorderRadiusManager.radiusAll10,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: DecorationManager.colorDot(AppColors.accent),
                      ),
                      SpacesManager.w6,
                      Text(m,
                          style: getSemiBoldTextStyle(
                              fontSize: FontSizesManager.s12, color: AppColors.primary)),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }
}
