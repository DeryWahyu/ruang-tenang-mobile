import '../../entities/mood.dart';
import '../../repositories/mood_repository.dart';

class RecordMoodUseCase {
  final MoodRepository _repository;
  RecordMoodUseCase(this._repository);

  Future<UserMood> call(MoodType mood) => _repository.record(mood);
}
