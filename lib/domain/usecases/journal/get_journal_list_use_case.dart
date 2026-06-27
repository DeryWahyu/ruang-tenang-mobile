import '../../entities/journal.dart';
import '../../repositories/journal_repository.dart';

class GetJournalListUseCase {
  final JournalRepository _repository;
  GetJournalListUseCase(this._repository);

  Future<JournalListResult> call({
    int page = 1,
    int limit = 10,
    List<String>? tags,
    DateTime? startDate,
    DateTime? endDate,
    int? moodId,
  }) =>
      _repository.list(
        page: page,
        limit: limit,
        tags: tags,
        startDate: startDate,
        endDate: endDate,
        moodId: moodId,
      );
}
