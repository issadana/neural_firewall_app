import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Sentri/core/resources/font_manager.dart';
import 'package:Sentri/core/resources/text_style_manager.dart';
import 'package:Sentri/core/theme/app_colors.dart';
import '../../domain/entities/chat_session.dart';
import '../../domain/usecases/get_sessions_usecase.dart';
import '../bloc/chat_cubit.dart';

class ChatHistoryScreen extends StatefulWidget {
  const ChatHistoryScreen({super.key});

  @override
  State<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen> {
  List<ChatSession> _sessions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final useCase = context.read<GetSessionsUseCase>();
      final result = await useCase();
      if (mounted) setState(() { _sessions = result; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Drawer(
      backgroundColor: colors.background,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Text(
                    'Chat History',
                    style: getBoldTextStyle(fontSize: FontSizesManager.s16, color: colors.textPrimary),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.close, color: colors.textMuted),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Container(height: 0.5, color: colors.borderColor),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                  : _sessions.isEmpty
                      ? Center(
                          child: Text('No previous sessions',
                              style: TextStyle(color: colors.textMuted)),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: _sessions.length,
                          itemBuilder: (context, index) {
                            final session = _sessions[index];
                            return ListTile(
                              leading: Icon(Icons.chat_bubble_outline,
                                  color: AppColors.primary, size: 20),
                              title: Text(
                                session.title ?? 'Session ${session.id}',
                                style: getRegularTextStyle(fontSize: FontSizesManager.s13, color: colors.textPrimary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                _formatDate(session.createdAt),
                                style: getRegularTextStyle(fontSize: FontSizesManager.s11, color: colors.textDisabled),
                              ),
                              onTap: () {
                                Navigator.of(context).pop();
                                context
                                    .read<ChatCubit>()
                                    .loadSession(session.id);
                              },
                              trailing: IconButton(
                                icon: Icon(Icons.delete_outline,
                                    color: colors.textDisabled, size: 18),
                                onPressed: () async {
                                  await context
                                      .read<ChatCubit>()
                                      .deleteSession(session.id);
                                  _load();
                                },
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
