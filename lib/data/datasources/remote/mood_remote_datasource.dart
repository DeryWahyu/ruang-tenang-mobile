import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../domain/entities/mood.dart';
import '../../models/mood_model.dart';

/// Remote data source for Mood endpoints.
///
/// Mood endpoints use the standard `{success, message, data}` envelope,
/// so we use the regular [ApiClient] get/post methods.
class MoodRemoteDataSource {
  final ApiClient _apiClient;

  MoodRemoteDataSource(this._apiClient);

  /// GET /user-moods?start_date=&end_date=&page=&limit=
  Future<MoodHistoryModel> history({
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 30,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.userMoods,
      queryParameters: {
        if (startDate != null) 'start_date': _formatDate(startDate),
        if (endDate != null) 'end_date': _formatDate(endDate),
        'page': page,
        'limit': limit,
      },
      fromJson: (json) => Map<String, dynamic>.from(json as Map),
    );

    if (!response.success || response.data == null) {
      throw Exception(response.error ?? 'Gagal memuat riwayat mood');
    }
    return MoodHistoryModel.fromJson(response.data!);
  }

  /// POST /user-moods (upsert — one mood per day)
  Future<UserMoodModel> record(MoodType mood) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.userMoods,
      data: {'mood': mood.value},
      fromJson: (json) => Map<String, dynamic>.from(json as Map),
    );

    if (!response.success || response.data == null) {
      throw Exception(response.error ?? 'Gagal menyimpan mood');
    }
    return UserMoodModel.fromJson(response.data!);
  }

  /// GET /user-moods/today → {has_checked, mood}
  Future<TodayMoodModel> today() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.userMoodToday,
      fromJson: (json) => Map<String, dynamic>.from(json as Map),
    );

    if (!response.success || response.data == null) {
      throw Exception(response.error ?? 'Gagal memeriksa mood hari ini');
    }
    return TodayMoodModel.fromJson(response.data!);
  }

  /// GET /user-moods/latest → UserMoodDTO (404 if none)
  Future<UserMoodModel?> latest() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.userMoodLatest,
      fromJson: (json) => Map<String, dynamic>.from(json as Map),
    );

    if (!response.success || response.data == null) return null;
    return UserMoodModel.fromJson(response.data!);
  }

  /// GET /user-moods/stats?days= → raw `Map<String, int>`
  Future<MoodStatsModel> stats({int days = 30}) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.userMoodStats,
      queryParameters: {'days': days},
      fromJson: (json) => Map<String, dynamic>.from(json as Map),
    );

    if (!response.success || response.data == null) {
      return const MoodStatsModel();
    }
    return MoodStatsModel.fromJson(response.data!);
  }

  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
