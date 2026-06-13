import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Sentri/core/resources/color_manager.dart';
import 'package:Sentri/core/resources/decoration_manager.dart';
import 'package:Sentri/core/resources/font_manager.dart';
import 'package:Sentri/core/resources/padding_manager.dart';
import 'package:Sentri/core/resources/spaces_manager.dart';
import 'package:Sentri/core/resources/text_style_manager.dart';
import 'package:Sentri/core/theme/app_colors.dart';
import '../bloc/chat_cubit.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/message_bubble.dart';
import '../widgets/streaming_bubble.dart';
import '../widgets/suggestion_chips.dart';

/// Instant chat with Nova — the Sentri AI assistant.
class NovaChatScreen extends StatefulWidget {
  const NovaChatScreen({super.key});

  @override
  State<NovaChatScreen> createState() => _NovaChatScreenState();
}

class _NovaChatScreenState extends State<NovaChatScreen> {
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<ChatCubit>().openChat();
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _NovaAvatar(size: 34),
            SpacesManager.w10,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Nova',
                  style: getBoldTextStyle(fontSize: FontSizesManager.s16, color: colors.textPrimary),
                ),
                Text(
                  'Sentri AI Assistant',
                  style: getRegularTextStyle(fontSize: FontSizesManager.s11, color: AppColors.accent),
                ),
              ],
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: colors.borderColor),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment_outlined),
            tooltip: 'New chat',
            onPressed: () => context.read<ChatCubit>().startNewChat(),
          ),
        ],
      ),
      body: BlocConsumer<ChatCubit, ChatState>(
        listener: (context, state) => _scrollToBottom(),
        builder: (context, state) {
          return Column(
            children: [
              Expanded(
                child: state.messages.isEmpty
                    ? _EmptyState()
                    : ListView.builder(
                        controller: _scrollCtrl,
                        physics: const BouncingScrollPhysics(),
                        padding: PaddingManager.paddingVertical12,
                        itemCount: state.messages.length,
                        itemBuilder: (context, index) {
                          final msg = state.messages[index];
                          if (msg.isStreaming) {
                            return StreamingBubble(key: ValueKey(index), message: msg);
                          }
                          return MessageBubble(key: ValueKey(index), message: msg);
                        },
                      ),
              ),
              if (!state.isStreaming && state.suggestions.isNotEmpty) ...[
                SpacesManager.h4,
                SuggestionChips(
                  suggestions: state.suggestions,
                  onTap: (text) => context.read<ChatCubit>().sendMessage(text),
                ),
                SpacesManager.h4,
              ],
              ChatInputBar(
                disabled: state.isStreaming,
                onSend: (text) => context.read<ChatCubit>().sendMessage(text),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Center(
      child: Padding(
        padding: PaddingManager.paddingHorizontal24,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _NovaAvatar(size: 72),
            SpacesManager.h16,
            Text(
              "Hi, I'm Nova",
              style: getBoldTextStyle(fontSize: FontSizesManager.s18, color: colors.textPrimary),
            ),
            SpacesManager.h8,
            Text(
              'Your Sentri security assistant. Ask me about threats, blocked IPs, or anything in your network activity.',
              textAlign: TextAlign.center,
              style: getRegularTextStyle(fontSize: FontSizesManager.s13, color: colors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

/// Gradient avatar disc with a sparkle — Nova's identity mark.
class _NovaAvatar extends StatelessWidget {
  const _NovaAvatar({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: DecorationManager.novaAvatar,
      child: Icon(Icons.auto_awesome_rounded, color: ColorManager.white, size: size * 0.5),
    );
  }
}
