import '../../entities/journal.dart';
import '../../repositories/journal_repository.dart';

class SearchJournalsUseCase {
  final JournalRepository _repository;
  SearchJournalsUseCase(this._repository);

  Future<List<JournalListItem>> call(String query) =>
      _repository.search(query);
}
