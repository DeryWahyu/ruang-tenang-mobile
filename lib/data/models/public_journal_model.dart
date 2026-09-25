import '../../domain/entities/public_journal.dart';
import '../../core/utils/json_parser.dart';

class PublicJournalModel {
  final PublicJournal value;
  PublicJournalModel.fromJson(Map<String, dynamic> json)
    : value = PublicJournal(
        uuid: json['uuid']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        content: json['content']?.toString() ?? '',
        preview: json['preview']?.toString() ?? '',
        authorName:
            (json['author'] is Map ? (json['author'] as Map)['name'] : null)
                ?.toString() ??
            'Sahabat',
        moodLabel: json['mood_label']?.toString() ?? '',
        moodEmoji: json['mood_emoji']?.toString() ?? '',
        tags:
            (json['tags'] as List?)?.map((e) => e.toString()).toList() ??
            const [],
        createdAt: Json.date(json['created_at']) ?? DateTime.now(),
      );
}
