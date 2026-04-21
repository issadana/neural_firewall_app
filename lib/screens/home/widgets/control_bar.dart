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
    return BlocBuilder<VpnCubit, VpnState>(
      builder: (context, vpn) {
        final isRunning = vpn.status == VpnStatus.running;
        final isStarting = vpn.status == VpnStatus.starting;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: const BoxDecoration(
            color: AppColors.surfaceDark,
            border: Border(
              bottom: BorderSide(color: AppColors.borderColor, width: 1),
            ),
          ),
          child: Row(
            children: [
              _VpnStatusDot(status: vpn.status),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _statusLabel(vpn.status),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: _statusColor(vpn.status),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () =>
                    context.read<TrafficBloc>().add(const ClearLogsEvent()),
                icon: const Icon(Icons.clear_all, size: 16),
                label: const Text('CLEAR', style: TextStyle(fontSize: 16)),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
              ),
              const SizedBox(width: 4),
              _StartStopButton(isRunning: isRunning, isStarting: isStarting),
            ],
          ),
        );
      },
    );
  }

  String _statusLabel(VpnStatus status) => switch (status) {
        VpnStatus.stopped => 'VPN STOPPED',
        VpnStatus.starting => 'STARTING...',
        VpnStatus.running => 'VPN ACTIVE — CAPTURING',
        VpnStatus.error => 'VPN ERROR',
      };

  Color _statusColor(VpnStatus status) => switch (status) {
        VpnStatus.stopped => AppColors.vpnDisconnected,
        VpnStatus.starting => AppColors.vpnConnecting,
        VpnStatus.running => AppColors.vpnConnected,
        VpnStatus.error => AppColors.statusDanger,
      };
}

class _VpnStatusDot extends StatelessWidget {
  final VpnStatus status;
  const _VpnStatusDot({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      VpnStatus.running => AppColors.vpnConnected,
      VpnStatus.starting => AppColors.vpnConnecting,
      VpnStatus.error => AppColors.statusDanger,
      _ => AppColors.vpnDisconnected,
    };

    final dot = Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 6)],
      ),
    );

    if (status == VpnStatus.running) {
      return dot
          .animate(onPlay: (c) => c.repeat())
          .scaleXY(begin: 1.0, end: 1.4, duration: 800.ms)
          .then()
          .scaleXY(begin: 1.4, end: 1.0, duration: 800.ms);
    }
    return dot;
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

    return ElevatedButton(
      onPressed: () {
        if (isRunning) {
          context.read<VpnCubit>().stop();
          context.read<TrafficBloc>().add(const StopListeningEvent());
        } else {
          context.read<VpnCubit>().start();
          context.read<TrafficBloc>().add(const StartListeningEvent());
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isRunning ? AppColors.statusDanger : AppColors.accentGreen,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        minimumSize: const Size(80, 34),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      child: Text(
        isRunning ? 'STOP' : 'START',
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
      ),
    );
  }
}
