import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:Sentri/core/theme/app_colors.dart';
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
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: AppColors.statusDanger.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
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
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        decoration: BoxDecoration(
          color: colors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.borderColor, width: 0.5),
          boxShadow: colors.cardShadow,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.statusDanger.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(Icons.block_rounded, color: AppColors.statusDanger, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.ip,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        fontFamily: 'monospace',
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        _ReasonBadge(reason: entry.reason),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('MM/dd  HH:mm').format(entry.addedAt),
                          style: TextStyle(color: colors.textDisabled, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (entry.bruteForceScore != null || entry.dosScore != null) ...[
                _ScoreBadges(bf: entry.bruteForceScore, dos: entry.dosScore),
                const SizedBox(width: 8),
              ],
              GestureDetector(
                onTap: onDelete,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.statusDanger.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
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
            style: const TextStyle(
              color: AppColors.statusWarning,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        if (dos != null)
          Text(
            'DoS ${(dos! * 100).toStringAsFixed(0)}%',
            style: const TextStyle(
              color: AppColors.statusDanger,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
      ],
    );
  }
}
