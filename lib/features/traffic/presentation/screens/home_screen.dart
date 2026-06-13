import 'package:flutter/material.dart';

import 'package:Sentri/core/resources/border_radius_manager.dart';
import 'package:Sentri/core/resources/decoration_manager.dart';
import 'package:Sentri/core/resources/font_manager.dart';
import 'package:Sentri/core/resources/padding_manager.dart';
import 'package:Sentri/core/resources/spaces_manager.dart';
import 'package:Sentri/core/resources/text_style_manager.dart';
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
      body: SafeArea(
        child: Column(
          children: [
            const ControlBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    const StatsRow(),
                    const ThreatSparkline(),
                    const _TrafficHeader(),
                    const TrafficTable(),
                    SpacesManager.h24,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrafficHeader extends StatelessWidget {
  const _TrafficHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: PaddingManager.paddingLTRB16_8_16_4,
      child: Row(
        children: [
          Container(
            width: 3,
            height: 16,
            decoration: DecorationManager.colorBar(
              AppColors.primary,
              radius: BorderRadiusManager.radiusAll2,
            ),
          ),
          SpacesManager.w8,
          Text(
            'TRAFFIC LOG',
            style: getBoldTextStyle(
              fontSize: FontSizesManager.s11,
              color: context.appColors.textMuted,
              letterSpacing: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
