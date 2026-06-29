import '../../entities/journal.dart';
import '../../repositories/journal_repository.dart';

class CreateJournalUseCase {
  final JournalRepository _repository;
  CreateJournalUseCase(this._repository);

  Future<Journal> call({
    required String title,
    required String content,
    int? moodId,
    List<String>? tags,
    bool? isPrivate,
    bool? shareWithAI,
  }) =>
      _repository.create(
        title: title,
        content: content,
        moodId: moodId,
        tags: tags,
        isPrivate: isPrivate,
        shareWithAI: shareWithAI,
      );
}
