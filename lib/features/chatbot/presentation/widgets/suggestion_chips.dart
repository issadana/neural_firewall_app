import 'package:flutter/material.dart';
import 'package:Sentri/core/resources/decoration_manager.dart';
import 'package:Sentri/core/resources/font_manager.dart';
import 'package:Sentri/core/resources/padding_manager.dart';
import 'package:Sentri/core/resources/spaces_manager.dart';
import 'package:Sentri/core/resources/text_style_manager.dart';
import 'package:Sentri/core/theme/app_colors.dart';
import 'package:Sentri/core/widgets/pressable_buttons/app_pressable.dart';

class SuggestionChips extends StatelessWidget {
  final List<String> suggestions;
  final ValueChanged<String> onTap;

  const SuggestionChips({
    super.key,
    required this.suggestions,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: PaddingManager.paddingHorizontal16,
        itemCount: suggestions.length,
        separatorBuilder: (_, _) => SpacesManager.w8,
        itemBuilder: (_, index) {
          final text = suggestions[index];
          return AppPressable(
            onPressed: () => onTap(text),
            child: Container(
              padding: PaddingManager.paddingH14V7,
              decoration: DecorationManager.suggestionChip,
              child: Text(
                text,
                style: getMediumTextStyle(
                  fontSize: FontSizesManager.s12,
                  color: AppColors.primary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
