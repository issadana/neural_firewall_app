import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Sentri/core/resources/font_manager.dart';
import 'package:Sentri/core/resources/text_style_manager.dart';
import 'package:Sentri/core/theme/app_colors.dart';
import '../bloc/chat_cubit.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/message_bubble.dart';
import '../widgets/streaming_bubble.dart';
import '../widgets/suggestion_chips.dart';
import 'chat_history_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
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
        title: const Text('Neural Assistant'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: colors.borderColor),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            onPressed: () => Scaffold.of(context).openEndDrawer(),
          ),
          IconButton(
            icon: const Icon(Icons.add_comment_outlined),
            onPressed: () => context.read<ChatCubit>().startNewChat(),
          ),
        ],
      ),
      endDrawer: const ChatHistoryScreen(),
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
                        padding: const EdgeInsets.symmetric(vertical: 12),
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
                const SizedBox(height: 4),
                SuggestionChips(
                  suggestions: state.suggestions,
                  onTap: (text) => context.read<ChatCubit>().sendMessage(text),
                ),
                const SizedBox(height: 4),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shield_outlined, size: 52, color: colors.textDisabled),
          const SizedBox(height: 16),
          Text(
            'Your AI Security Assistant',
            style: getSemiBoldTextStyle(fontSize: FontSizesManager.s16, color: colors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'Ask anything about your network activity',
            style: getRegularTextStyle(fontSize: FontSizesManager.s13, color: colors.textMuted),
          ),
        ],
      ),
    );
  }
}
