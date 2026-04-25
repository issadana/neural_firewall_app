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
        backgroundColor: AppColors.surfaceDark,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.shield, color: AppColors.accentBlue, size: 20),
            SizedBox(width: 8),
            Text(
              'NEURAL FIREWALL',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: AppColors.accentBlue,
              ),
            ),
          ],
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
