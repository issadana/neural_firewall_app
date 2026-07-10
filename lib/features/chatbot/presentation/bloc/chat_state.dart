import 'package:equatable/equatable.dart';
import '../../domain/entities/chat_message.dart';

enum ChatStatus { initial, streaming, ready, error }

class ChatState extends Equatable {
  final ChatStatus status;
  final List<ChatMessage> messages;
  final List<String> suggestions;
  final String? errorMessage;

  const ChatState({
    this.status = ChatStatus.initial,
    this.messages = const [],
    this.suggestions = const [
      'Who is attacking me?',
      'Top threats today',
      'Is my device safe?',
    ],
    this.errorMessage,
  });

  bool get isStreaming => status == ChatStatus.streaming;

  ChatState copyWith({
    ChatStatus? status,
    List<ChatMessage>? messages,
    List<String>? suggestions,
    String? errorMessage,
  }) =>
      ChatState(
        status: status ?? this.status,
        messages: messages ?? this.messages,
        suggestions: suggestions ?? this.suggestions,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props => [status, messages, suggestions, errorMessage];
}
