import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:Sentri/core/resources/border_radius_manager.dart';
import 'package:Sentri/core/resources/decoration_manager.dart';
import 'package:Sentri/core/resources/font_manager.dart';
import 'package:Sentri/core/resources/padding_manager.dart';
import 'package:Sentri/core/resources/spaces_manager.dart';
import 'package:Sentri/core/resources/text_style_manager.dart';
import 'package:Sentri/core/theme/app_colors.dart';
import 'package:Sentri/features/traffic/presentation/bloc/traffic_bloc.dart';

class ThreatSparkline extends StatelessWidget {
  const ThreatSparkline({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return BlocBuilder<TrafficBloc, TrafficState>(
      builder: (context, state) {
        return Container(
          height: 100,
          margin: PaddingManager.paddingLTRB16_0_16_12,
          padding: PaddingManager.paddingLTRB16_12_12_8,
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
                      AppColors.statusDanger,
                      radius: BorderRadiusManager.radiusAll2,
                    ),
                  ),
                  SpacesManager.w8,
                  Text(
                    'THREAT TREND',
                    style: getBoldTextStyle(
                      fontSize: FontSizesManager.s10,
                      color: colors.textMuted,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              SpacesManager.h6,
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
          style: getRegularTextStyle(fontSize: FontSizesManager.s12, color: colors.textDisabled),
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
              gradient: DecorationManager.threatSparkline,
            ),
          ),
        ],
        lineTouchData: const LineTouchData(enabled: false),
      ),
      duration: const Duration(milliseconds: 150),
    );
  }
}
