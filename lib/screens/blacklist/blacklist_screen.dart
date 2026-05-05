import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/blacklist/blacklist_cubit.dart';
import '../../blocs/blacklist/blacklist_state.dart';
import '../../core/theme/app_colors.dart';
import 'widgets/add_ip_dialog.dart';
import 'widgets/blacklist_tile.dart';

class BlacklistScreen extends StatelessWidget {
  const BlacklistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BlacklistCubit, BlacklistState>(
      builder: (context, state) {
        final entries = state.entries;

        return Scaffold(
          backgroundColor: AppColors.primaryBlack,
          appBar: AppBar(
            backgroundColor: AppColors.surfaceLight,
            elevation: 0,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Blacklist',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.statusDanger.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${entries.length}',
                    style: const TextStyle(
                      color: AppColors.statusDanger,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Divider(height: 1, color: AppColors.borderColor),
            ),
            actions: [
              if (entries.isNotEmpty)
                TextButton.icon(
                  onPressed: () => _confirmClearAll(context),
                  icon: const Icon(Icons.delete_sweep_outlined, size: 16),
                  label: const Text('Clear All', style: TextStyle(fontSize: 13)),
                  style: TextButton.styleFrom(foregroundColor: AppColors.statusDanger),
                ),
              const SizedBox(width: 4),
            ],
          ),
          body: entries.isEmpty
              ? const _EmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: entries.length,
                  itemBuilder: (context, i) {
                    final entry = entries[i];
                    return BlacklistTile(
                      entry: entry,
                      onDelete: () => context.read<BlacklistCubit>().remove(entry.ip),
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton(
            heroTag: 'blacklist_fab',
            onPressed: () => _showAddDialog(context),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 2,
            tooltip: 'Block IP',
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Future<void> _showAddDialog(BuildContext context) async {
    final result = await showDialog<({String ip, String notes})>(
      context: context,
      builder: (_) => const AddIpDialog(title: 'Block IP Address'),
    );
    if (result != null && context.mounted) {
      context.read<BlacklistCubit>().addManual(result.ip);
    }
  }

  Future<void> _confirmClearAll(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear Blacklist'),
        content: const Text('Remove all blocked IPs? This cannot be undone.'),
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
      context.read<BlacklistCubit>().clearAll();
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_user_outlined, size: 64, color: AppColors.accent.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          const Text(
            'No blocked IPs',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'IPs are auto-blocked when AI detects threats,\nor tap + to block manually.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
