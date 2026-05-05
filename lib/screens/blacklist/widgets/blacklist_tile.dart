import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/app_models.dart';

class BlacklistTile extends StatelessWidget {
  final BlacklistEntry entry;
  final VoidCallback onDelete;

  const BlacklistTile({super.key, required this.entry, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(entry.ip),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: AppColors.statusDanger.withValues(alpha: 0.1),
        child: const Icon(Icons.delete_outline, color: AppColors.statusDanger),
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
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.cardShadow,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.statusDanger.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.block, color: AppColors.statusDanger, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.ip,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _ReasonBadge(reason: entry.reason),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('MM/dd HH:mm').format(entry.addedAt),
                          style: const TextStyle(color: AppColors.textDisabled, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (entry.bruteForceScore != null || entry.dosScore != null)
                _ScoreBadges(bf: entry.bruteForceScore, dos: entry.dosScore),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18),
                color: AppColors.textDisabled,
                onPressed: onDelete,
                tooltip: 'Remove',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: isManual
            ? AppColors.primary.withValues(alpha: 0.1)
            : AppColors.statusDanger.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isManual ? 'Manual' : 'AI Block',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: isManual ? AppColors.primary : AppColors.statusDanger,
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
      children: [
        if (bf != null)
          Text(
            'BF ${(bf! * 100).toStringAsFixed(0)}%',
            style: const TextStyle(
              color: AppColors.statusWarning,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        if (dos != null)
          Text(
            'DoS ${(dos! * 100).toStringAsFixed(0)}%',
            style: const TextStyle(
              color: AppColors.statusDanger,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }
}
