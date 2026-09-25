import '../entities/journal.dart';
import '../entities/public_journal.dart';

/// Abstract repository interface for journal entries (domain layer).
///
/// Implemented by [JournalRepositoryImpl] in the data layer.
abstract class JournalRepository {
  Future<Map<String, dynamic>> getSettings();
  Future<Map<String, dynamic>> updateSettings(String key, dynamic value);
  Future<Map<String, dynamic>> getAnalytics();
  Future<Map<String, dynamic>?> getWeeklySummary();
  Future<Map<String, dynamic>> getAiContext();
  Future<List<dynamic>> getAiAccessLogs();
  Future<Map<String, dynamic>> exportJournals(String format);
  Future<Map<String, dynamic>> getWritingPrompt();
  Future<List<PublicJournal>> listPublic({int page, String? search});
  Future<PublicJournal> getPublic(String uuid);
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
