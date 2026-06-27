import '../../entities/chat.dart';
import '../../repositories/chat_repository.dart';

class GetChatSessionsUseCase {
  final ChatRepository _repository;
  GetChatSessionsUseCase(this._repository);

  Future<ChatSessionListResult> call({int page = 1, int limit = 20}) =>
      _repository.getSessions(page: page, limit: limit);
}

class GetChatSessionUseCase {
  final ChatRepository _repository;
  GetChatSessionUseCase(this._repository);

  Future<ChatSession> call(String uuid) => _repository.getSession(uuid);
}

class CreateChatSessionUseCase {
  final ChatRepository _repository;
  CreateChatSessionUseCase(this._repository);

  Future<ChatSession> call(String title, {int? folderId}) =>
      _repository.createSession(title, folderId: folderId);
}

class DeleteChatSessionUseCase {
  final ChatRepository _repository;
  DeleteChatSessionUseCase(this._repository);

  Future<void> call(String uuid) => _repository.deleteSession(uuid);
}

class SendChatMessageUseCase {
  final ChatRepository _repository;
  SendChatMessageUseCase(this._repository);

  Future<({ChatMessage userMessage, ChatMessage aiMessage})> call(
          String uuid, String content) =>
      _repository.sendMessage(uuid, content);
}

class ToggleLikeMessageUseCase {
  final ChatRepository _repository;
  ToggleLikeMessageUseCase(this._repository);

  Future<void> call(int messageId) => _repository.toggleLikeMessage(messageId);
}

class ToggleDislikeMessageUseCase {
  final ChatRepository _repository;
  ToggleDislikeMessageUseCase(this._repository);

  Future<void> call(int messageId) => _repository.toggleDislikeMessage(messageId);
}

class ChatUseCases {
  final GetChatSessionsUseCase getSessions;
  final GetChatSessionUseCase getSession;
  final CreateChatSessionUseCase createSession;
  final DeleteChatSessionUseCase deleteSession;
  final SendChatMessageUseCase sendMessage;
  final ToggleLikeMessageUseCase toggleLikeMessage;
  final ToggleDislikeMessageUseCase toggleDislikeMessage;

  const ChatUseCases({
    required this.getSessions,
    required this.getSession,
    required this.createSession,
    required this.deleteSession,
    required this.sendMessage,
    required this.toggleLikeMessage,
    required this.toggleDislikeMessage,
  });
}
