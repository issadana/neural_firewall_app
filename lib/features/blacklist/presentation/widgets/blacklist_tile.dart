import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:Sentri/core/resources/border_radius_manager.dart';
import 'package:Sentri/core/resources/decoration_manager.dart';
import 'package:Sentri/core/resources/font_manager.dart';
import 'package:Sentri/core/resources/padding_manager.dart';
import 'package:Sentri/core/resources/spaces_manager.dart';
import 'package:Sentri/core/resources/text_style_manager.dart';
import 'package:Sentri/core/theme/app_colors.dart';
import 'package:Sentri/core/widgets/pressable_buttons/app_pressable.dart';
import 'package:Sentri/features/blacklist/domain/entities/blacklist_entry.dart';

class BlacklistTile extends StatelessWidget {
  final BlacklistEntry entry;
  final VoidCallback onDelete;

  const BlacklistTile({super.key, required this.entry, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Dismissible(
      key: ValueKey(entry.ip),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: PaddingManager.paddingRight24,
        decoration: DecorationManager.tinted(
          AppColors.statusDanger,
          BorderRadiusManager.radiusAll16,
          alpha: 0.12,
        ),
        child: const Icon(Icons.delete_rounded, color: AppColors.statusDanger, size: 22),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Remove IP'),
                content: Text('Remove ${entry.ip} from blacklist?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: TextButton.styleFrom(foregroundColor: AppColors.statusDanger),
                    child: const Text('Remove'),
                  ),
                ],
              ),
            ) ??
            false;
      },
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: PaddingManager.paddingH16V5,
        decoration: DecorationManager.surfaceCard(
          colors,
          radius: BorderRadiusManager.radiusAll16,
        ),
        child: Padding(
          padding: PaddingManager.paddingH16V12,
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: DecorationManager.tinted(
                  AppColors.statusDanger,
                  BorderRadiusManager.radiusAll11,
                ),
                child: const Icon(Icons.block_rounded, color: AppColors.statusDanger, size: 18),
              ),
              SpacesManager.w12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.ip,
                      style: getBoldTextStyle(
                        fontSize: FontSizesManager.s14,
                        color: colors.textPrimary,
                        family: 'monospace',
                        letterSpacing: 0.3,
                      ),
                    ),
                    SpacesManager.h5,
                    Row(
                      children: [
                        _ReasonBadge(reason: entry.reason),
                        SpacesManager.w8,
                        Text(
                          DateFormat('MM/dd  HH:mm').format(entry.addedAt),
                          style: getRegularTextStyle(fontSize: FontSizesManager.s11, color: colors.textDisabled),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (entry.bruteForceScore != null || entry.dosScore != null) ...[
                _ScoreBadges(bf: entry.bruteForceScore, dos: entry.dosScore),
                SpacesManager.w8,
              ],
              AppPressable(
                onPressed: onDelete,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: DecorationManager.tinted(
                    AppColors.statusDanger,
                    BorderRadiusManager.radiusAll8,
                    alpha: 0.08,
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    size: 16,
                    color: AppColors.statusDanger,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReasonBadge extends StatelessWidget {
  final String reason;
  const _ReasonBadge({required this.reason});

  @override
  Widget build(BuildContext context) {
    final isManual = reason == 'manual';
    final color = isManual ? AppColors.primary : AppColors.statusDanger;
    final label = isManual ? 'Manual' : 'AI Block';

    return Container(
      padding: PaddingManager.paddingH8V3,
      decoration: DecorationManager.tinted(color, BorderRadiusManager.radiusAll6),
      child: Text(
        label,
        style: getBoldTextStyle(
          fontSize: FontSizesManager.s10,
          color: color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _ScoreBadges extends StatelessWidget {
  final double? bf;
  final double? dos;
  const _ScoreBadges({this.bf, this.dos});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (bf != null)
          Text(
            'BF ${(bf! * 100).toStringAsFixed(0)}%',
            style: getBoldTextStyle(
              fontSize: FontSizesManager.s11,
              color: AppColors.statusWarning,
            ),
          ),
        if (dos != null)
          Text(
            'DoS ${(dos! * 100).toStringAsFixed(0)}%',
            style: getBoldTextStyle(
              fontSize: FontSizesManager.s11,
              color: AppColors.statusDanger,
            ),
          ),
      ],
    );
  }
}
