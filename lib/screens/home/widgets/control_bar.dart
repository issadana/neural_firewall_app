import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/traffic/traffic_bloc.dart';
import '../../../blocs/traffic/traffic_event.dart';
import '../../../blocs/vpn/vpn_cubit.dart';
import '../../../blocs/vpn/vpn_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/enums.dart';

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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: colors.surfaceLight,
            border: Border(
              bottom: BorderSide(color: colors.borderColor, width: 0.5),
            ),
          ),
          child: Row(
            children: [
              _VpnStatusDot(status: vpn.status),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _statusLabel(vpn.status),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _statusColor(vpn.status),
                        letterSpacing: 0.2,
                      ),
                    ),
                    Text(
                      _statusSub(vpn.status),
                      style: TextStyle(
                        fontSize: 11,
                        color: colors.textDisabled,
                      ),
                    ),
                  ],
                ),
              ),
              _ClearButton(),
              const SizedBox(width: 8),
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

// ── VPN Status Dot ────────────────────────────────────────────────────────────

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

    final dot = Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: AppColors.glowShadow(color),
      ),
    );

    if (status == VpnStatus.running) {
      return dot
          .animate(onPlay: (c) => c.repeat())
          .scaleXY(begin: 1.0, end: 1.5, duration: 900.ms, curve: Curves.easeInOut)
          .then()
          .scaleXY(begin: 1.5, end: 1.0, duration: 900.ms, curve: Curves.easeInOut);
    }
    if (status == VpnStatus.starting) {
      return dot
          .animate(onPlay: (c) => c.repeat())
          .fadeIn(duration: 600.ms)
          .then()
          .fadeOut(duration: 600.ms);
    }
    return dot;
  }
}

// ── Clear Button ──────────────────────────────────────────────────────────────

class _ClearButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return GestureDetector(
      onTap: () => context.read<TrafficBloc>().add(const ClearLogsEvent()),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: colors.borderColor.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.clear_all_rounded, size: 14, color: colors.textDisabled),
            const SizedBox(width: 4),
            Text(
              'Clear',
              style: TextStyle(
                fontSize: 12,
                color: colors.textDisabled,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Start / Stop Button ───────────────────────────────────────────────────────

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

    return GestureDetector(
      onTap: () {
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppColors.glowShadow(bgColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
