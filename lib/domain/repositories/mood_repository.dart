import '../entities/mood.dart';

/// Abstract repository interface for mood tracking (domain layer).
///
/// Implemented by [MoodRepositoryImpl] in the data layer.
abstract class MoodRepository {
  Future<UserMood> record(MoodType mood);
  Future<TodayMood> today();
  Future<UserMood?> latest();
  Future<MoodHistory> history({
    DateTime? startDate,
    DateTime? endDate,
    int page,
    int limit,
  });
  Future<MoodStats> stats({int days});
}
