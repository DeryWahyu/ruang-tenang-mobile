import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/storage_keys.dart';
import '../../core/network/api_exceptions.dart';
import '../../domain/entities/mood.dart';
import '../../domain/repositories/mood_repository.dart';
import '../datasources/remote/mood_remote_datasource.dart';
import '../models/mood_model.dart';

/// Data-layer implementation of [MoodRepository] with offline-first
/// caching. The remote data source returns [UserMoodModel]s etc.; this
/// class maps them to entities at the boundary.
class MoodRepositoryImpl implements MoodRepository {
  final MoodRemoteDataSource _remote;
  final SharedPreferences _prefs;

  MoodRepositoryImpl({
    required MoodRemoteDataSource remote,
    required SharedPreferences prefs,
  })  : _remote = remote,
        _prefs = prefs;

  @override
  Future<UserMood> record(MoodType mood) async {
    final userMood = await _remote.record(mood);
    await _cacheLatest(userMood);
    await _prefs.setString(
      '${StorageKeys.cachedMoods}_today',
      jsonEncode({
        'has_checked': true,
        'mood': userMood.toJson(),
      }),
    );
    return userMood.toEntity();
  }

  @override
  Future<TodayMood> today() async {
    try {
      final today = await _remote.today();
      await _prefs.setString(
        '${StorageKeys.cachedMoods}_today',
        jsonEncode(today.toJson()),
      );
      return today.toEntity();
    } on ApiException {
      return _readCachedToday();
    }
  }

  @override
  Future<UserMood?> latest() async {
    try {
      final mood = await _remote.latest();
      if (mood != null) await _cacheLatest(mood);
      return mood?.toEntity();
    } on ApiException {
      return _readCachedLatest();
    }
  }

  @override
  Future<MoodHistory> history({
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 30,
  }) async {
    try {
      final history = await _remote.history(
        startDate: startDate,
        endDate: endDate,
        page: page,
        limit: limit,
      );
      await _cacheHistory(history);
      return history.toEntity();
    } on ApiException {
      final cached = _readCachedHistory();
      if (cached != null) return cached;
      rethrow;
    }
  }

  @override
  Future<MoodStats> stats({int days = 30}) async {
    try {
      final stats = await _remote.stats(days: days);
      await _prefs.setString(
        '${StorageKeys.cachedMoods}_stats',
        jsonEncode(stats.toJson()),
      );
      return stats.toEntity();
    } on ApiException {
      final raw = _prefs.getString('${StorageKeys.cachedMoods}_stats');
      if (raw == null) return const MoodStats();
      try {
        return MoodStatsModel.fromJson(jsonDecode(raw) as Map<String, dynamic>)
            .toEntity();
      } catch (_) {
        return const MoodStats();
      }
    }
  }

  // ─── Cache helpers (operate on *Model JSON) ───

  Future<void> _cacheLatest(UserMoodModel mood) async {
    await _prefs.setString(
      '${StorageKeys.cachedMoods}_latest',
      jsonEncode(mood.toJson()),
    );
  }

  UserMood? _readCachedLatest() {
    final raw = _prefs.getString('${StorageKeys.cachedMoods}_latest');
    if (raw == null) return null;
    try {
      return UserMoodModel.fromJson(jsonDecode(raw) as Map<String, dynamic>)
          .toEntity();
    } catch (_) {
      return null;
    }
  }

  TodayMood _readCachedToday() {
    final raw = _prefs.getString('${StorageKeys.cachedMoods}_today');
    if (raw == null) return const TodayMood();
    try {
      return TodayMoodModel.fromJson(jsonDecode(raw) as Map<String, dynamic>)
          .toEntity();
    } catch (_) {
      return const TodayMood();
    }
  }

  Future<void> _cacheHistory(MoodHistoryModel history) async {
    await _prefs.setString(
      StorageKeys.cachedMoods,
      jsonEncode(history.toJson()),
    );
  }

  MoodHistory? _readCachedHistory() {
    final raw = _prefs.getString(StorageKeys.cachedMoods);
    if (raw == null) return null;
    try {
      return MoodHistoryModel.fromJson(jsonDecode(raw) as Map<String, dynamic>)
          .toEntity();
    } catch (_) {
      return null;
    }
  }
}
