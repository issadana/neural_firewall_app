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
import 'package:Sentri/core/widgets/pressable_buttons/app_pressable.dart';
import 'package:Sentri/features/blacklist/domain/entities/blacklist_entry.dart';
import 'package:Sentri/features/blacklist/presentation/bloc/blacklist_cubit.dart';
import '../widgets/add_ip_dialog.dart';
import '../widgets/blacklist_tile.dart';

enum _BlacklistFilter { all, ai, manual }

bool _isManual(BlacklistEntry e) => e.reason == 'manual';

class BlacklistScreen extends StatefulWidget {
  const BlacklistScreen({super.key});

  @override
  State<BlacklistScreen> createState() => _BlacklistScreenState();
}

class _BlacklistScreenState extends State<BlacklistScreen> {
  _BlacklistFilter _filter = _BlacklistFilter.all;

  List<BlacklistEntry> _applyFilter(List<BlacklistEntry> entries) {
    switch (_filter) {
      case _BlacklistFilter.all:
        return entries;
      case _BlacklistFilter.ai:
        return entries.where((e) => !_isManual(e)).toList();
      case _BlacklistFilter.manual:
        return entries.where(_isManual).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return BlocBuilder<BlacklistCubit, BlacklistState>(
      builder: (context, state) {
        final entries = state.entries;
        final manualCount = entries.where(_isManual).length;
        final aiCount = entries.length - manualCount;
        final filtered = _applyFilter(entries);

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
              : Column(
                  children: [
                    _FilterBar(
                      filter: _filter,
                      all: entries.length,
                      ai: aiCount,
                      manual: manualCount,
                      onChanged: (f) => setState(() => _filter = f),
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        color: AppColors.primary,
                        backgroundColor: colors.surfaceLight,
                        onRefresh: () => context.read<BlacklistCubit>().load(),
                        child: filtered.isEmpty
                            ? _NoMatchState(filter: _filter)
                            : ListView.builder(
                                padding: PaddingManager.paddingVertical8,
                                physics: const AlwaysScrollableScrollPhysics(
                                  parent: BouncingScrollPhysics(),
                                ),
                                itemCount: filtered.length,
                                itemBuilder: (context, i) {
                                  final entry = filtered[i];
                                  final tile =
                                      BlacklistTile(
                                            entry: entry,
                                            onDelete: () => context
                                                .read<BlacklistCubit>()
                                                .remove(entry.ip),
                                          )
                                          .animate()
                                          .fadeIn(
                                            duration: 250.ms,
                                            delay: Duration(
                                              milliseconds: i < 8 ? i * 30 : 0,
                                            ),
                                          )
                                          .slideX(
                                            begin: 0.02,
                                            end: 0,
                                            duration: 250.ms,
                                          );
                                  if (i == filtered.length - 1) {
                                    return Column(
                                      children: [tile, SpacesManager.h150],
                                    );
                                  }
                                  return tile;
                                },
                              ),
                      ),
                    ),
                  ],
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
            style: TextButton.styleFrom(
              foregroundColor: AppColors.statusDanger,
            ),
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
            label: Text(
              'Clear All',
              style: getRegularTextStyle(fontSize: FontSizesManager.s13),
            ),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.statusDanger,
            ),
          ),
        SpacesManager.w4,
      ],
    );
  }
}

class _FilterBar extends StatelessWidget {
  final _BlacklistFilter filter;
  final int all;
  final int ai;
  final int manual;
  final ValueChanged<_BlacklistFilter> onChanged;

  const _FilterBar({
    required this.filter,
    required this.all,
    required this.ai,
    required this.manual,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: PaddingManager.paddingH16V8,
      child: Row(
        children: [
          _FilterChip(
            label: 'All',
            count: all,
            color: AppColors.primary,
            selected: filter == _BlacklistFilter.all,
            onTap: () => onChanged(_BlacklistFilter.all),
          ),
          SpacesManager.w8,
          _FilterChip(
            label: 'AI Block',
            count: ai,
            color: AppColors.statusDanger,
            selected: filter == _BlacklistFilter.ai,
            onTap: () => onChanged(_BlacklistFilter.ai),
          ),
          SpacesManager.w8,
          _FilterChip(
            label: 'Manual',
            count: manual,
            color: AppColors.primary,
            selected: filter == _BlacklistFilter.manual,
            onTap: () => onChanged(_BlacklistFilter.manual),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.count,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return AppPressable(
      onPressed: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: PaddingManager.paddingH12V7,
        decoration: DecorationManager.filterChip(
          colors,
          color,
          selected: selected,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: getSemiBoldTextStyle(
                fontSize: FontSizesManager.s12,
                color: selected ? color : colors.textSecondary,
              ),
            ),
            SpacesManager.w6,
            Container(
              padding: PaddingManager.paddingH6V1,
              decoration: DecorationManager.tinted(
                selected ? color : colors.textMuted,
                BorderRadiusManager.radiusAll6,
                alpha: selected ? 0.18 : 0.12,
              ),
              child: Text(
                '$count',
                style: getBoldTextStyle(
                  fontSize: FontSizesManager.s10,
                  color: selected ? color : colors.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoMatchState extends StatelessWidget {
  final _BlacklistFilter filter;
  const _NoMatchState({required this.filter});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final label = filter == _BlacklistFilter.manual
        ? 'No manually blocked IPs'
        : 'No AI-blocked IPs';
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      children: [
        SpacesManager.h64,
        Column(
          children: [
            Icon(
              Icons.filter_alt_off_rounded,
              size: 40,
              color: colors.textDisabled,
            ),
            SpacesManager.h12,
            Text(
              label,
              textAlign: TextAlign.center,
              style: getSemiBoldTextStyle(
                fontSize: FontSizesManager.s14,
                color: colors.textMuted,
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(duration: 300.ms);
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Center(
      child:
          Column(
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
                    style: getRegularTextStyle(
                      fontSize: FontSizesManager.s14,
                      color: colors.textDisabled,
                      height: 1.5,
                    ),
                  ),
                ],
              )
              .animate()
              .fadeIn(duration: 500.ms)
              .slideY(begin: 0.04, end: 0, duration: 500.ms),
    );
  }
}
