import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_colors.dart';

import '../../common/widgets/app_avatar.dart';
import '../../common/widgets/app_skeleton.dart';
import '../../common/widgets/app_empty_state.dart';
import '../../common/widgets/app_error_widget.dart';
import '../../../domain/entities/story.dart';
import '../../../domain/repositories/story_repository.dart';
import '../bloc/story_bloc.dart';
import '../bloc/story_event.dart';
import '../bloc/story_state.dart';

class StoryListScreen extends StatelessWidget {
  const StoryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<StoryBloc>()..add(const StoryListRequested()),
      child: const _StoryListView(),
    );
  }
}

class _StoryListView extends StatefulWidget {
  const _StoryListView();

  @override
  State<_StoryListView> createState() => _StoryListViewState();
}

class _StoryListViewState extends State<_StoryListView> {
  final _search = TextEditingController();
  List<StoryCategory> _categories = [];
  String? _categoryId;
  String _sortBy = 'recent';

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await sl<StoryRepository>().getCategories();
      if (mounted) setState(() => _categories = categories);
    } catch (_) {
      /* Stories remain available without category filters. */
    }
  }

  void _load() => context.read<StoryBloc>().add(
    StoryListRequested(
      refresh: true,
      sortBy: _sortBy,
      categoryId: _categoryId,
      search: _search.text.trim(),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cerita Inspiratif'),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(126),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Column(
              children: [
                TextField(
                  controller: _search,
                  onSubmitted: (_) => _load(),
                  decoration: InputDecoration(
                    hintText: 'Cari kisah',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      onPressed: () {
                        _search.clear();
                        _load();
                      },
                      icon: const Icon(Icons.clear),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _categoryId ?? 'all',
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Kategori',
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: 'all',
                            child: Text('Semua'),
                          ),
                          ..._categories.map(
                            (item) => DropdownMenuItem(
                              value: item.id,
                              child: Text(item.name),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setState(
                            () => _categoryId = value == 'all' ? null : value,
                          );
                          _load();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _sortBy,
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: 'Urutkan'),
                        items: const [
                          DropdownMenuItem(
                            value: 'recent',
                            child: Text('Terbaru'),
                          ),
                          DropdownMenuItem(
                            value: 'hearts',
                            child: Text('Paling disukai'),
                          ),
                          DropdownMenuItem(
                            value: 'featured',
                            child: Text('Pilihan'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _sortBy = value);
                            _load();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: BlocBuilder<StoryBloc, StoryState>(
        builder: (context, state) {
          if (state.status == StoryStatus.loading && state.stories.isEmpty) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: List.generate(4, (_) => const AppSkeletonCard()),
            );
          }
          if (state.status == StoryStatus.failure) {
            return AppErrorWidget(
              message: state.errorMessage.isNotEmpty
                  ? state.errorMessage
                  : 'Gagal memuat cerita',
              onRetry: _load,
            );
          }

          if (state.stories.isEmpty) {
            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async => _load(),
              child: LayoutBuilder(
                builder: (context, constraints) => ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    Container(
                      height: constraints.maxHeight > 0
                          ? constraints.maxHeight
                          : 400,
                      alignment: Alignment.center,
                      child: const AppEmptyState(
                        icon: Icons.auto_stories_outlined,
                        title: 'Belum Ada Cerita',
                        subtitle:
                            'Kisah inspiratif dari komunitas akan muncul di sini.',
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _load(),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              cacheExtent: 600,
              padding: const EdgeInsets.all(16),
              itemCount: state.stories.length + (state.hasMore ? 1 : 0),
              itemBuilder: (context, index) => index == state.stories.length
                  ? TextButton(
                      onPressed: state.status == StoryStatus.loading
                          ? null
                          : () => context.read<StoryBloc>().add(
                              StoryLoadMoreRequested(
                                sortBy: _sortBy,
                                categoryId: _categoryId,
                                search: _search.text.trim(),
                              ),
                            ),
                      child: Text(
                        state.status == StoryStatus.loading
                            ? 'Memuat...'
                            : 'Muat lagi',
                      ),
                    )
                  : _buildStoryCard(context, state.stories[index]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStoryCard(BuildContext context, StoryCard story) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      child: InkWell(
        onTap: () => context.push('/stories/${story.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (story.isFeatured)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.warningLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified_rounded,
                              size: 13,
                              color: AppColors.storyHeading,
                            ),
                            SizedBox(width: 3),
                            Text(
                              'Featured',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.storyHeading,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Text(
                    story.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (story.author != null) ...[
                        AppAvatar(
                          name: story.isAnonymous
                              ? 'Anonim'
                              : story.author!.name,
                          imageUrl: story.isAnonymous
                              ? null
                              : story.author!.avatar,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          story.isAnonymous ? 'Anonim' : story.author!.name,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.mutedForeground,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '•',
                          style: TextStyle(color: AppColors.mutedForeground),
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (story.publishedAt != null)
                        Text(
                          _formatDate(story.publishedAt!),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.mutedForeground,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    story.excerpt,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.mutedForeground,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.favorite,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${story.heartCount}',
                        style: const TextStyle(fontSize: 13),
                      ),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.chat_bubble_outline,
                        size: 18,
                        color: AppColors.mutedForeground,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${story.commentCount}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.mutedForeground,
                        ),
                      ),
                      if (story.hasTriggerWarning) ...[
                        const Spacer(),
                        const Icon(
                          Icons.warning_amber,
                          size: 16,
                          color: AppColors.warning,
                        ),
                      ],
                    ],
                  ),
                  if (story.categories.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      children: story.categories
                          .map(
                            (cat) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.storyIconBg,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                cat.name,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.storyHeading,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays < 1) return 'Hari ini';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    return '${date.day}/${date.month}/${date.year}';
  }
}
