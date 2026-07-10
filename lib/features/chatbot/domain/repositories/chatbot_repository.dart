/// Contract for the Nova assistant. The backend is stateless — every request
/// is answered on its own, with no history, sessions or digest.
abstract class ChatbotRepository {
  /// Streams the assistant's reply to [message] token-by-token.
  Stream<String> sendMessage(String message);
}
