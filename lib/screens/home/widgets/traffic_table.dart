import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

import '../../../blocs/traffic/traffic_bloc.dart';
import '../../../blocs/traffic/traffic_state.dart';
import '../../../blocs/vpn/vpn_cubit.dart';
import '../../../blocs/vpn/vpn_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/enums.dart';
import 'traffic_row.dart';

class TrafficTable extends StatelessWidget {
  const TrafficTable({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TrafficBloc, TrafficState>(
      builder: (context, traffic) {
        if (traffic.records.isEmpty) {
          return const _EmptyState();
        }
        final records = traffic.records.toList();
        return ListView.builder(
          padding: const EdgeInsets.only(top: 4, bottom: 16),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: records.length,
          itemBuilder: (context, index) => TrafficRow(record: records[index])
              .animate()
              .fadeIn(duration: 250.ms, delay: Duration(milliseconds: index < 5 ? index * 40 : 0))
              .slideX(begin: 0.02, end: 0, duration: 250.ms),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VpnCubit, VpnState>(
      builder: (context, vpn) {
        if (vpn.status == VpnStatus.starting) {
          return const _ShimmerCards();
        }
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderColor),
                ),
                child: const Icon(
                  Icons.wifi_tethering_off_outlined,
                  size: 26,
                  color: AppColors.textDisabled,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'No traffic captured',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Tap START to begin monitoring',
                style: TextStyle(
                  color: AppColors.textDisabled,
                  fontSize: 13,
                ),
              ),
            ],
          )
              .animate()
              .fadeIn(duration: 500.ms)
              .slideY(begin: 0.04, end: 0, duration: 500.ms),
        );
      },
    );
  }
}

class _ShimmerCards extends StatelessWidget {
  const _ShimmerCards();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceLight,
      highlightColor: AppColors.borderColor,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 7,
        itemBuilder: (_, _) => Container(
          height: 70,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
