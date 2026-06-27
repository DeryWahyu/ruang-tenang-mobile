import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/storage_keys.dart';
import '../../core/network/api_exceptions.dart';
import '../../domain/entities/journal.dart';
import '../../domain/repositories/journal_repository.dart';
import '../datasources/remote/journal_remote_datasource.dart';
import '../models/journal_model.dart';

/// Data-layer implementation of [JournalRepository] with offline-first
/// caching. The remote data source returns [JournalModel]s; this class
/// maps them to [Journal] entities at the boundary.
class JournalRepositoryImpl implements JournalRepository {
  final JournalRemoteDataSource _remote;
  final SharedPreferences _prefs;

  JournalRepositoryImpl({
    required JournalRemoteDataSource remote,
    required SharedPreferences prefs,
  })  : _remote = remote,
        _prefs = prefs;

  @override
  Future<JournalListResult> list({
    int page = 1,
    int limit = 10,
    List<String>? tags,
    DateTime? startDate,
    DateTime? endDate,
    int? moodId,
  }) async {
    try {
      final result = await _remote.list(
        page: page,
        limit: limit,
        tags: tags,
        startDate: startDate,
        endDate: endDate,
        moodId: moodId,
      );
      if (page == 1) await _cacheList(result);
      return result.toEntity();
    } on ApiException {
      if (page == 1) {
        final cached = _readCachedList();
        if (cached != null) return cached;
      }
      rethrow;
    }
  }

  @override
  Future<List<JournalListItem>> search(String query) async {
    final models = await _remote.search(query: query);
    return models.map((e) => e.toEntity()).toList();
  }

  @override
  Future<Journal> getByUuid(String uuid) async {
    try {
      final journal = await _remote.getByUuid(uuid);
      await _cacheDetail(journal);
      return journal.toEntity();
    } on ApiException {
      final cached = _readCachedDetail(uuid);
      if (cached != null) return cached;
      rethrow;
    }
  }

  @override
  Future<Journal> create({
    required String title,
    required String content,
    int? moodId,
    List<String>? tags,
    bool? shareWithAI,
  }) async {
    final journal = await _remote.create(
      title: title,
      content: content,
      moodId: moodId,
      tags: tags,
      shareWithAI: shareWithAI,
    );
    await _prefs.remove(StorageKeys.cachedJournals);
    return journal.toEntity();
  }

  @override
  Future<Journal> update({
    required String uuid,
    String? title,
    String? content,
    int? moodId,
    List<String>? tags,
    bool? shareWithAI,
  }) async {
    final journal = await _remote.update(
      uuid: uuid,
      title: title,
      content: content,
      moodId: moodId,
      tags: tags,
      shareWithAI: shareWithAI,
    );
    await _cacheDetail(journal);
    await _prefs.remove(StorageKeys.cachedJournals);
    return journal.toEntity();
  }

  @override
  Future<void> delete(String uuid) async {
    await _remote.delete(uuid);
    await _prefs.remove(_detailKey(uuid));
    await _prefs.remove(StorageKeys.cachedJournals);
  }

  // ─── Cache helpers (operate on *Model JSON) ───

  Future<void> _cacheList(JournalListResultModel result) async {
    await _prefs.setString(
      StorageKeys.cachedJournals,
      jsonEncode({
        'data': result.items.map((e) => e.toJson()).toList(),
        'total': result.total,
        'page': result.page,
        'limit': result.limit,
      }),
    );
  }

  JournalListResult? _readCachedList() {
    final raw = _prefs.getString(StorageKeys.cachedJournals);
    if (raw == null) return null;
    try {
      return JournalListResultModel.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      ).toEntity();
    } catch (_) {
      return null;
    }
  }

  Future<void> _cacheDetail(JournalModel journal) async {
    await _prefs.setString(
      _detailKey(journal.uuid),
      jsonEncode(journal.toJson()),
    );
  }

  Journal? _readCachedDetail(String uuid) {
    final raw = _prefs.getString(_detailKey(uuid));
    if (raw == null) return null;
    try {
      return JournalModel.fromJson(jsonDecode(raw) as Map<String, dynamic>)
          .toEntity();
    } catch (_) {
      return null;
    }
  }

  String _detailKey(String uuid) => '${StorageKeys.cachedJournals}_detail_$uuid';
}
