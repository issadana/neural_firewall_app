import 'package:flutter/material.dart';

import 'package:Sentri/core/theme/app_colors.dart';
import 'package:Sentri/features/dashboard/presentation/screens/dashboard_screen.dart';

/// The Dashboard bottom-nav tab: hardware stats, threat summary, recent blocked
/// and active models.
class DashboardTabsScreen extends StatelessWidget {
  const DashboardTabsScreen({super.key});

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
      body: const DashboardScreen(),
    );
  }
}
