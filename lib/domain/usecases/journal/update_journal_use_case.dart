import '../../entities/journal.dart';
import '../../repositories/journal_repository.dart';

class UpdateJournalUseCase {
  final JournalRepository _repository;
  UpdateJournalUseCase(this._repository);

  Future<Journal> call({
    required String uuid,
    String? title,
    String? content,
    int? moodId,
    List<String>? tags,
    bool? shareWithAI,
  }) =>
      _repository.update(
        uuid: uuid,
        title: title,
        content: content,
        moodId: moodId,
        tags: tags,
        shareWithAI: shareWithAI,
      );
}
