class ChatSession {
  final int id;
  final String? title;
  final DateTime createdAt;

  const ChatSession({
    required this.id,
    this.title,
    required this.createdAt,
  });

  factory ChatSession.fromJson(Map<String, dynamic> json) => ChatSession(
        id: json['id'] as int,
        title: json['title'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}
