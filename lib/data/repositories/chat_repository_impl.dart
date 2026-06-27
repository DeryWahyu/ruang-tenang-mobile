import '../../domain/entities/chat.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/remote/chat_remote_datasource.dart';
import '../models/chat_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource _remote;

  ChatRepositoryImpl({required ChatRemoteDataSource remote}) : _remote = remote;

  @override
  Future<ChatSessionListResult> getSessions({int page = 1, int limit = 20}) async {
    final result = await _remote.getSessions(page: page, limit: limit);
    return result.toEntity();
  }

  @override
  Future<ChatSession> getSession(String uuid) async {
    final session = await _remote.getSession(uuid);
    return session.toEntity();
  }

  @override
  Future<ChatSession> createSession(String title, {int? folderId}) async {
    final session = await _remote.createSession(title, folderId: folderId);
    return session.toEntity();
  }

  @override
  Future<void> deleteSession(String uuid) async {
    await _remote.deleteSession(uuid);
  }

  @override
  Future<({ChatMessage userMessage, ChatMessage aiMessage})> sendMessage(
      String uuid, String content) async {
    final result = await _remote.sendMessage(uuid, content);
    final userMessageModel = result['user_message'] as ChatMessageModel;
    final aiMessageModel = result['ai_message'] as ChatMessageModel;

    return (
      userMessage: userMessageModel.toEntity(),
      aiMessage: aiMessageModel.toEntity(),
    );
  }

  @override
  Future<void> toggleLikeMessage(int messageId) async {
    await _remote.toggleLikeMessage(messageId);
  }

  @override
  Future<void> toggleDislikeMessage(int messageId) async {
    await _remote.toggleDislikeMessage(messageId);
  }
}
