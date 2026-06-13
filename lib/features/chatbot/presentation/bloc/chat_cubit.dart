import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/usecases/delete_session_usecase.dart';
import '../../domain/usecases/get_digest_usecase.dart';
import '../../domain/usecases/get_session_messages_usecase.dart';
import '../../domain/usecases/send_message_usecase.dart';
import 'chat_state.dart';

export 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final SendMessageUseCase _sendMessage;
  final GetDigestUseCase _getDigest;
  final GetSessionMessagesUseCase _getSessionMessages;
  final DeleteSessionUseCase _deleteSession;

  ChatCubit({
    required SendMessageUseCase sendMessage,
    required GetDigestUseCase getDigest,
    required GetSessionMessagesUseCase getSessionMessages,
    required DeleteSessionUseCase deleteSession,
  })  : _sendMessage = sendMessage,
        _getDigest = getDigest,
        _getSessionMessages = getSessionMessages,
        _deleteSession = deleteSession,
        super(const ChatState());

  Future<void> openChat() async {
    if (state.digestLoaded) return;
    try {
      final digest = await _getDigest();
      if (digest.isNotEmpty) {
        final digestMsg = ChatMessage(
          sessionId: 0,
          role: 'assistant',
          content: digest,
          createdAt: DateTime.now(),
        );
        emit(state.copyWith(
          status: ChatStatus.ready,
          messages: [digestMsg],
          digestLoaded: true,
        ));
      } else {
        emit(state.copyWith(status: ChatStatus.ready, digestLoaded: true));
      }
    } catch (_) {
      emit(state.copyWith(status: ChatStatus.ready, digestLoaded: true));
    }
  }

  Future<void> sendMessage(String text) async {
    if (state.isStreaming || text.trim().isEmpty) return;

    final userMsg = ChatMessage(
      sessionId: state.sessionId ?? 0,
      role: 'user',
      content: text.trim(),
      createdAt: DateTime.now(),
    );

    final assistantMsg = ChatMessage(
      sessionId: state.sessionId ?? 0,
      role: 'assistant',
      content: '',
      createdAt: DateTime.now(),
      isStreaming: true,
    );

    emit(state.copyWith(
      status: ChatStatus.streaming,
      messages: [...state.messages, userMsg, assistantMsg],
    ));

    var accumulated = '';
    try {
      await for (final chunk in _sendMessage(text.trim(), state.sessionId)) {
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
      errorMessages[errorMessages.length - 1] = ChatMessage(
        sessionId: state.sessionId ?? 0,
        role: 'assistant',
        content: 'Sorry, something went wrong. Please try again.',
        createdAt: DateTime.now(),
      );
      emit(state.copyWith(
        status: ChatStatus.error,
        messages: errorMessages,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> loadSession(int sessionId) async {
    emit(state.copyWith(status: ChatStatus.loading));
    try {
      final msgs = await _getSessionMessages(sessionId);
      emit(state.copyWith(
        status: ChatStatus.ready,
        messages: msgs,
        sessionId: sessionId,
        digestLoaded: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ChatStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> deleteSession(int sessionId) async {
    await _deleteSession(sessionId);
    emit(const ChatState());
  }

  void startNewChat() => emit(const ChatState());
}
