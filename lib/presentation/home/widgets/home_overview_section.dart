import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/injection_container.dart';
import '../../../domain/entities/article.dart';
import '../../../domain/entities/journal.dart';
import '../../../domain/entities/mood.dart';
import '../../../domain/entities/music.dart';
import '../../../domain/repositories/article_repository.dart';
import '../../../domain/repositories/journal_repository.dart';
import '../../../domain/repositories/mood_repository.dart';
import '../../../domain/repositories/music_repository.dart';

class HomeOverviewState {
  final bool loading;
  final List<UserMood> moods;
  final JournalListItem? latestJournal;
  final List<ArticleListItem> articles;
  final List<SongCategory> categories;
  const HomeOverviewState({
    this.loading = false,
    this.moods = const [],
    this.latestJournal,
    this.articles = const [],
    this.categories = const [],
  });
}

class HomeOverviewCubit extends Cubit<HomeOverviewState> {
  final MoodRepository _moods;
  final JournalRepository _journals;
  final ArticleRepository _articles;
  final MusicRepository _music;
  HomeOverviewCubit(this._moods, this._journals, this._articles, this._music)
    : super(const HomeOverviewState());

  Future<T?> _safe<T>(Future<T> future) async {
    try {
      return await future;
    } catch (_) {
      return null;
    }
  }

  Future<void> load() async {
    emit(const HomeOverviewState(loading: true));
    final data = await Future.wait<dynamic>([
      _safe(_moods.history(limit: 30)),
      _safe(_journals.list(limit: 1)),
      _safe(_articles.getArticles(limit: 3)),
      _safe(_music.getSongCategories()),
    ]);
    if (isClosed) return;
    emit(
      HomeOverviewState(
        moods: (data[0] as MoodHistory?)?.moods ?? const [],
        latestJournal:
            ((data[1] as JournalListResult?)?.items.isNotEmpty ?? false)
            ? (data[1] as JournalListResult).items.first
            : null,
        articles: (data[2] as List<ArticleListItem>?) ?? const [],
        categories: (data[3] as List<SongCategory>?) ?? const [],
      ),
    );
  }
}

class HomeOverviewSection extends StatelessWidget {
  const HomeOverviewSection({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => sl<HomeOverviewCubit>()..load(),
    child: BlocBuilder<HomeOverviewCubit, HomeOverviewState>(
      builder: (context, state) {
        if (state.loading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          );
        }
        final days = List.generate(
          7,
          (index) => DateTime.now().subtract(Duration(days: 6 - index)),
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ritme hari ini',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Kalender mood',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: days.map((day) {
                        UserMood? mood;
                        for (final candidate in state.moods) {
                          if (candidate.createdAt.year == day.year &&
                              candidate.createdAt.month == day.month &&
                              candidate.createdAt.day == day.day) {
                            mood = candidate;
                            break;
                          }
                        }
                        return Column(
                          children: [
                            Text(
                              '${day.day}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              mood?.displayEmoji ?? '·',
                              style: const TextStyle(fontSize: 22),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                    TextButton(
                      onPressed: () => context.push('/mood/stats'),
                      child: const Text('Lihat riwayat mood'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              child: ListTile(
                leading: const Icon(Icons.menu_book_rounded),
                title: Text(
                  state.latestJournal?.title ?? 'Mulai refleksi kecil hari ini',
                ),
                subtitle: Text(
                  state.latestJournal?.preview ?? 'Tulis jurnal pertamamu',
                  maxLines: 2,
                ),
                onTap: () => context.push(
                  state.latestJournal == null
                      ? '/journal/create'
                      : '/journal/${state.latestJournal!.uuid}',
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text('Teman jeda', style: Theme.of(context).textTheme.titleLarge),
            if (state.categories.isNotEmpty) ...[
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.headphones_rounded),
                  title: Text(state.categories.first.name),
                  subtitle: Text(
                    '${state.categories.first.songCount} lagu untuk menemanimu',
                  ),
                  onTap: () => context.push('/music'),
                ),
              ),
            ],
            const SizedBox(height: 8),
            ...state.articles.map(
              (article) => Card(
                child: ListTile(
                  title: Text(article.title),
                  subtitle: Text(
                    article.excerpt,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => context.push('/articles/${article.slug}'),
                ),
              ),
            ),
            TextButton(
              onPressed: () => context.push('/articles'),
              child: const Text('Jelajahi semua artikel'),
            ),
          ],
        );
      },
    ),
  );
}
