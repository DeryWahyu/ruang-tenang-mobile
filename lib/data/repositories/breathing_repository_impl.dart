import '../../domain/entities/breathing.dart';
import '../../domain/repositories/breathing_repository.dart';
import '../datasources/remote/breathing_remote_datasource.dart';

class BreathingRepositoryImpl implements BreathingRepository {
  final BreathingRemoteDataSource _remote;

  BreathingRepositoryImpl({required BreathingRemoteDataSource remote}) : _remote = remote;

  @override
  Future<List<BreathingTechnique>> getTechniques() async {
    final models = await _remote.getTechniques();
    return models.map((e) => e.toEntity()).toList();
  }

  @override
  Future<BreathingStats> getStats() async {
    final model = await _remote.getStats();
    return model.toEntity();
  }

  @override
  Future<BreathingSession> startSession({
    required String techniqueId,
    required int targetDurationSeconds,
    bool voiceGuidanceEnabled = false,
    String backgroundSound = '',
    bool hapticFeedbackEnabled = false,
    String moodBefore = '',
  }) async {
    final model = await _remote.startSession(
      techniqueId: techniqueId,
      targetDurationSeconds: targetDurationSeconds,
      voiceGuidanceEnabled: voiceGuidanceEnabled,
      backgroundSound: backgroundSound,
      hapticFeedbackEnabled: hapticFeedbackEnabled,
      moodBefore: moodBefore,
    );
    return model.toEntity();
  }

  @override
  Future<Map<String, dynamic>> completeSession({
    required String sessionId,
    required int durationSeconds,
    required int cyclesCompleted,
    required bool completed,
    required int completedPercentage,
    String moodAfter = '',
  }) async {
    return _remote.completeSession(
      sessionId: sessionId,
      durationSeconds: durationSeconds,
      cyclesCompleted: cyclesCompleted,
      completed: completed,
      completedPercentage: completedPercentage,
      moodAfter: moodAfter,
    );
  }
}
