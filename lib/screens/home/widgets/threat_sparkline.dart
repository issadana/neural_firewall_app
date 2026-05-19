import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/traffic/traffic_bloc.dart';
import '../../../blocs/traffic/traffic_state.dart';
import '../../../core/theme/app_colors.dart';

class ThreatSparkline extends StatelessWidget {
  const ThreatSparkline({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return BlocBuilder<TrafficBloc, TrafficState>(
      builder: (context, state) {
        return Container(
          height: 100,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          padding: const EdgeInsets.fromLTRB(16, 12, 12, 8),
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
                    width: 3,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.statusDanger,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'THREAT TREND',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: colors.textMuted,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Expanded(child: _buildChart(state.sparklineData, colors)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChart(List<double> data, AppThemeColors colors) {
    if (data.isEmpty) {
      return Center(
        child: Text(
          'Start capture to see threat trend',
          style: TextStyle(fontSize: 12, color: colors.textDisabled),
        ),
      );
    }

    final spots = <FlSpot>[
      for (int i = 0; i < data.length; i++)
        FlSpot(i.toDouble(), data[i].clamp(0.0, 100.0)),
    ];

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: 100,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: const FlTitlesData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.35,
            color: AppColors.statusDanger,
            barWidth: 2,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.statusDanger.withValues(alpha: 0.25),
                  AppColors.statusDanger.withValues(alpha: 0.02),
                ],
              ),
            ),
          ),
        ],
        lineTouchData: const LineTouchData(enabled: false),
      ),
      duration: const Duration(milliseconds: 150),
    );
  }
}
