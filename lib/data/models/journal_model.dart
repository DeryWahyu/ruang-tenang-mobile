import 'package:equatable/equatable.dart';
import '../../core/utils/json_parser.dart';
import '../../domain/entities/journal.dart';

/// Data-layer model for [Journal] (full entry). JSON (de)serialization
/// lives here; mapping to the pure-Dart entity via [toEntity].
///
/// Matches backend `JournalResponse` (internal/dto/journal.go).
class JournalModel extends Equatable {
  final int id;
  final String uuid;
  final String title;
  final String content;
  final String? summary;
  final int? moodId;
  final String? moodLabel;
  final String? moodEmoji;
  final List<String> tags;
  final bool isPrivate;
  final bool shareWithAI;
  final DateTime? aiAccessedAt;
  final int wordCount;
  final double? sentimentScore;
  final DateTime createdAt;
  final DateTime updatedAt;

  const JournalModel({
    required this.id,
    required this.uuid,
    required this.title,
    required this.content,
    this.summary,
    this.moodId,
    this.moodLabel,
    this.moodEmoji,
    this.tags = const [],
    this.isPrivate = false,
    this.shareWithAI = false,
    this.aiAccessedAt,
    this.wordCount = 0,
    this.sentimentScore,
    required this.createdAt,
    required this.updatedAt,
  });

