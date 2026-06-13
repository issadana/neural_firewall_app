import 'package:flutter/material.dart';
import 'package:Sentri/core/resources/decoration_manager.dart';
import 'package:Sentri/core/resources/font_manager.dart';
import 'package:Sentri/core/resources/text_style_manager.dart';
import 'package:Sentri/core/theme/app_colors.dart';
import '../../domain/entities/chat_message.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({super.key, required this.message});

  bool get _isUser => message.role == 'user';

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Align(
      alignment: _isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        margin: EdgeInsets.only(
          top: 4,
          bottom: 4,
          left: _isUser ? 48 : 16,
          right: _isUser ? 16 : 48,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: _isUser
            ? DecorationManager.userChatBubble
            : DecorationManager.aiBubble(colors),
        child: Text(
          message.content,
          style: getRegularTextStyle(
            fontSize: FontSizesManager.s14,
            color: colors.textPrimary,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}
