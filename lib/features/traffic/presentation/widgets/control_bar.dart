import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:Sentri/core/enums.dart';
import 'package:Sentri/core/resources/border_radius_manager.dart';
import 'package:Sentri/core/resources/color_manager.dart';
import 'package:Sentri/core/resources/decoration_manager.dart';
import 'package:Sentri/core/resources/font_manager.dart';
import 'package:Sentri/core/resources/padding_manager.dart';
import 'package:Sentri/core/resources/spaces_manager.dart';
import 'package:Sentri/core/resources/text_style_manager.dart';
import 'package:Sentri/core/theme/app_colors.dart';
import 'package:Sentri/core/widgets/pressable_buttons/app_pressable.dart';
import 'package:Sentri/features/traffic/presentation/bloc/traffic_bloc.dart';
import 'package:Sentri/features/vpn/presentation/bloc/vpn_cubit.dart';

class ControlBar extends StatelessWidget {
  const ControlBar({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return BlocBuilder<VpnCubit, VpnState>(
      builder: (context, vpn) {
        final isRunning = vpn.status == VpnStatus.running;
        final isStarting = vpn.status == VpnStatus.starting;

        return Container(
          padding: PaddingManager.paddingH16V12,
          decoration: DecorationManager.bottomBorder(colors),
          child: Row(
            children: [
              _VpnStatusDot(status: vpn.status),
              SpacesManager.w10,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _statusLabel(vpn.status),
                      style: getBoldTextStyle(
                        fontSize: FontSizesManager.s13,
                        color: _statusColor(vpn.status),
                        letterSpacing: 0.2,
                      ),
                    ),
                    Text(
                      _statusSub(vpn.status),
                      style: getRegularTextStyle(
                        fontSize: FontSizesManager.s11,
                        color: colors.textDisabled,
                      ),
                    ),
                  ],
                ),
              ),
              _StartStopButton(isRunning: isRunning, isStarting: isStarting),
            ],
          ),
        );
      },
    );
  }

  String _statusLabel(VpnStatus status) => switch (status) {
        VpnStatus.stopped  => 'OFFLINE',
        VpnStatus.starting => 'STARTING',
        VpnStatus.running  => 'ACTIVE',
        VpnStatus.error    => 'ERROR',
      };

  String _statusSub(VpnStatus status) => switch (status) {
        VpnStatus.stopped  => 'Protection off',
        VpnStatus.starting => 'Initializing VPN…',
        VpnStatus.running  => 'Capturing traffic',
        VpnStatus.error    => 'VPN error — tap to retry',
      };

  Color _statusColor(VpnStatus status) => switch (status) {
        VpnStatus.stopped  => AppColors.vpnDisconnected,
        VpnStatus.starting => AppColors.vpnConnecting,
        VpnStatus.running  => AppColors.vpnConnected,
        VpnStatus.error    => AppColors.statusDanger,
      };
}

class _VpnStatusDot extends StatelessWidget {
  final VpnStatus status;
  const _VpnStatusDot({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      VpnStatus.running  => AppColors.vpnConnected,
      VpnStatus.starting => AppColors.vpnConnecting,
      VpnStatus.error    => AppColors.statusDanger,
      _                  => AppColors.vpnDisconnected,
    };

    Widget dot = Container(
      width: 10,
      height: 10,
      decoration: DecorationManager.colorDot(color),
    );

    if (status == VpnStatus.running) {
      dot = dot
          .animate(onPlay: (c) => c.repeat())
          .scaleXY(begin: 1.0, end: 1.5, duration: 900.ms, curve: Curves.easeInOut)
          .then()
          .scaleXY(begin: 1.5, end: 1.0, duration: 900.ms, curve: Curves.easeInOut);
    } else if (status == VpnStatus.starting) {
      dot = dot
          .animate(onPlay: (c) => c.repeat())
          .fadeIn(duration: 600.ms)
          .then()
          .fadeOut(duration: 600.ms);
    }

    // Seat the dot inside a soft, status-tinted "radar" disc for more presence.
    return Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: DecorationManager.circleIcon(color, alpha: 0.14),
      child: dot,
    );
  }
}

class _StartStopButton extends StatelessWidget {
  final bool isRunning;
  final bool isStarting;

  const _StartStopButton({required this.isRunning, required this.isStarting});

  @override
  Widget build(BuildContext context) {
    if (isStarting) {
      return const SizedBox(
        width: 80,
        height: 36,
        child: Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.vpnConnecting,
            ),
          ),
        ),
      );
    }

    final bgColor = isRunning ? AppColors.statusDanger : AppColors.accent;
    final label = isRunning ? 'Stop' : 'Start';
    final icon = isRunning ? Icons.stop_rounded : Icons.play_arrow_rounded;

    return AppPressable(
      onPressed: () {
        if (isRunning) {
          context.read<VpnCubit>().stop();
          context.read<TrafficBloc>().add(const StopListeningEvent());
        } else {
          context.read<VpnCubit>().start();
          context.read<TrafficBloc>().add(const StartListeningEvent());
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: PaddingManager.paddingH16V8,
        decoration: DecorationManager.colorButton(bgColor, radius: BorderRadiusManager.radiusAll20),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: ColorManager.white),
            SpacesManager.w4,
            Text(
              label,
              style: getBoldTextStyle(
                fontSize: FontSizesManager.s13,
                color: ColorManager.white,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
