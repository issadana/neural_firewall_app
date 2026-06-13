import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

import 'package:Sentri/core/enums.dart';
import 'package:Sentri/core/resources/border_radius_manager.dart';
import 'package:Sentri/core/resources/decoration_manager.dart';
import 'package:Sentri/core/resources/font_manager.dart';
import 'package:Sentri/core/resources/padding_manager.dart';
import 'package:Sentri/core/resources/spaces_manager.dart';
import 'package:Sentri/core/resources/text_style_manager.dart';
import 'package:Sentri/core/theme/app_colors.dart';
import 'package:Sentri/features/traffic/presentation/bloc/traffic_bloc.dart';
import 'package:Sentri/features/vpn/presentation/bloc/vpn_cubit.dart';
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
          padding: PaddingManager.paddingTop4Bottom16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: records.length,
          itemBuilder: (context, index) => TrafficRow(record: records[index])
              .animate()
              .fadeIn(
                duration: 250.ms,
                delay: Duration(milliseconds: index < 5 ? index * 40 : 0),
              )
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
    final colors = context.appColors;
    return BlocBuilder<VpnCubit, VpnState>(
      builder: (context, vpn) {
        if (vpn.status == VpnStatus.starting) {
          return const _ShimmerCards();
        }
        return Padding(
          padding: PaddingManager.paddingVertical40,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: DecorationManager.surfaceCardBare(
                  colors,
                  radius: BorderRadiusManager.radiusAll16,
                  borderWidth: 1.0,
                ),
                child: Icon(
                  Icons.wifi_tethering_off_outlined,
                  size: 26,
                  color: colors.textDisabled,
                ),
              ),
              SpacesManager.h16,
              Text(
                'No traffic captured',
                style: getSemiBoldTextStyle(
                  fontSize: FontSizesManager.s15,
                  color: colors.textSecondary,
                ),
              ),
              SpacesManager.h6,
              Text(
                'Tap START to begin monitoring',
                style: getRegularTextStyle(fontSize: FontSizesManager.s13, color: colors.textDisabled),
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
    final colors = context.appColors;
    return Shimmer.fromColors(
      baseColor: colors.surfaceLight,
      highlightColor: colors.borderColor,
      child: ListView.builder(
        padding: PaddingManager.paddingVertical8,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 7,
        itemBuilder: (_, _) => Container(
          height: 70,
          margin: PaddingManager.paddingH12V3,
          decoration: DecorationManager.surfaceCardBare(
            colors,
            radius: BorderRadiusManager.radiusAll12,
          ),
        ),
      ),
    );
  }
}
