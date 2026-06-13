import 'package:flutter/material.dart';
import 'package:Sentri/core/resources/decoration_manager.dart';
import 'package:Sentri/core/resources/font_manager.dart';
import 'package:Sentri/core/resources/text_style_manager.dart';
import 'package:Sentri/core/theme/app_colors.dart';

class ThreatFilterBar extends StatelessWidget {
  final String? selectedAction;
  final ValueChanged<String?> onActionChanged;
  final VoidCallback onClear;

  const ThreatFilterBar({
    super.key,
    required this.selectedAction,
    required this.onActionChanged,
    required this.onClear,
  });

  static const _actions = ['blocked', 'warned', 'allowed'];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _FilterChip(
            label: 'All',
            selected: selectedAction == null,
            color: AppColors.primary,
            onTap: () => onActionChanged(null),
          ),
          const SizedBox(width: 8),
          ..._actions.map((a) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _FilterChip(
                  label: _label(a),
                  selected: selectedAction == a,
                  color: _color(a),
                  onTap: () => onActionChanged(selectedAction == a ? null : a),
                ),
              )),
        ],
      ),
    );
  }

  String _label(String action) => switch (action) {
        'blocked' => 'Blocked',
        'warned' => 'Warned',
        'allowed' => 'Allowed',
        _ => action,
      };

  Color _color(String action) => switch (action) {
        'blocked' => AppColors.statusDanger,
        'warned' => AppColors.statusWarning,
        'allowed' => AppColors.statusNormal,
        _ => AppColors.primary,
      };
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: DecorationManager.filterChip(colors, color, selected: selected),
        child: Text(
          label,
          style: selected
              ? getBoldTextStyle(fontSize: FontSizesManager.s12, color: color)
              : getMediumTextStyle(fontSize: FontSizesManager.s12, color: colors.textSecondary),
        ),
      ),
    );
  }
}
