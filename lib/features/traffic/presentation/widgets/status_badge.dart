import 'package:Sentri/core/enums.dart';
import 'package:Sentri/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final PacketStatus status;
  const StatusBadge(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      PacketStatus.aiBlock => ('BLOCK',  AppColors.statusDanger),
      PacketStatus.warn    => ('WARN',   AppColors.statusWarning),
      PacketStatus.safe    => ('SAFE',   AppColors.statusNormal),
      PacketStatus.tcp     => ('TCP',    AppColors.accentBlue),
      PacketStatus.quic    => ('QUIC',   const Color(0xFFAA77FF)),
      PacketStatus.ping    => ('PING',   AppColors.statusWarning),
      PacketStatus.err     => ('ERR',    context.appColors.textDisabled),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 0.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
