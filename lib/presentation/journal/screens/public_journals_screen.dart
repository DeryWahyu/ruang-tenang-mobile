import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/injection_container.dart';
import '../../../domain/entities/public_journal.dart';
import '../../../domain/repositories/journal_repository.dart';
import '../../common/widgets/mascot_hero.dart';

class PublicJournalState {
  final List<PublicJournal> items;
  final PublicJournal? detail;
  final bool loading;
  final String? error;
  final int page;
  final bool hasMore;
  const PublicJournalState({
    this.items = const [],
    this.detail,
    this.loading = false,
    this.error,
    this.page = 0,
    this.hasMore = true,
  });
}

class PublicJournalCubit extends Cubit<PublicJournalState> {
  final JournalRepository _repository;
  PublicJournalCubit(this._repository) : super(const PublicJournalState());

  Future<void> load({String? search, bool more = false}) async {
    if (state.loading) return;
    if (more && !state.hasMore) return;
    final page = more ? state.page + 1 : 1;
    emit(
      PublicJournalState(
        items: more ? state.items : const [],
        loading: true,
        page: state.page,
        hasMore: state.hasMore,
      ),
    );
    try {
      final items = await _repository.listPublic(page: page, search: search);
      emit(
        PublicJournalState(
          items: [...(more ? state.items : <PublicJournal>[]), ...items],
          page: page,
          hasMore: items.length == 10,
        ),
      );
    } catch (error) {
      emit(
        PublicJournalState(
          items: state.items,
          page: state.page,
          hasMore: state.hasMore,
          error: 'Jurnal publik belum berhasil dimuat.',
        ),
      );
    }
  }

  Future<void> loadDetail(String uuid) async {
    emit(const PublicJournalState(loading: true));
    try {
      emit(PublicJournalState(detail: await _repository.getPublic(uuid)));
    } catch (_) {
      emit(const PublicJournalState(error: 'Jurnal ini tidak tersedia.'));
    }
  }
}

class PublicJournalsScreen extends StatefulWidget {
  const PublicJournalsScreen({super.key});
  @override
  State<PublicJournalsScreen> createState() => _PublicJournalsScreenState();
}

class _PublicJournalsScreenState extends State<PublicJournalsScreen> {
  late final PublicJournalCubit _cubit = sl<PublicJournalCubit>()..load();
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocProvider.value(
    value: _cubit,
    child: Scaffold(
      body: BlocBuilder<PublicJournalCubit, PublicJournalState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const MascotHero(
                title: 'Jurnal Publik',
                description: 'Refleksi yang dibagikan oleh sahabat komunitas.',
                pose: 'journal',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _search,
                onSubmitted: (value) => _cubit.load(search: value),
                decoration: InputDecoration(
                  labelText: 'Cari jurnal publik',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    onPressed: () {
                      _search.clear();
                      _cubit.load();
                    },
                    icon: const Icon(Icons.clear),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (state.loading && state.items.isEmpty)
                const Center(child: CircularProgressIndicator()),
              if (state.error != null) ...[
                Text(state.error!, textAlign: TextAlign.center),
                TextButton(
                  onPressed: () => _cubit.load(search: _search.text),
                  child: const Text('Coba lagi'),
                ),
              ],
              if (!state.loading && state.error == null && state.items.isEmpty)
                const Text(
                  'Belum ada jurnal yang dibagikan.',
                  textAlign: TextAlign.center,
                ),
              ...state.items.map(
                (journal) => Card(
                  child: ListTile(
                    title: Text(journal.title),
                    subtitle: Text(
                      '${journal.authorName} • ${journal.moodLabel}\n${journal.preview}',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    isThreeLine: true,
                    onTap: () =>
                        context.push('/community/journals/${journal.uuid}'),
                  ),
                ),
              ),
              if (state.hasMore && state.items.isNotEmpty)
                TextButton(
                  onPressed: state.loading
                      ? null
                      : () => _cubit.load(search: _search.text, more: true),
                  child: Text(state.loading ? 'Memuat...' : 'Muat lagi'),
                ),
            ],
          );
        },
      ),
    ),
  );
}

class PublicJournalDetailScreen extends StatelessWidget {
  final String uuid;
  const PublicJournalDetailScreen({super.key, required this.uuid});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => sl<PublicJournalCubit>()..loadDetail(uuid),
    child: Scaffold(
      appBar: AppBar(title: const Text('Jurnal Publik')),
      body: BlocBuilder<PublicJournalCubit, PublicJournalState>(
        builder: (context, state) {
          if (state.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.error != null) return Center(child: Text(state.error!));
          final journal = state.detail;
          if (journal == null) return const SizedBox.shrink();
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                journal.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                '${journal.authorName} • ${journal.moodEmoji} ${journal.moodLabel}',
              ),
              const SizedBox(height: 20),
              Html(data: journal.content),
            ],
          );
        },
      ),
    ),
  );
}
