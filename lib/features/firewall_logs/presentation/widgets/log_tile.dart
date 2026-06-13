import 'package:flutter/material.dart';
import 'package:Sentri/core/resources/border_radius_manager.dart';
import 'package:Sentri/core/resources/decoration_manager.dart';
import 'package:Sentri/core/resources/font_manager.dart';
import 'package:Sentri/core/resources/padding_manager.dart';
import 'package:Sentri/core/resources/spaces_manager.dart';
import 'package:Sentri/core/resources/text_style_manager.dart';
import 'package:Sentri/core/theme/app_colors.dart';
import '../../domain/entities/firewall_log.dart';

class LogTile extends StatelessWidget {
  final FirewallLog log;

  const LogTile({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final actionColor = _actionColor(log.action);

    return Container(
      margin: PaddingManager.paddingH16V4,
      padding: PaddingManager.paddingAll12,
      decoration: DecorationManager.surfaceCard(
        colors,
        radius: BorderRadiusManager.radiusAll14,
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 48,
            decoration: DecorationManager.colorBar(
              actionColor,
              radius: BorderRadiusManager.radiusAll3,
            ),
          ),
          SpacesManager.w12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        log.srcIp.isEmpty ? 'Unknown IP' : log.srcIp,
                        style: getSemiBoldTextStyle(
                          fontSize: FontSizesManager.s13,
                          color: colors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _ActionChip(action: log.action, color: actionColor),
                  ],
                ),
                SpacesManager.h4,
                Row(
                  children: [
                    if (log.serviceName.isNotEmpty) ...[
                      Icon(Icons.public, size: 11, color: colors.textDisabled),
                      SpacesManager.w3,
                      Text(log.serviceName,
                          style: getRegularTextStyle(fontSize: FontSizesManager.s11, color: colors.textMuted)),
                      SpacesManager.w10,
                    ],
                    if (log.appName.isNotEmpty) ...[
                      Icon(Icons.apps, size: 11, color: colors.textDisabled),
                      SpacesManager.w3,
                      Text(log.appName,
                          style: getRegularTextStyle(fontSize: FontSizesManager.s11, color: colors.textMuted)),
                      SpacesManager.w10,
                    ],
                    if (log.selectedModel.isNotEmpty) ...[
                      Icon(Icons.memory, size: 11, color: colors.textDisabled),
                      SpacesManager.w3,
                      Text(
                        '${log.selectedModel} ${(log.selectedScore * 100).toStringAsFixed(0)}%',
                        style: getRegularTextStyle(fontSize: FontSizesManager.s11, color: colors.textMuted),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _actionColor(String action) => switch (action) {
        'blocked' => AppColors.statusDanger,
        'warned' => AppColors.statusWarning,
        'allowed' => AppColors.statusNormal,
        _ => AppColors.primary,
      };
}

class _ActionChip extends StatelessWidget {
  final String action;
  final Color color;

  const _ActionChip({required this.action, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: PaddingManager.paddingH8V3,
      decoration: DecorationManager.tinted(color, BorderRadiusManager.radiusAll8, alpha: 0.14),
      child: Text(
        action.toUpperCase(),
        style: getBoldTextStyle(
          fontSize: FontSizesManager.s10,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
