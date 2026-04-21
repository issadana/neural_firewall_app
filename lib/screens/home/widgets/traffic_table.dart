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

  // Sum of all column widths (590) + horizontal padding (8*2)
  static const double _minTableWidth = 700;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tableWidth = constraints.maxWidth < _minTableWidth
            ? _minTableWidth
            : constraints.maxWidth;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: tableWidth,
            child: Column(
              children: [
                _TableHeader(),
                const Divider(height: 1, color: AppColors.borderColor),
                Expanded(
                  child: BlocBuilder<TrafficBloc, TrafficState>(
                    builder: (context, traffic) {
                      if (traffic.records.isEmpty) {
                        return _EmptyState();
                      }
                      final records = traffic.records.toList();
                      return ListView.separated(
                        itemCount: records.length,
                        separatorBuilder: (_, _) =>
                            const Divider(height: 1, color: AppColors.borderColor),
                        itemBuilder: (context, index) =>
                            TrafficRow(record: records[index]),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      color: AppColors.surfaceDark,
      child: const Row(
        children: [
          _HeaderCell('STATUS', 80),
          _HeaderCell('TIME', 60),
          _HeaderCell('SRC IP:PORT', 125),
          _HeaderCell('DST IP:PORT', 125),
          _HeaderCell('PROTO', 80),
          _HeaderCell('SIZE', 80),
          _HeaderCell('BF%', 38, align: TextAlign.left),
          _HeaderCell('DoS%', 80, align: TextAlign.right),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String label;
  final double width;
  final TextAlign align;

  const _HeaderCell(this.label, this.width,
      {this.align = TextAlign.left});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Text(
        label,
        textAlign: align,
        style: const TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.bold,
          color: AppColors.textDisabled,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VpnCubit, VpnState>(
      builder: (context, vpn) {
        if (vpn.status == VpnStatus.starting) {
          return _ShimmerRows();
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
                  fontSize: 19,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Press START to begin capture',
                style: TextStyle(
                  color: AppColors.textDisabled,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ShimmerRows extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceLight,
      highlightColor: AppColors.borderColor,
      child: ListView.builder(
        itemCount: 8,
        itemBuilder: (_, _) => Container(
          height: 32,
          margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
