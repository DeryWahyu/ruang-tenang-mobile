import '../../entities/mood.dart';
import '../../repositories/mood_repository.dart';

class GetTodayMoodUseCase {
  final MoodRepository _repository;
  GetTodayMoodUseCase(this._repository);

  Future<TodayMood> call() => _repository.today();
}
