import 'package:equatable/equatable.dart';

/// A single message within a chat session.
class ChatMessage extends Equatable {
  final int id;
  final String role;
  final String content;
  final String type;
  final bool isLiked;
  final bool isDisliked;
  final bool isPinned;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.type,
    this.isLiked = false,
    this.isDisliked = false,
    this.isPinned = false,
    required this.createdAt,
  });

  ChatMessage copyWith({
    int? id,
    String? role,
    String? content,
    String? type,
    bool? isLiked,
    bool? isDisliked,
    bool? isPinned,
    DateTime? createdAt,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      type: type ?? this.type,
      isLiked: isLiked ?? this.isLiked,
      isDisliked: isDisliked ?? this.isDisliked,
      isPinned: isPinned ?? this.isPinned,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isUser => role == 'user';
  bool get isAI => role == 'assistant' || role == 'model';

  @override
  List<Object?> get props => [
        id,
        role,
        content,
        type,
        isLiked,
        isDisliked,
        isPinned,
        createdAt,
      ];
}

/// A full chat session including its messages.
class ChatSession extends Equatable {
  final int id;
  final String uuid;
  final String title;
  final int? folderId;
  final String? folderName;
  final String? summary;
  final bool isFavorite;
  final bool isTrash;
  final ChatMessage? lastMessage;
  final List<ChatMessage> messages;
  final List<ChatMessage> pinnedMessages;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ChatSession({
    required this.id,
    required this.uuid,
    required this.title,
    this.folderId,
    this.folderName,
    this.summary,
    this.isFavorite = false,
    this.isTrash = false,
    this.lastMessage,
    this.messages = const [],
    this.pinnedMessages = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  ChatSession copyWith({
    int? id,
    String? uuid,
    String? title,
    int? folderId,
    String? folderName,
    String? summary,
    bool? isFavorite,
    bool? isTrash,
    ChatMessage? lastMessage,
    List<ChatMessage>? messages,
    List<ChatMessage>? pinnedMessages,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChatSession(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      title: title ?? this.title,
      folderId: folderId ?? this.folderId,
      folderName: folderName ?? this.folderName,
      summary: summary ?? this.summary,
      isFavorite: isFavorite ?? this.isFavorite,
      isTrash: isTrash ?? this.isTrash,
      lastMessage: lastMessage ?? this.lastMessage,
      messages: messages ?? this.messages,
      pinnedMessages: pinnedMessages ?? this.pinnedMessages,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        uuid,
        title,
        isFavorite,
        isTrash,
        lastMessage,
        messages,
        updatedAt,
      ];
}

/// A lightweight representation of a chat session for list views.
class ChatSessionListItem extends Equatable {
  final int id;
  final String uuid;
  final String title;
  final int? folderId;
  final bool isFavorite;
  final bool isTrash;
  final bool hasSummary;
  final String lastMessage;
  final DateTime createdAt;

  const ChatSessionListItem({
    required this.id,
    required this.uuid,
    required this.title,
    this.folderId,
    this.isFavorite = false,
    this.isTrash = false,
    this.hasSummary = false,
    required this.lastMessage,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        uuid,
        title,
        isFavorite,
        isTrash,
        hasSummary,
        lastMessage,
        createdAt,
      ];
}

/// Paginated wrapper for list of sessions.
class ChatSessionListResult extends Equatable {
  final List<ChatSessionListItem> items;
  final int total;
  final int page;
  final int limit;

  const ChatSessionListResult({
    this.items = const [],
    this.total = 0,
    this.page = 1,
    this.limit = 10,
  });

  int get totalPages => limit > 0 ? (total / limit).ceil() : 0;
  bool get hasNextPage => page < totalPages;

  @override
  List<Object?> get props => [items, total, page, limit];
}
