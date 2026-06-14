import 'package:flutter/material.dart';

import 'package:Sentri/core/resources/spaces_manager.dart';
import 'package:Sentri/core/theme/app_colors.dart';
import 'package:Sentri/features/analytics/presentation/widgets/analytics_sections.dart';
import 'package:Sentri/features/traffic/presentation/widgets/stats_row.dart';
import 'package:Sentri/features/traffic/presentation/widgets/threat_sparkline.dart';

/// Deeper traffic analytics, reached from the Home control bar. Surfaces the
/// threat trend chart plus the live traffic stat cards in one focused view.
class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        centerTitle: false,
        title: const Text('Analytics'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: colors.borderColor),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const AnalyticsStats(),
              SpacesManager.h8,
              const ThreatSparkline(),
              SpacesManager.h4,
              const TrafficBreakdownCard(),
              const ThreatVectorsCard(),
              const TopSourcesCard(),
              const ProtocolMixCard(),
              SpacesManager.h24,
            ],
          ),
        ),
      ),
    );
  }
}
