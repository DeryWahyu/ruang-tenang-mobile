import '../../entities/mood.dart';
import '../../repositories/mood_repository.dart';

class GetMoodStatsUseCase {
  final MoodRepository _repository;
  GetMoodStatsUseCase(this._repository);

  Future<MoodStats> call({int days = 30}) => _repository.stats(days: days);
}
