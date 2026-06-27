import '../../entities/journal.dart';
import '../../repositories/journal_repository.dart';

class GetJournalUseCase {
  final JournalRepository _repository;
  GetJournalUseCase(this._repository);

  Future<Journal> call(String uuid) => _repository.getByUuid(uuid);
}
