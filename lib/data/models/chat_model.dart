import 'package:equatable/equatable.dart';
import '../../domain/entities/chat.dart';

class ChatMessageModel extends Equatable {
  final int id;
  final String role;
  final String content;
  final String type;
  final bool isLiked;
  final bool isDisliked;
  final bool isPinned;
  final DateTime createdAt;

  const ChatMessageModel({
    required this.id,
    required this.role,
    required this.content,
    required this.type,
    this.isLiked = false,
    this.isDisliked = false,
    this.isPinned = false,
    required this.createdAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      role: json['role'] as String? ?? 'user',
      content: json['content'] as String? ?? '',
      type: json['type'] as String? ?? 'text',
      isLiked: json['is_liked'] as bool? ?? false,
      isDisliked: json['is_disliked'] as bool? ?? false,
      isPinned: json['is_pinned'] as bool? ?? false,
      createdAt: _parseDate(json['created_at']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'role': role,
        'content': content,
        'type': type,
        'is_liked': isLiked,
        'is_disliked': isDisliked,
        'is_pinned': isPinned,
        'created_at': createdAt.toIso8601String(),
      };

  ChatMessage toEntity() => ChatMessage(
        id: id,
        role: role,
        content: content,
        type: type,
        isLiked: isLiked,
        isDisliked: isDisliked,
        isPinned: isPinned,
        createdAt: createdAt,
      );

  static ChatMessageModel fromEntity(ChatMessage e) => ChatMessageModel(
        id: e.id,
        role: e.role,
        content: e.content,
        type: e.type,
        isLiked: e.isLiked,
        isDisliked: e.isDisliked,
        isPinned: e.isPinned,
        createdAt: e.createdAt,
      );

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

class ChatSessionModel extends Equatable {
  final int id;
  final String uuid;
  final String title;
  final int? folderId;
  final String? folderName;
  final String? summary;
  final bool isFavorite;
  final bool isTrash;
  final ChatMessageModel? lastMessage;
  final List<ChatMessageModel> messages;
  final List<ChatMessageModel> pinnedMessages;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ChatSessionModel({
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

  factory ChatSessionModel.fromJson(Map<String, dynamic> json) {
    return ChatSessionModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      uuid: json['uuid'] as String? ?? '',
      title: json['title'] as String? ?? '',
      folderId: (json['folder_id'] as num?)?.toInt(),
      folderName: json['folder_name'] as String?,
      summary: json['summary'] as String?,
      isFavorite: json['is_favorite'] as bool? ?? false,
      isTrash: json['is_trash'] as bool? ?? false,
      lastMessage: json['last_message'] != null
          ? ChatMessageModel.fromJson(
              Map<String, dynamic>.from(json['last_message']))
          : null,
      messages: (json['messages'] as List<dynamic>?)
              ?.map((e) => ChatMessageModel.fromJson(
                  Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
      pinnedMessages: (json['pinned_messages'] as List<dynamic>?)
              ?.map((e) => ChatMessageModel.fromJson(
                  Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
      createdAt: _parseDate(json['created_at']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: _parseDate(json['updated_at']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'title': title,
        if (folderId != null) 'folder_id': folderId,
        if (folderName != null) 'folder_name': folderName,
        if (summary != null) 'summary': summary,
        'is_favorite': isFavorite,
        'is_trash': isTrash,
        if (lastMessage != null) 'last_message': lastMessage!.toJson(),
        'messages': messages.map((e) => e.toJson()).toList(),
        'pinned_messages': pinnedMessages.map((e) => e.toJson()).toList(),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  ChatSession toEntity() => ChatSession(
        id: id,
        uuid: uuid,
        title: title,
        folderId: folderId,
        folderName: folderName,
        summary: summary,
        isFavorite: isFavorite,
        isTrash: isTrash,
        lastMessage: lastMessage?.toEntity(),
        messages: messages.map((e) => e.toEntity()).toList(),
        pinnedMessages: pinnedMessages.map((e) => e.toEntity()).toList(),
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  static ChatSessionModel fromEntity(ChatSession e) => ChatSessionModel(
        id: e.id,
        uuid: e.uuid,
        title: e.title,
        folderId: e.folderId,
        folderName: e.folderName,
        summary: e.summary,
        isFavorite: e.isFavorite,
        isTrash: e.isTrash,
        lastMessage: e.lastMessage != null
            ? ChatMessageModel.fromEntity(e.lastMessage!)
            : null,
        messages: e.messages.map(ChatMessageModel.fromEntity).toList(),
        pinnedMessages:
            e.pinnedMessages.map(ChatMessageModel.fromEntity).toList(),
        createdAt: e.createdAt,
        updatedAt: e.updatedAt,
      );

  @override
  List<Object?> get props => [
        id,
        uuid,
        title,
        isFavorite,
        isTrash,
        messages,
        updatedAt,
      ];
}

class ChatSessionListItemModel extends Equatable {
  final int id;
  final String uuid;
  final String title;
  final int? folderId;
  final bool isFavorite;
  final bool isTrash;
  final bool hasSummary;
  final String lastMessage;
  final DateTime createdAt;

  const ChatSessionListItemModel({
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

  factory ChatSessionListItemModel.fromJson(Map<String, dynamic> json) {
    return ChatSessionListItemModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      uuid: json['uuid'] as String? ?? '',
      title: json['title'] as String? ?? '',
      folderId: (json['folder_id'] as num?)?.toInt(),
      isFavorite: json['is_favorite'] as bool? ?? false,
      isTrash: json['is_trash'] as bool? ?? false,
      hasSummary: json['has_summary'] as bool? ?? false,
      lastMessage: json['last_message'] as String? ?? '',
      createdAt: _parseDate(json['created_at']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'title': title,
        if (folderId != null) 'folder_id': folderId,
        'is_favorite': isFavorite,
        'is_trash': isTrash,
        'has_summary': hasSummary,
        'last_message': lastMessage,
        'created_at': createdAt.toIso8601String(),
      };

  ChatSessionListItem toEntity() => ChatSessionListItem(
        id: id,
        uuid: uuid,
        title: title,
        folderId: folderId,
        isFavorite: isFavorite,
        isTrash: isTrash,
        hasSummary: hasSummary,
        lastMessage: lastMessage,
        createdAt: createdAt,
      );

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

class ChatSessionListResultModel extends Equatable {
  final List<ChatSessionListItemModel> items;
  final int total;
  final int page;
  final int limit;

  const ChatSessionListResultModel({
    this.items = const [],
    this.total = 0,
    this.page = 1,
    this.limit = 10,
  });

  factory ChatSessionListResultModel.fromJson(Map<String, dynamic> json) {
    return ChatSessionListResultModel(
      items: (json['data'] as List<dynamic>?)
              ?.map((e) => ChatSessionListItemModel.fromJson(
                  Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      total: (json['total_items'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 10,
    );
  }

  ChatSessionListResult toEntity() => ChatSessionListResult(
        items: items.map((e) => e.toEntity()).toList(),
        total: total,
        page: page,
        limit: limit,
      );

  @override
  List<Object?> get props => [items, total, page, limit];
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  if (value is! String || value.isEmpty) return null;
  try {
    return DateTime.parse(value).toLocal();
  } catch (_) {
    return null;
  }
}
