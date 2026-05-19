import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/acl/acl_cubit.dart';
import '../../blocs/acl/acl_state.dart';
import '../../core/theme/app_colors.dart';
import '../blacklist/widgets/add_ip_dialog.dart';
import 'widgets/acl_tile.dart';

class AclScreen extends StatelessWidget {
  const AclScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return BlocBuilder<AclCubit, AclState>(
      builder: (context, state) {
        final entries = state.entries;

        return Scaffold(
          backgroundColor: colors.background,
          appBar: _AclAppBar(
            count: entries.length,
            showClear: entries.isNotEmpty,
            onClear: () => _confirmClearAll(context),
          ),
          body: Column(
            children: [
              const _InfoBanner(),
              Expanded(
                child: entries.isEmpty
                    ? const _EmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        physics: const BouncingScrollPhysics(),
                        itemCount: entries.length,
                        itemBuilder: (context, i) {
                          final entry = entries[i];
                          return AclTile(
                            entry: entry,
                            onDelete: () => context.read<AclCubit>().remove(entry.ip),
                          )
                              .animate()
                              .fadeIn(
                                duration: 250.ms,
                                delay: Duration(milliseconds: i < 8 ? i * 30 : 0),
                              )
                              .slideX(begin: 0.02, end: 0, duration: 250.ms);
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            heroTag: 'acl_fab',
            onPressed: () => _showAddDialog(context),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 4,
            tooltip: 'Add ACL Rule',
            child: const Icon(Icons.add_rounded),
          ),
        );
      },
    );
  }

  Future<void> _showAddDialog(BuildContext context) async {
    final result = await showDialog<({String ip, String notes})>(
      context: context,
      builder: (_) => const AddIpDialog(
        title: 'Add ACL Rule',
        notesHint: 'Notes (optional)',
      ),
    );
    if (result != null && context.mounted) {
      context.read<AclCubit>().add(
            result.ip,
            notes: result.notes.isNotEmpty ? result.notes : null,
          );
    }
  }

  Future<void> _confirmClearAll(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear ACL'),
        content: const Text('Remove all ACL rules? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.statusDanger),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<AclCubit>().clearAll();
    }
  }
}

// ── App Bar ───────────────────────────────────────────────────────────────────

class _AclAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int count;
  final bool showClear;
  final VoidCallback onClear;

  const _AclAppBar({
    required this.count,
    required this.showClear,
    required this.onClear,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return AppBar(
      backgroundColor: colors.background,
      elevation: 0,
      centerTitle: false,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0.5),
        child: Container(height: 0.5, color: colors.borderColor),
      ),
      title: Row(
        children: [
          const Text('Access Control'),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      actions: [
        if (showClear)
          TextButton.icon(
            onPressed: onClear,
            icon: const Icon(Icons.delete_sweep_rounded, size: 16),
            label: const Text('Clear All', style: TextStyle(fontSize: 13)),
            style: TextButton.styleFrom(foregroundColor: AppColors.statusDanger),
          ),
        const SizedBox(width: 4),
      ],
    );
  }
}

// ── Info Banner ───────────────────────────────────────────────────────────────

class _InfoBanner extends StatelessWidget {
  const _InfoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 0.5),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_rounded, color: AppColors.primary, size: 15),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'ACL rules are checked before ML inference. Matching IPs are permanently blocked.',
              style: TextStyle(color: AppColors.primary, fontSize: 12, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: colors.surfaceLight,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: colors.borderColor),
            ),
            child: Icon(
              Icons.shield_rounded,
              size: 36,
              color: AppColors.primary.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No ACL rules',
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to add a permanent block rule.\nACL rules bypass ML inference.',
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.textDisabled, fontSize: 14, height: 1.5),
          ),
        ],
      )
          .animate()
          .fadeIn(duration: 500.ms)
          .slideY(begin: 0.04, end: 0, duration: 500.ms),
    );
  }
}
