import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../models/breathing_model.dart';

class BreathingRemoteDataSource {
  final ApiClient _apiClient;

  BreathingRemoteDataSource(this._apiClient);

  /// GET /breathing/techniques
  Future<List<BreathingTechniqueModel>> getTechniques() async {
    final response = await _apiClient.get<List<dynamic>>(
      ApiConstants.breathingTechniques,
      fromJson: (json) => json as List<dynamic>,
    );

    if (!response.success || response.data == null) {
      throw Exception(response.error ?? 'Gagal memuat teknik pernapasan');
    }

    return response.data!
        .map((e) => BreathingTechniqueModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// GET /breathing/stats
  Future<BreathingStatsModel> getStats() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.breathingStats,
      fromJson: (json) => Map<String, dynamic>.from(json as Map),
    );

    if (!response.success || response.data == null) {
      throw Exception(response.error ?? 'Gagal memuat statistik pernapasan');
    }

    return BreathingStatsModel.fromJson(response.data!);
  }

  /// POST /breathing/sessions
  Future<BreathingSessionModel> startSession({
    required String techniqueId,
    required int targetDurationSeconds,
    bool voiceGuidanceEnabled = false,
    String backgroundSound = '',
    bool hapticFeedbackEnabled = false,
    String moodBefore = '',
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.breathingSessions,
      data: {
        'technique_id': techniqueId,
        'target_duration_seconds': targetDurationSeconds,
        'voice_guidance_enabled': voiceGuidanceEnabled,
        'background_sound': backgroundSound,
        'haptic_feedback_enabled': hapticFeedbackEnabled,
        'mood_before': moodBefore,
      },
      fromJson: (json) => Map<String, dynamic>.from(json as Map),
    );

    if (!response.success || response.data == null) {
      throw Exception(response.error ?? 'Gagal memulai sesi pernapasan');
    }

    return BreathingSessionModel.fromJson(response.data!);
  }

  /// POST /breathing/sessions/:id/complete
  Future<Map<String, dynamic>> completeSession({
    required String sessionId,
    required int durationSeconds,
    required int cyclesCompleted,
    required bool completed,
    required int completedPercentage,
    String moodAfter = '',
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '${ApiConstants.breathingSessions}/$sessionId/complete',
      data: {
        'duration_seconds': durationSeconds,
        'cycles_completed': cyclesCompleted,
        'completed': completed,
        'completed_percentage': completedPercentage,
        'mood_after': moodAfter,
      },
      fromJson: (json) => Map<String, dynamic>.from(json as Map),
    );

    if (!response.success || response.data == null) {
      throw Exception(response.error ?? 'Gagal menyelesaikan sesi pernapasan');
    }

    return response.data!;
  }
}
