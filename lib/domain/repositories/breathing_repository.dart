import '../entities/breathing.dart';

abstract class BreathingRepository {
  Future<List<BreathingTechnique>> getTechniques();
  Future<BreathingStats> getStats();
  Future<BreathingSession> startSession({
    required String techniqueId,
    required int targetDurationSeconds,
    bool voiceGuidanceEnabled = false,
    String backgroundSound = '',
    bool hapticFeedbackEnabled = false,
    String moodBefore = '',
  });
  Future<Map<String, dynamic>> completeSession({
    required String sessionId,
    required int durationSeconds,
    required int cyclesCompleted,
    required bool completed,
    required int completedPercentage,
    String moodAfter = '',
  });
}
