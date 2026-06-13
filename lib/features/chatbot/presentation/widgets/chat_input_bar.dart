import 'package:flutter/material.dart';
import 'package:Sentri/core/resources/border_radius_manager.dart';
import 'package:Sentri/core/resources/color_manager.dart';
import 'package:Sentri/core/resources/decoration_manager.dart';
import 'package:Sentri/core/resources/font_manager.dart';
import 'package:Sentri/core/resources/padding_manager.dart';
import 'package:Sentri/core/resources/spaces_manager.dart';
import 'package:Sentri/core/resources/text_style_manager.dart';
import 'package:Sentri/core/theme/app_colors.dart';
import 'package:Sentri/core/widgets/pressable_buttons/app_pressable.dart';

class ChatInputBar extends StatefulWidget {
  final bool disabled;
  final ValueChanged<String> onSend;

  const ChatInputBar({
    super.key,
    required this.disabled,
    required this.onSend,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _ctrl.text.trim();
    if (text.isEmpty || widget.disabled) return;
    _ctrl.clear();
    widget.onSend(text);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: PaddingManager.paddingLTRB16_8_16_8,
      decoration: DecorationManager.topBorder(colors),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _ctrl,
                enabled: !widget.disabled,
                maxLines: 4,
                minLines: 1,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _submit(),
                style: getRegularTextStyle(fontSize: FontSizesManager.s14, color: colors.textPrimary),
                decoration: DecorationManager.inputField(
                  colors,
                  hintText: 'Ask about your security…',
                  radius: BorderRadiusManager.radiusAll20,
                  isDense: true,
                  contentPadding: PaddingManager.paddingH14V10,
                  borderWidth: 0.5,
                ),
              ),
            ),
            SpacesManager.w8,
            AnimatedOpacity(
              opacity: widget.disabled ? 0.4 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: AppPressable(
                onPressed: widget.disabled ? null : _submit,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: DecorationManager.sendButton,
                  child: const Icon(Icons.send_rounded, color: ColorManager.white, size: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
