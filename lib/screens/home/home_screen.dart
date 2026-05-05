import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'widgets/control_bar.dart';
import 'widgets/stats_row.dart';
import 'widgets/threat_sparkline.dart';
import 'widgets/traffic_table.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceLight,
        elevation: 0,
        centerTitle: true,
        title: Image.asset('assets/images/Sentri_logo.png', height: 32),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.borderColor),
        ),
      ),
      body: const Column(
        children: [
          ControlBar(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  StatsRow(),
                  ThreatSparkline(),
                  Divider(height: 1, color: AppColors.borderColor),
                  TrafficTable(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
