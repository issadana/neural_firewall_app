import 'package:flutter/material.dart';
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
    return BlocBuilder<AclCubit, AclState>(
      builder: (context, state) {
        final entries = state.entries;

        return Scaffold(
          backgroundColor: AppColors.primaryBlack,
          appBar: AppBar(
            backgroundColor: AppColors.surfaceDark,
            title: Row(
              children: [
                const Text(
                  'ACCESS CONTROL LIST',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: AppColors.accentBlue,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.accentBlue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.accentBlue, width: 0.5),
                  ),
                  child: Text(
                    '${entries.length}',
                    style: const TextStyle(
                      color: AppColors.accentBlue,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              if (entries.isNotEmpty)
                TextButton.icon(
                  onPressed: () => _confirmClearAll(context),
                  icon: const Icon(Icons.delete_sweep_outlined, size: 16),
                  label: const Text('CLEAR ALL', style: TextStyle(fontSize: 13)),
                  style: TextButton.styleFrom(foregroundColor: AppColors.statusDanger),
                ),
              const SizedBox(width: 4),
            ],
          ),
          body: Column(
            children: [
              _InfoBanner(),
              Expanded(
                child: entries.isEmpty
                    ? _EmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: entries.length,
                        itemBuilder: (context, i) {
                          final entry = entries[i];
                          return AclTile(
                            entry: entry,
                            onDelete: () => context.read<AclCubit>().remove(entry.ip),
                          );
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddDialog(context),
            backgroundColor: AppColors.accentBlue,
            foregroundColor: Colors.black,
            tooltip: 'Add ACL Rule',
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Future<void> _showAddDialog(BuildContext context) async {
    final result = await showDialog<({String ip, String notes})>(
      context: context,
      builder: (_) => const AddIpDialog(
        title: 'ADD ACL RULE',
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
        backgroundColor: AppColors.surfaceLight,
        title: const Text('Clear ACL', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          'Remove all ACL rules? This cannot be undone.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('CLEAR ALL', style: TextStyle(color: AppColors.statusDanger)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<AclCubit>().clearAll();
    }
  }
}

class _InfoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.accentBlue.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.accentBlue.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.accentBlue, size: 16),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'ACL rules are checked before ML inference. Matching IPs are permanently blocked.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shield_outlined, size: 56, color: AppColors.accentBlue.withValues(alpha: 0.4)),
          const SizedBox(height: 14),
          const Text(
            'No ACL rules',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tap + to add a permanent block rule.\nACL rules bypass ML inference.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textDisabled, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
