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
            backgroundColor: AppColors.surfaceDark,
            title: Row(
              children: [
                const Text(
                  'BLACKLIST',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: AppColors.accentBlue,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.statusDanger.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.statusDanger, width: 0.5),
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
          body: entries.isEmpty
              ? _EmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
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
            onPressed: () => _showAddDialog(context),
            backgroundColor: AppColors.accentBlue,
            foregroundColor: Colors.black,
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
      builder: (_) => const AddIpDialog(title: 'BLOCK IP ADDRESS'),
    );
    if (result != null && context.mounted) {
      context.read<BlacklistCubit>().addManual(result.ip);
    }
  }

  Future<void> _confirmClearAll(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceLight,
        title: const Text('Clear Blacklist', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          'Remove all blocked IPs? This cannot be undone.',
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
      context.read<BlacklistCubit>().clearAll();
    }
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_user_outlined, size: 56, color: AppColors.accentGreen.withValues(alpha: 0.5)),
          const SizedBox(height: 14),
          const Text(
            'No blocked IPs',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'IPs are auto-blocked when AI detects threats,\nor tap + to block manually.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textDisabled, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
