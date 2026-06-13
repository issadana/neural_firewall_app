import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:Sentri/core/resources/border_radius_manager.dart';
import 'package:Sentri/core/resources/decoration_manager.dart';
import 'package:Sentri/core/resources/font_manager.dart';
import 'package:Sentri/core/resources/padding_manager.dart';
import 'package:Sentri/core/resources/spaces_manager.dart';
import 'package:Sentri/core/resources/text_style_manager.dart';
import 'package:Sentri/core/theme/app_colors.dart';
import 'package:Sentri/features/blacklist/presentation/bloc/blacklist_cubit.dart';
import '../widgets/add_ip_dialog.dart';
import '../widgets/blacklist_tile.dart';

class BlacklistScreen extends StatelessWidget {
  const BlacklistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return BlocBuilder<BlacklistCubit, BlacklistState>(
      builder: (context, state) {
        final entries = state.entries;

        return Scaffold(
          backgroundColor: colors.background,
          appBar: _BlacklistAppBar(
            count: entries.length,
            showClear: entries.isNotEmpty,
            onClear: () => _confirmClearAll(context),
            onAdd: () => _showAddDialog(context),
          ),
          body: entries.isEmpty
              ? const _EmptyState()
              : ListView.builder(
                  padding: PaddingManager.paddingVertical12,
                  physics: const BouncingScrollPhysics(),
                  itemCount: entries.length,
                  itemBuilder: (context, i) {
                    final entry = entries[i];
                    return BlacklistTile(
                      entry: entry,
                      onDelete: () => context.read<BlacklistCubit>().remove(entry.ip),
                    )
                        .animate()
                        .fadeIn(
                          duration: 250.ms,
                          delay: Duration(milliseconds: i < 8 ? i * 30 : 0),
                        )
                        .slideX(begin: 0.02, end: 0, duration: 250.ms);
                  },
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

class _BlacklistAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int count;
  final bool showClear;
  final VoidCallback onClear;
  final VoidCallback onAdd;

  const _BlacklistAppBar({
    required this.count,
    required this.showClear,
    required this.onClear,
    required this.onAdd,
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
          const Text('Blacklist'),
          SpacesManager.w10,
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: PaddingManager.paddingH8V3,
            decoration: DecorationManager.tinted(
              AppColors.statusDanger,
              BorderRadiusManager.radiusAll20,
              alpha: 0.15,
            ),
            child: Text(
              '$count',
              style: getBoldTextStyle(
                fontSize: FontSizesManager.s12,
                color: AppColors.statusDanger,
              ),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: onAdd,
          icon: const Icon(Icons.add_rounded),
          tooltip: 'Block IP',
          style: IconButton.styleFrom(foregroundColor: AppColors.primary),
        ),
        if (showClear)
          TextButton.icon(
            onPressed: onClear,
            icon: const Icon(Icons.delete_sweep_rounded, size: 16),
            label: Text('Clear All', style: getRegularTextStyle(fontSize: FontSizesManager.s13)),
            style: TextButton.styleFrom(foregroundColor: AppColors.statusDanger),
          ),
        SpacesManager.w4,
      ],
    );
  }
}

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
            decoration: DecorationManager.surfaceCardBare(
              colors,
              radius: BorderRadiusManager.radiusAll22,
              borderWidth: 1.0,
            ),
            child: Icon(
              Icons.verified_user_rounded,
              size: 36,
              color: AppColors.accent.withValues(alpha: 0.7),
            ),
          ),
          SpacesManager.h20,
          Text(
            'No blocked IPs',
            style: getBoldTextStyle(
              fontSize: FontSizesManager.s18,
              color: colors.textPrimary,
            ),
          ),
          SpacesManager.h8,
          Text(
            'IPs are auto-blocked when threats are\ndetected, or tap + to block manually.',
            textAlign: TextAlign.center,
            style: getRegularTextStyle(fontSize: FontSizesManager.s14, color: colors.textDisabled, height: 1.5),
          ),
        ],
      )
          .animate()
          .fadeIn(duration: 500.ms)
          .slideY(begin: 0.04, end: 0, duration: 500.ms),
    );
  }
}
