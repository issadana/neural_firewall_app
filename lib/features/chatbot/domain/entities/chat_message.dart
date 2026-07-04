/// A single message in an instant Nova chat. Purely in-memory — the backend
/// keeps no history, so there is no id, session or persistence.
class ChatMessage {
  final String role; // 'user' | 'assistant'
  final String content;
  final bool isStreaming;

  const ChatMessage({
    required this.role,
    required this.content,
    this.isStreaming = false,
  });

  ChatMessage copyWith({String? content, bool? isStreaming}) => ChatMessage(
        role: role,
        content: content ?? this.content,
        isStreaming: isStreaming ?? this.isStreaming,
      );
}
