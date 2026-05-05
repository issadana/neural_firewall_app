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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: const BoxDecoration(
            color: AppColors.surfaceLight,
            border: Border(bottom: BorderSide(color: AppColors.borderColor, width: 1)),
          ),
          child: Row(
            children: [
              _VpnStatusDot(status: vpn.status),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _statusLabel(vpn.status),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _statusColor(vpn.status),
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () => context.read<TrafficBloc>().add(const ClearLogsEvent()),
                icon: const Icon(Icons.clear_all, size: 16),
                label: const Text('Clear', style: TextStyle(fontSize: 13)),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
        VpnStatus.stopped => 'Protection stopped',
        VpnStatus.starting => 'Starting…',
        VpnStatus.running => 'Active — Capturing',
        VpnStatus.error => 'VPN error',
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
        backgroundColor: isRunning ? AppColors.statusDanger : AppColors.accent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        minimumSize: const Size(80, 36),
        shape: const StadiumBorder(),
        elevation: 0,
      ),
      child: Text(
        isRunning ? 'Stop' : 'Start',
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }
}