  factory JournalModel.fromJson(Map<String, dynamic> json) {
    return JournalModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      uuid: json['uuid'] as String? ?? '',
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      summary: json['summary'] as String?,
      moodId: (json['mood_id'] as num?)?.toInt(),
      moodLabel: json['mood_label'] as String?,
      moodEmoji: json['mood_emoji'] as String?,
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      isPrivate: json['is_private'] as bool? ?? false,
      shareWithAI: json['share_with_ai'] as bool? ?? false,
      aiAccessedAt: Json.date(json['ai_accessed_at']),
      wordCount: (json['word_count'] as num?)?.toInt() ?? 0,
      sentimentScore: (json['sentiment_score'] as num?)?.toDouble(),
      createdAt: Json.date(json['created_at']) ?? DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: Json.date(json['updated_at']) ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'title': title,
        'content': content,
        if (summary != null) 'summary': summary,
        if (moodId != null) 'mood_id': moodId,
        if (moodLabel != null) 'mood_label': moodLabel,
        if (moodEmoji != null) 'mood_emoji': moodEmoji,
        'tags': tags,
        'is_private': isPrivate,
        'share_with_ai': shareWithAI,
        if (aiAccessedAt != null) 'ai_accessed_at': aiAccessedAt!.toIso8601String(),
        'word_count': wordCount,
        if (sentimentScore != null) 'sentiment_score': sentimentScore,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  JournalModel copyWith({
    int? id,
    String? uuid,
    String? title,
    String? content,
    String? summary,
    int? moodId,
    String? moodLabel,
    String? moodEmoji,
    List<String>? tags,
    bool? isPrivate,
    bool? shareWithAI,
    DateTime? aiAccessedAt,
    int? wordCount,
    double? sentimentScore,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return JournalModel(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      title: title ?? this.title,
      content: content ?? this.content,
      summary: summary ?? this.summary,
      moodId: moodId ?? this.moodId,
      moodLabel: moodLabel ?? this.moodLabel,
      moodEmoji: moodEmoji ?? this.moodEmoji,
      tags: tags ?? this.tags,
      isPrivate: isPrivate ?? this.isPrivate,
      shareWithAI: shareWithAI ?? this.shareWithAI,
      aiAccessedAt: aiAccessedAt ?? this.aiAccessedAt,
      wordCount: wordCount ?? this.wordCount,
      sentimentScore: sentimentScore ?? this.sentimentScore,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Journal toEntity() => Journal(
        id: id,
        uuid: uuid,
        title: title,
        content: content,
        summary: summary,
        moodId: moodId,
        moodLabel: moodLabel,
        moodEmoji: moodEmoji,
        tags: tags,
        isPrivate: isPrivate,
        shareWithAI: shareWithAI,
        aiAccessedAt: aiAccessedAt,
        wordCount: wordCount,
        sentimentScore: sentimentScore,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  static JournalModel fromEntity(Journal e) => JournalModel(
        id: e.id,
        uuid: e.uuid,
        title: e.title,
        content: e.content,
        summary: e.summary,
        moodId: e.moodId,
        moodLabel: e.moodLabel,
        moodEmoji: e.moodEmoji,
        tags: e.tags,
        isPrivate: e.isPrivate,
        shareWithAI: e.shareWithAI,
        aiAccessedAt: e.aiAccessedAt,
        wordCount: e.wordCount,
        sentimentScore: e.sentimentScore,
        createdAt: e.createdAt,
        updatedAt: e.updatedAt,
      );

  @override
  List<Object?> get props => [id, uuid, title, content, updatedAt];
}

/// Data-layer model for [JournalListItem] (list / search item).
///
/// Matches backend `JournalListResponse`.
class JournalListItemModel extends Equatable {
  final int id;
  final String uuid;
  final String title;
  final String preview;
  final int? moodId;
  final String? moodLabel;
  final String? moodEmoji;
  final List<String> tags;
  final bool shareWithAI;
  final DateTime? aiAccessedAt;
  final int wordCount;
  final DateTime createdAt;

  const JournalListItemModel({
    required this.id,
    required this.uuid,
    required this.title,
    required this.preview,
    this.moodId,
    this.moodLabel,
    this.moodEmoji,
    this.tags = const [],
    this.shareWithAI = false,
    this.aiAccessedAt,
    this.wordCount = 0,
    required this.createdAt,
  });

  factory JournalListItemModel.fromJson(Map<String, dynamic> json) {
    return JournalListItemModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      uuid: json['uuid'] as String? ?? '',
      title: json['title'] as String? ?? '',
      preview: json['preview'] as String? ?? '',
      moodId: (json['mood_id'] as num?)?.toInt(),
      moodLabel: json['mood_label'] as String?,
      moodEmoji: json['mood_emoji'] as String?,
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      shareWithAI: json['share_with_ai'] as bool? ?? false,
      aiAccessedAt: Json.date(json['ai_accessed_at']),
      wordCount: (json['word_count'] as num?)?.toInt() ?? 0,
      createdAt: Json.date(json['created_at']) ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'title': title,
        'preview': preview,
        if (moodId != null) 'mood_id': moodId,
        if (moodLabel != null) 'mood_label': moodLabel,
        if (moodEmoji != null) 'mood_emoji': moodEmoji,
        'tags': tags,
        'share_with_ai': shareWithAI,
        if (aiAccessedAt != null) 'ai_accessed_at': aiAccessedAt!.toIso8601String(),
        'word_count': wordCount,
        'created_at': createdAt.toIso8601String(),
      };

  JournalListItem toEntity() => JournalListItem(
        id: id,
        uuid: uuid,
        title: title,
        preview: preview,
        moodId: moodId,
        moodLabel: moodLabel,
        moodEmoji: moodEmoji,
        tags: tags,
        shareWithAI: shareWithAI,
        aiAccessedAt: aiAccessedAt,
        wordCount: wordCount,
        createdAt: createdAt,
      );

  @override
  List<Object?> get props => [id, uuid, title, preview, createdAt];
}

/// Data-layer model for [JournalListResult] (paginated list).
///
/// Backend returns a flat `{data, total, page, limit}` envelope.
class JournalListResultModel extends Equatable {
  final List<JournalListItemModel> items;
  final int total;
  final int page;
  final int limit;

  const JournalListResultModel({
    this.items = const [],
    this.total = 0,
    this.page = 1,
    this.limit = 10,
  });

  factory JournalListResultModel.fromJson(Map<String, dynamic> json) {
    return JournalListResultModel(
      items: (json['data'] as List<dynamic>?)
              ?.map((e) => JournalListItemModel.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      total: (json['total'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 10,
    );
  }

  int get totalPages => limit > 0 ? (total / limit).ceil() : 0;
  bool get hasNextPage => page < totalPages;

  JournalListResult toEntity() => JournalListResult(
        items: items.map((e) => e.toEntity()).toList(),
        total: total,
        page: page,
        limit: limit,
      );

  @override
  List<Object?> get props => [items, total, page, limit];
}

