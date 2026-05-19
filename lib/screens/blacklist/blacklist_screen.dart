import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
          backgroundColor: AppColors.background,
          appBar: _BlacklistAppBar(
            count: entries.length,
            showClear: entries.isNotEmpty,
            onClear: () => _confirmClearAll(context),
          ),
          body: entries.isEmpty
              ? const _EmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  physics: const BouncingScrollPhysics(),
                  itemCount: entries.length,
                  itemBuilder: (context, i) {
                    final entry = entries[i];
                    return BlacklistTile(
                      entry: entry,
                      onDelete: () => context.read<BlacklistCubit>().remove(entry.ip),
                    )
                        .animate()
                        .fadeIn(duration: 250.ms, delay: Duration(milliseconds: i < 8 ? i * 30 : 0))
                        .slideX(begin: 0.02, end: 0, duration: 250.ms);
                  },
                ),
          floatingActionButton: FloatingActionButton(
            heroTag: 'blacklist_fab',
            onPressed: () => _showAddDialog(context),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 4,
            tooltip: 'Block IP',
            child: const Icon(Icons.add_rounded),
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

// ── App Bar ───────────────────────────────────────────────────────────────────

class _BlacklistAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int count;
  final bool showClear;
  final VoidCallback onClear;

  const _BlacklistAppBar({
    required this.count,
    required this.showClear,
    required this.onClear,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: false,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0.5),
        child: Container(height: 0.5, color: AppColors.borderColor),
      ),
      title: Row(
        children: [
          const Text('Blacklist'),
          const SizedBox(width: 10),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.statusDanger.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                color: AppColors.statusDanger,
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

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.borderColor),
            ),
            child: Icon(
              Icons.verified_user_rounded,
              size: 36,
              color: AppColors.accent.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No blocked IPs',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'IPs are auto-blocked when threats are\ndetected, or tap + to block manually.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textDisabled, fontSize: 14, height: 1.5),
          ),
        ],
      )
          .animate()
          .fadeIn(duration: 500.ms)
          .slideY(begin: 0.04, end: 0, duration: 500.ms),
    );
  }
}
