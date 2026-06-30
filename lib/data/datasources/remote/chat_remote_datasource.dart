import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../models/chat_model.dart';

class ChatRemoteDataSource {
  final ApiClient _apiClient;

  ChatRemoteDataSource(this._apiClient);

  /// GET /chat-sessions?page=&limit=
  Future<ChatSessionListResultModel> getSessions({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _apiClient.getPaginated<ChatSessionListItemModel>(
      ApiConstants.chatSessions,
      queryParameters: {
        'page': page,
        'limit': limit,
      },
      fromJson: (json) => ChatSessionListItemModel.fromJson(json),
    );

    return ChatSessionListResultModel(
      items: response.data,
      total: response.totalItems,
      page: response.page,
      limit: response.limit,
    );
  }

  /// GET /chat-sessions/:uuid
  Future<ChatSessionModel> getSession(String uuid) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '${ApiConstants.chatSessions}/$uuid',
      fromJson: (json) => Map<String, dynamic>.from(json as Map),
    );

    if (!response.success || response.data == null) {
      throw Exception(response.error ?? 'Gagal memuat sesi chat');
    }

    return ChatSessionModel.fromJson(response.data!);
  }

  /// POST /chat-sessions
  Future<ChatSessionModel> createSession(String title, {int? folderId}) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.chatSessions,
      data: {
        'title': title,
        'folder_id': ?folderId,
      },
      fromJson: (json) => Map<String, dynamic>.from(json as Map),
    );

    if (!response.success || response.data == null) {
      throw Exception(response.error ?? 'Gagal membuat sesi chat');
    }

    return ChatSessionModel.fromJson(response.data!);
  }

  /// DELETE /chat-sessions/:uuid
  Future<void> deleteSession(String uuid) async {
    final response = await _apiClient.delete<dynamic>(
      '${ApiConstants.chatSessions}/$uuid',
    );

    if (!response.success) {
      throw Exception(response.error ?? 'Gagal menghapus sesi chat');
    }
  }

  /// POST /chat-sessions/:uuid/messages
  Future<Map<String, dynamic>> sendMessage(String uuid, String content) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '${ApiConstants.chatSessions}/$uuid/messages',
      data: {
        'content': content,
        'type': 'text',
      },
      fromJson: (json) => Map<String, dynamic>.from(json as Map),
    );

    if (!response.success || response.data == null) {
      throw Exception(response.error ?? 'Gagal mengirim pesan');
    }

    return {
      'user_message': ChatMessageModel.fromJson(
          Map<String, dynamic>.from(response.data!['user_message'] as Map)),
      'ai_message': ChatMessageModel.fromJson(
          Map<String, dynamic>.from(response.data!['ai_message'] as Map)),
    };
  }

  /// PUT /chat-messages/:id/like
  Future<void> toggleLikeMessage(int messageId) async {
    final response = await _apiClient.put<dynamic>(
      '${ApiConstants.chatMessages}/$messageId/like',
    );

    if (!response.success) {
      throw Exception(response.error ?? 'Gagal memperbarui status like');
    }
  }

  /// PUT /chat-messages/:id/dislike
  Future<void> toggleDislikeMessage(int messageId) async {
    final response = await _apiClient.put<dynamic>(
      '${ApiConstants.chatMessages}/$messageId/dislike',
    );

    if (!response.success) {
      throw Exception(response.error ?? 'Gagal memperbarui status dislike');
    }
  }
}
