import '../../entities/mood.dart';
import '../../repositories/mood_repository.dart';

class GetLatestMoodUseCase {
  final MoodRepository _repository;
  GetLatestMoodUseCase(this._repository);

  Future<UserMood?> call() => _repository.latest();
}
