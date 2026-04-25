import 'package:flutter/material.dart';
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
          return _EmptyState();
        }
        final records = traffic.records.toList();
        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 16),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: records.length,
          itemBuilder: (context, index) =>
              TrafficRow(record: records[index]),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VpnCubit, VpnState>(
      builder: (context, vpn) {
        if (vpn.status == VpnStatus.starting) {
          return _ShimmerCards();
        }
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.wifi_tethering_off_outlined,
                size: 40,
                color: AppColors.textDisabled,
              ),
              const SizedBox(height: 12),
              const Text(
                'No traffic captured',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Press START to begin capture',
                style: TextStyle(
                  color: AppColors.textDisabled,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ShimmerCards extends StatelessWidget {
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
          height: 72,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
