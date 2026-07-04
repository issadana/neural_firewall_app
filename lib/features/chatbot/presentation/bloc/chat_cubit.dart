import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/usecases/send_message_usecase.dart';
import 'chat_state.dart';

export 'chat_state.dart';

/// Drives the instant Nova chat. Stateless: no history, no sessions — the
/// conversation lives only in memory for the lifetime of the screen.
class ChatCubit extends Cubit<ChatState> {
  final SendMessageUseCase _sendMessage;

  ChatCubit({required SendMessageUseCase sendMessage})
      : _sendMessage = sendMessage,
        super(const ChatState());

  Future<void> sendMessage(String text) async {
    if (state.isStreaming || text.trim().isEmpty) return;

    final userMsg = ChatMessage(role: 'user', content: text.trim());
    final assistantMsg =
        const ChatMessage(role: 'assistant', content: '', isStreaming: true);

    emit(state.copyWith(
      status: ChatStatus.streaming,
      messages: [...state.messages, userMsg, assistantMsg],
    ));

    var accumulated = '';
    try {
      await for (final chunk in _sendMessage(text.trim())) {
        accumulated += chunk;
        final updated = List<ChatMessage>.from(state.messages);
        updated[updated.length - 1] =
            updated.last.copyWith(content: accumulated, isStreaming: true);
        emit(state.copyWith(status: ChatStatus.streaming, messages: updated));
      }

      final finalMessages = List<ChatMessage>.from(state.messages);
      finalMessages[finalMessages.length - 1] =
          finalMessages.last.copyWith(isStreaming: false);
      emit(state.copyWith(status: ChatStatus.ready, messages: finalMessages));
    } catch (e) {
      final errorMessages = List<ChatMessage>.from(state.messages);
      errorMessages[errorMessages.length - 1] = const ChatMessage(
        role: 'assistant',
        content: 'Sorry, something went wrong. Please try again.',
      );
      emit(state.copyWith(
        status: ChatStatus.error,
        messages: errorMessages,
        errorMessage: e.toString(),
      ));
    }
  }

  void startNewChat() => emit(const ChatState());
}
