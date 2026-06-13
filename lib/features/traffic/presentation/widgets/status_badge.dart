import 'package:Sentri/core/enums.dart';
import 'package:Sentri/core/resources/color_manager.dart';
import 'package:Sentri/core/resources/decoration_manager.dart';
import 'package:Sentri/core/resources/font_manager.dart';
import 'package:Sentri/core/resources/text_style_manager.dart';
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
      PacketStatus.quic    => ('QUIC',   ColorManager.quicPurple),
      PacketStatus.ping    => ('PING',   AppColors.statusWarning),
      PacketStatus.err     => ('ERR',    context.appColors.textDisabled),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: DecorationManager.statusBadge(color),
      child: Text(
        label,
        style: getBoldTextStyle(
          fontSize: FontSizesManager.s10,
          color: color,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
