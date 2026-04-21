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
    return BlocBuilder<TrafficBloc, TrafficState>(
      builder: (context, state) {
        return Container(
          height: 80,
          margin: const EdgeInsets.only(right: 12, left: 12, bottom: 15,),
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
          decoration: BoxDecoration(
            color: AppColors.chartBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'THREAT LEVEL',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 4),
              Expanded(child: _buildChart(state.sparklineData)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChart(List<double> data) {
    if (data.isEmpty) {
      return const Center(
        child: Text(
          'No data — start capture',
          style: TextStyle(fontSize: 15, color: AppColors.textDisabled),
        ),
      );
    }

    final spots = <FlSpot>[];
    for (int i = 0; i < data.length; i++) {
      spots.add(FlSpot(i.toDouble(), data[i].clamp(0.0, 100.0)));
    }

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
            color: AppColors.statusDanger,
            barWidth: 1.5,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.statusDanger.withValues(alpha: 0.15),
            ),
          ),
        ],
        lineTouchData: const LineTouchData(enabled: false),
      ),
      duration: Duration.zero,
    );
  }
}
