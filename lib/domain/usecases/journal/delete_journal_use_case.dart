import '../../repositories/journal_repository.dart';

class DeleteJournalUseCase {
  final JournalRepository _repository;
  DeleteJournalUseCase(this._repository);

  Future<void> call(String uuid) => _repository.delete(uuid);
}
