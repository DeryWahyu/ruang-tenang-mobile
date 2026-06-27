import '../entities/chat.dart';

abstract class ChatRepository {
  Future<ChatSessionListResult> getSessions({int page = 1, int limit = 20});
  Future<ChatSession> getSession(String uuid);
  Future<ChatSession> createSession(String title, {int? folderId});
  Future<void> deleteSession(String uuid);

  /// Returns a record of the saved user message and the generated AI message.
  Future<({ChatMessage userMessage, ChatMessage aiMessage})> sendMessage(
    String uuid,
    String content,
  );

  Future<void> toggleLikeMessage(int messageId);
  Future<void> toggleDislikeMessage(int messageId);
}
