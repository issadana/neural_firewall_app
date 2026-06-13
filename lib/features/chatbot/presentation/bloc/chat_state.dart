import 'package:equatable/equatable.dart';
import '../../domain/entities/chat_message.dart';

enum ChatStatus { initial, loading, ready, streaming, error }

class ChatState extends Equatable {
  final ChatStatus status;
  final List<ChatMessage> messages;
  final int? sessionId;
  final List<String> suggestions;
  final bool digestLoaded;
  final String? errorMessage;

  const ChatState({
    this.status = ChatStatus.initial,
    this.messages = const [],
    this.sessionId,
    this.suggestions = const [
      'Who is attacking me?',
      'Top threats today',
      'Is my device safe?',
    ],
    this.digestLoaded = false,
    this.errorMessage,
  });

  bool get isStreaming => status == ChatStatus.streaming;

  ChatState copyWith({
    ChatStatus? status,
    List<ChatMessage>? messages,
    int? sessionId,
    List<String>? suggestions,
    bool? digestLoaded,
    String? errorMessage,
  }) =>
      ChatState(
        status: status ?? this.status,
        messages: messages ?? this.messages,
        sessionId: sessionId ?? this.sessionId,
        suggestions: suggestions ?? this.suggestions,
        digestLoaded: digestLoaded ?? this.digestLoaded,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props =>
      [status, messages, sessionId, suggestions, digestLoaded, errorMessage];
}
