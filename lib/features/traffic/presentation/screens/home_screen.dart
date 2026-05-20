import 'package:flutter/material.dart';

import 'package:Sentri/core/theme/app_colors.dart';
import '../widgets/control_bar.dart';
import '../widgets/stats_row.dart';
import '../widgets/threat_sparkline.dart';
import '../widgets/traffic_table.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.background,
      appBar: _SentriAppBar(),
      body: const Column(
        children: [
          ControlBar(),
          Expanded(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                children: [
                  StatsRow(),
                  ThreatSparkline(),
                  _TrafficHeader(),
                  TrafficTable(),
                  SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SentriAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      height: 56 + MediaQuery.of(context).padding.top,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(bottom: BorderSide(color: colors.borderColor, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/logo/logo.png', height: 28, fit: BoxFit.contain),
          const SizedBox(width: 10),
          Text(
            'Sentri',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrafficHeader extends StatelessWidget {
  const _TrafficHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 16,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'TRAFFIC LOG',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: context.appColors.textMuted,
              letterSpacing: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
