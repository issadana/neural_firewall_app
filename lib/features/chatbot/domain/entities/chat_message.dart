class ChatMessage {
  final int? id;
  final int sessionId;
  final String role;
  final String content;
  final DateTime createdAt;
  final bool isStreaming;

  const ChatMessage({
    this.id,
    required this.sessionId,
    required this.role,
    required this.content,
    required this.createdAt,
    this.isStreaming = false,
  });

  ChatMessage copyWith({String? content, bool? isStreaming}) => ChatMessage(
        id: id,
        sessionId: sessionId,
        role: role,
        content: content ?? this.content,
        createdAt: createdAt,
        isStreaming: isStreaming ?? this.isStreaming,
      );

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'] as int?,
        sessionId: json['session_id'] as int,
        role: json['role'] as String,
        content: json['content'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}
