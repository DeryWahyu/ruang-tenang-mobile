import '../entities/journal.dart';

/// Abstract repository interface for journal entries (domain layer).
///
/// Implemented by [JournalRepositoryImpl] in the data layer.
abstract class JournalRepository {
  Future<JournalListResult> list({
    int page,
    int limit,
    List<String>? tags,
    DateTime? startDate,
    DateTime? endDate,
    int? moodId,
  });
  Future<List<JournalListItem>> search(String query);
  Future<Journal> getByUuid(String uuid);
  Future<Journal> create({
    required String title,
    required String content,
    int? moodId,
    List<String>? tags,
    bool? isPrivate,
    bool? shareWithAI,
  });
  Future<Journal> update({
    required String uuid,
    String? title,
    String? content,
    int? moodId,
    List<String>? tags,
    bool? isPrivate,
    bool? shareWithAI,
  });
  Future<void> delete(String uuid);
}
