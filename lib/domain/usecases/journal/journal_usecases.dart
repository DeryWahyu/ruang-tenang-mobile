import 'create_journal_use_case.dart';
import 'delete_journal_use_case.dart';
import 'get_journal_list_use_case.dart';
import 'get_journal_use_case.dart';
import 'search_journals_use_case.dart';
import 'update_journal_use_case.dart';

/// Aggregate of all journal use cases, injected into [JournalBloc].
class JournalUseCases {
  final GetJournalListUseCase getList;
  final SearchJournalsUseCase search;
  final GetJournalUseCase getJournal;
  final CreateJournalUseCase create;
  final UpdateJournalUseCase update;
  final DeleteJournalUseCase delete;

  const JournalUseCases({
    required this.getList,
    required this.search,
    required this.getJournal,
    required this.create,
    required this.update,
    required this.delete,
  });
}
