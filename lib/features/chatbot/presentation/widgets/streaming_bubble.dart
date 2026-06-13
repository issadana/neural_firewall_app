import 'package:flutter/material.dart';
import 'package:Sentri/core/resources/decoration_manager.dart';
import 'package:Sentri/core/resources/font_manager.dart';
import 'package:Sentri/core/resources/padding_manager.dart';
import 'package:Sentri/core/resources/text_style_manager.dart';
import 'package:Sentri/core/theme/app_colors.dart';
import '../../domain/entities/chat_message.dart';

class StreamingBubble extends StatefulWidget {
  final ChatMessage message;

  const StreamingBubble({super.key, required this.message});

  @override
  State<StreamingBubble> createState() => _StreamingBubbleState();
}

class _StreamingBubbleState extends State<StreamingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _cursorCtrl;

  @override
  void initState() {
    super.initState();
    _cursorCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 530),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _cursorCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isStreaming = widget.message.isStreaming;
    final content = widget.message.content;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        margin: PaddingManager.bubbleMargin,
        padding: PaddingManager.paddingH14V10,
        decoration: DecorationManager.aiBubble(colors),
        child: content.isEmpty && isStreaming
            ? _ThinkingDots()
            : RichText(
                text: TextSpan(
                  style: getRegularTextStyle(
                    fontSize: FontSizesManager.s14,
                    color: colors.textPrimary,
                    height: 1.5,
                  ),
                  children: [
                    TextSpan(text: content),
                    if (isStreaming)
                      WidgetSpan(
                        child: AnimatedBuilder(
                          animation: _cursorCtrl,
                          builder: (_, _) => Opacity(
                            opacity: _cursorCtrl.value,
                            child: Text(
                              '▌',
                              style: getRegularTextStyle(
                                fontSize: FontSizesManager.s14,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _ThinkingDots extends StatefulWidget {
  @override
  State<_ThinkingDots> createState() => _ThinkingDotsState();
}

class _ThinkingDotsState extends State<_ThinkingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) {
        final dot = (_ctrl.value * 3).floor();
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            3,
            (i) => Container(
              margin: PaddingManager.paddingHorizontal2,
              width: 6,
              height: 6,
              decoration: DecorationManager.thinkingDot(dot == i ? 0.9 : 0.3),
            ),
          ),
        );
      },
    );
  }
}
