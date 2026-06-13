import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Sentri/core/resources/border_radius_manager.dart';
import 'package:Sentri/core/resources/decoration_manager.dart';
import 'package:Sentri/core/resources/font_manager.dart';
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
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            const SizedBox(height: 8),
            const HardwareStatsCard(),
            const SizedBox(height: 8),
            _StatsRow(),
            const SizedBox(height: 16),
            _SectionHeader(title: 'Recent Blocked'),
            _RecentBlockedList(),
            const SizedBox(height: 16),
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
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 14,
            decoration: DecorationManager.sectionAccentBar,
          ),
          const SizedBox(width: 8),
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
          padding: const EdgeInsets.symmetric(horizontal: 16),
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
              const SizedBox(width: 8),
              Expanded(
                child: _StatCard(
                  label: 'Blocked',
                  value: '${state.blockedCount}',
                  icon: Icons.block_outlined,
                  color: AppColors.statusDanger,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatCard(
                  label: 'Warned',
                  value: '${state.warnCount}',
                  icon: Icons.warning_amber_outlined,
                  color: AppColors.statusWarning,
                ),
              ),
              const SizedBox(width: 8),
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
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: DecorationManager.surfaceCard(
        colors,
        radius: BorderRadiusManager.radiusAll16,
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(value,
              style: getBoldTextStyle(
                  fontSize: FontSizesManager.s16, color: colors.textPrimary)),
          const SizedBox(height: 2),
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: DecorationManager.surfaceCardBare(
        colors,
        radius: BorderRadiusManager.radiusAll12,
      ),
      child: Row(
        children: [
          Container(
            width: 5,
            height: 36,
            decoration: DecorationManager.colorBar(
              AppColors.statusDanger,
              radius: BorderRadiusManager.radiusAll3,
            ),
          ),
          const SizedBox(width: 10),
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
            Text(
              log.selectedModel,
              style: getSemiBoldTextStyle(
                  fontSize: FontSizesManager.s11, color: AppColors.statusDanger),
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _models
            .map((m) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: DecorationManager.coloredChip(
                    AppColors.primary,
                    BorderRadiusManager.radiusAll10,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, size: 12, color: AppColors.primary),
                      const SizedBox(width: 5),
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
