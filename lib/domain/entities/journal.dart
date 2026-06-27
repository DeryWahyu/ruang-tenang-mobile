import 'package:equatable/equatable.dart';

/// Full journal entry entity (domain layer).
///
/// No JSON coupling — serialization lives in [JournalModel] (data layer).
/// Field names match the legacy model so widgets need no changes.
class Journal extends Equatable {
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

  const Journal({
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

  Journal copyWith({
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
    return Journal(
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

  @override
  List<Object?> get props => [id, uuid, title, content, updatedAt];
}

/// Lightweight journal item used in list / search responses.
class JournalListItem extends Equatable {
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

  const JournalListItem({
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

  @override
  List<Object?> get props => [id, uuid, title, preview, createdAt];
}

/// Paginated journal list result.
class JournalListResult extends Equatable {
  final List<JournalListItem> items;
  final int total;
  final int page;
  final int limit;

  const JournalListResult({
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
