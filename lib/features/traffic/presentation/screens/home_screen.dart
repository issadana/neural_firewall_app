import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Sentri/core/constants/assets_manager.dart';
import 'package:Sentri/core/resources/border_radius_manager.dart';
import 'package:Sentri/core/resources/decoration_manager.dart';
import 'package:Sentri/core/resources/font_manager.dart';
import 'package:Sentri/core/resources/padding_manager.dart';
import 'package:Sentri/core/resources/spaces_manager.dart';
import 'package:Sentri/core/resources/text_style_manager.dart';
import 'package:Sentri/core/theme/app_colors.dart';
import 'package:Sentri/core/widgets/pressable_buttons/app_pressable.dart';
import 'package:Sentri/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:Sentri/features/auth/presentation/bloc/auth_cubit.dart';
import '../bloc/traffic_bloc.dart';
import '../widgets/control_bar.dart';
import '../widgets/traffic_table.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const ControlBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    const _AnalyticsCard(),
                    const _WelcomeHeader(),
                    const _TrafficHeader(),
                    const TrafficTable(),
                    SpacesManager.h150,
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

/// Greets the signed-in user by name. The username is read from [AuthCubit],
/// which restores it from secure storage on launch, so it survives app kills.
class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final username = context.select<AuthCubit, String?>(
      (cubit) => cubit.state.username,
    );
    final name = (username == null || username.isEmpty) ? 'there' : username;

    return Padding(
      padding: PaddingManager.paddingLTRB16_16_16_8,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: DecorationManager.tinted(
              AppColors.primary,
              BorderRadiusManager.radiusAll14,
              alpha: 0.14,
            ),
            child: Text(
              name.characters.first.toUpperCase(),
              style: getBoldTextStyle(
                fontSize: FontSizesManager.s18,
                color: AppColors.primary,
              ),
            ),
          ),
          SpacesManager.w12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text.rich(
                  TextSpan(
                    text: 'Good day, ',
                    style: getRegularTextStyle(
                      fontSize: FontSizesManager.s13,
                      color: colors.textMuted,
                    ),
                    children: [
                      TextSpan(
                        text: name.toUpperCase(),
                        style: getBoldTextStyle(
                          fontSize: FontSizesManager.s15,
                          color: colors.textPrimary,
                        ),
                      ),
                      TextSpan(
                        text: '!\nHere\'s your latest traffic',
                        style: getRegularTextStyle(
                          fontSize: FontSizesManager.s13,
                          color: colors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A small entry card on Home that launches the Analytics screen. Shows the app
/// logo with an animated sparkle to hint at the richer insights inside.
class _AnalyticsCard extends StatelessWidget {
  const _AnalyticsCard();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: PaddingManager.paddingLTRB16_16_16_8,
      child: AppPressable(
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const AnalyticsScreen())),
        child: Container(
          padding: PaddingManager.paddingAll16,
          decoration: DecorationManager.surfaceCard(
            colors,
            radius: BorderRadiusManager.radiusAll20,
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                clipBehavior: Clip.antiAlias,
                decoration: DecorationManager.tinted(
                  AppColors.primary,
                  BorderRadiusManager.radiusAll14,
                  alpha: 0.14,
                ),
                child: Image.asset(AssetsManager.logo, fit: BoxFit.cover),
              ),
              SpacesManager.w12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Analytics',
                          style: getBoldTextStyle(
                            fontSize: FontSizesManager.s15,
                            color: colors.textPrimary,
                          ),
                        ),
                        SpacesManager.w6,
                        Icon(
                              Icons.auto_awesome_rounded,
                              size: 14,
                              color: AppColors.primary,
                            )
                            .animate(onPlay: (c) => c.repeat())
                            .shimmer(duration: 2200.ms, color: AppColors.accent)
                            .then(delay: 1400.ms),
                      ],
                    ),
                    SpacesManager.h2,
                    Text(
                      'Tap to explore threat trends & insights',
                      style: getRegularTextStyle(
                        fontSize: FontSizesManager.s12,
                        color: colors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              SpacesManager.w8,
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: colors.textDisabled,
              ),
            ],
          ),
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
          const Spacer(),
          _ClearButton(),
        ],
      ),
    );
  }
}

class _ClearButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return AppPressable(
      onPressed: () => context.read<TrafficBloc>().add(const ClearLogsEvent()),
      child: Container(
        padding: PaddingManager.paddingH10V6,
        decoration: DecorationManager.clearButton(colors),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.clear_all_rounded, size: 14, color: colors.textDisabled),
            SpacesManager.w4,
            Text(
              'Clear',
              style: getMediumTextStyle(
                fontSize: FontSizesManager.s12,
                color: colors.textDisabled,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
