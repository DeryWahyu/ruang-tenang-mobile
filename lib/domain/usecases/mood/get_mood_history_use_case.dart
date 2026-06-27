import '../../entities/mood.dart';
import '../../repositories/mood_repository.dart';

class GetMoodHistoryUseCase {
  final MoodRepository _repository;
  GetMoodHistoryUseCase(this._repository);

  Future<MoodHistory> call({
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 30,
  }) =>
      _repository.history(
        startDate: startDate,
        endDate: endDate,
        page: page,
        limit: limit,
      );
}
