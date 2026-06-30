import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_colors.dart';
import '../../common/widgets/app_network_image.dart';
import '../../../domain/entities/music.dart';
import '../../music/bloc/music_bloc.dart';
import '../../music/bloc/music_event.dart';
import '../bloc/search_bloc.dart';
import '../bloc/search_event.dart';
import '../bloc/search_state.dart';

class GlobalSearchScreen extends StatelessWidget {
  const GlobalSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SearchBloc>(),
      child: const _GlobalSearchView(),
    );
  }
}

class _GlobalSearchView extends StatefulWidget {
  const _GlobalSearchView();

  @override
  State<_GlobalSearchView> createState() => _GlobalSearchViewState();
}

class _GlobalSearchViewState extends State<_GlobalSearchView> {
  final _searchController = TextEditingController();
  String _currentTab = 'Semua';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(BuildContext context) {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      context.read<SearchBloc>().add(SearchQuerySubmitted(query));
    } else {
      context.read<SearchBloc>().add(const SearchCleared());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Cari artikel, lagu...',
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                context.read<SearchBloc>().add(const SearchCleared());
              },
            ),
          ),
          onSubmitted: (_) => _onSearch(context),
          textInputAction: TextInputAction.search,
        ),
      ),
      body: BlocBuilder<SearchBloc, SearchState>(
        builder: (context, state) {
          if (state.status == SearchStatus.initial) {
            return _buildEmptyState('Ketikkan sesuatu untuk mencari');
          }
          if (state.status == SearchStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == SearchStatus.failure) {
            return _buildEmptyState(state.errorMessage, isError: true);
          }
          if (state.result == null || state.result!.total == 0) {
            return _buildEmptyState('Tidak ada hasil ditemukan untuk "${state.query}"');
          }

          final result = state.result!;
          final articles = result.articles;
          final songs = result.songs;

          return Column(
            children: [
              _buildTabs(articles.length, songs.length),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if ((_currentTab == 'Semua' || _currentTab == 'Artikel') && articles.isNotEmpty) ...[
                      const Text('Artikel', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 12),
                      ...articles.map((a) => _buildArticleItem(context, a)),
                      const SizedBox(height: 24),
                    ],
                    if ((_currentTab == 'Semua' || _currentTab == 'Lagu') && songs.isNotEmpty) ...[
                      const Text('Lagu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 12),
                      ...songs.map((s) => _buildSongItem(context, s)),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String message, {bool isError = false}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(isError ? Icons.error_outline : Icons.search, size: 64, color: AppColors.mutedForeground.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: AppColors.mutedForeground)),
        ],
      ),
    );
  }

  Widget _buildTabs(int articlesCount, int songsCount) {
    return Container(
      color: AppColors.card,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTabItem('Semua', articlesCount + songsCount),
          _buildTabItem('Artikel', articlesCount),
          _buildTabItem('Lagu', songsCount),
        ],
      ),
    );
  }

  Widget _buildTabItem(String title, int count) {
    final isSelected = _currentTab == title;
    return InkWell(
      onTap: () => setState(() => _currentTab = title),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: isSelected ? AppColors.primary : Colors.transparent, width: 2)),
        ),
        child: Text('$title ($count)', style: TextStyle(color: isSelected ? AppColors.primary : AppColors.mutedForeground, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      ),
    );
  }

  Widget _buildArticleItem(BuildContext context, article) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: () => context.push('/articles/${article.slug}'),
      leading: AppNetworkImage(
        url: article.thumbnail,
        width: 60,
        height: 60,
        borderRadius: BorderRadius.circular(8),
        fallbackIcon: Icons.article,
      ),
      title: Text(article.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text('Artikel', style: TextStyle(color: AppColors.primary, fontSize: 12)),
    );
  }

  Widget _buildSongItem(BuildContext context, Song song) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: () {
        // Putar lagu lewat MusicBloc global (singleton) lalu kembali —
        // mini-player global akan tampil mengikuti layar.
        sl<MusicBloc>().add(MusicPlaySongRequested(song));
        context.pop();
      },
      leading: AppNetworkImage(
        url: song.thumbnail,
        width: 60,
        height: 60,
        borderRadius: BorderRadius.circular(8),
        fallbackIcon: Icons.music_note,
      ),
      title: Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text('Lagu', style: TextStyle(color: Colors.blue, fontSize: 12)),
      trailing: const Icon(Icons.play_circle_filled, color: AppColors.primary),
    );
  }
}