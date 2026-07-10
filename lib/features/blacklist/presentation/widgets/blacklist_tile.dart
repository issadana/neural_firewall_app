import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:Sentri/core/resources/border_radius_manager.dart';
import 'package:Sentri/core/resources/decoration_manager.dart';
import 'package:Sentri/core/resources/font_manager.dart';
import 'package:Sentri/core/resources/padding_manager.dart';
import 'package:Sentri/core/resources/spaces_manager.dart';
import 'package:Sentri/core/resources/text_style_manager.dart';
import 'package:Sentri/core/constants/ai_models.dart';
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
                        _ReasonBadge(entry: entry),
                        SpacesManager.w8,
                        Text(
                          // .toLocal(): server timestamps arrive as UTC, so
                          // format in the device's zone, not UTC.
                          DateFormat('MM/dd  HH:mm').format(entry.addedAt.toLocal()),
                          style: getRegularTextStyle(fontSize: FontSizesManager.s11, color: colors.textDisabled),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (entry.flaggedScore != null) ...[
                _ScoreBadge(score: entry.flaggedScore!),
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
  final BlacklistEntry entry;
  const _ReasonBadge({required this.entry});

  @override
  Widget build(BuildContext context) {
    final isManual = !entry.isAiBlock;
    final color = isManual ? AppColors.primary : AppColors.statusDanger;

    // For an AI block, name the model that actually flagged the IP (the max
    // scorer). Fall back to a generic label if the id is missing/unknown.
    final modelId = entry.flaggedModelId;
    final label = isManual
        ? 'Manual'
        : (modelId != null ? AiModels.tryById(modelId)?.label : null) ??
            'AI Block';

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

class _ScoreBadge extends StatelessWidget {
  final double score;
  const _ScoreBadge({required this.score});

  @override
  Widget build(BuildContext context) {
    return Text(
      '${(score * 100).toStringAsFixed(0)}%',
      style: getBoldTextStyle(
        fontSize: FontSizesManager.s13,
        color: AppColors.statusDanger,
      ),
    );
  }
}
