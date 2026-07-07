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
import '../bloc/story_bloc.dart';
import '../bloc/story_event.dart';
import '../bloc/story_state.dart';

class StoryListScreen extends StatelessWidget {
  const StoryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<StoryBloc>()
        ..add(const StoryListRequested())
        ..add(const StoryCategoriesRequested()),
      child: const _StoryListView(),
    );
  }
}

class _StoryListView extends StatelessWidget {
  const _StoryListView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cerita Inspiratif'),
        centerTitle: true,
      ),
      body: BlocBuilder<StoryBloc, StoryState>(
        builder: (context, state) {
          if (state.status == StoryStatus.loading) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: List.generate(4, (_) => const AppSkeletonCard()),
            );
          }
          if (state.status == StoryStatus.failure) {
            return AppErrorWidget(
              message: state.errorMessage.isNotEmpty ? state.errorMessage : 'Gagal memuat cerita',
              onRetry: () => context.read<StoryBloc>().add(const StoryListRequested(refresh: true)),
            );
          }

          if (state.stories.isEmpty) {
            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async => context.read<StoryBloc>().add(const StoryListRequested(refresh: true)),
              child: LayoutBuilder(
                builder: (context, constraints) => ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    Container(
                      height: constraints.maxHeight > 0 ? constraints.maxHeight : 400,
                      alignment: Alignment.center,
                      child: const AppEmptyState(
                        icon: Icons.auto_stories_outlined,
                        title: 'Belum Ada Cerita',
                        subtitle: 'Kisah inspiratif dari komunitas akan muncul di sini.',
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => context.read<StoryBloc>().add(const StoryListRequested(refresh: true)),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              cacheExtent: 600,
              padding: const EdgeInsets.all(16),
              itemCount: state.stories.length,
              itemBuilder: (context, index) => _buildStoryCard(context, state.stories[index]),
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
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.warningLight, borderRadius: BorderRadius.circular(4)),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star_rounded, size: 13, color: AppColors.storyHeading),
                            SizedBox(width: 3),
                            Text('Featured', style: TextStyle(fontSize: 11, color: AppColors.storyHeading, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  Text(story.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (story.author != null) ...[
                        AppAvatar(
                          name: story.isAnonymous ? 'Anonim' : story.author!.name,
                          imageUrl: story.isAnonymous ? null : story.author!.avatar,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(story.isAnonymous ? 'Anonim' : story.author!.name, style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                        const SizedBox(width: 8),
                        const Text('•', style: TextStyle(color: AppColors.mutedForeground)),
                        const SizedBox(width: 8),
                      ],
                      if (story.publishedAt != null)
                        Text(_formatDate(story.publishedAt!), style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(story.excerpt, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, color: AppColors.mutedForeground, height: 1.4)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.favorite, size: 18, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text('${story.heartCount}', style: const TextStyle(fontSize: 13)),
                      const SizedBox(width: 16),
                      const Icon(Icons.chat_bubble_outline, size: 18, color: AppColors.mutedForeground),
                      const SizedBox(width: 4),
                      Text('${story.commentCount}', style: const TextStyle(fontSize: 13, color: AppColors.mutedForeground)),
                      if (story.hasTriggerWarning) ...[
                        const Spacer(),
                        const Icon(Icons.warning_amber, size: 16, color: AppColors.warning),
                      ],
                    ],
                  ),
                  if (story.categories.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      children: story.categories.map((cat) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.storyIconBg, borderRadius: BorderRadius.circular(4)),
                        child: Text(cat.name, style: const TextStyle(fontSize: 11, color: AppColors.storyHeading)),
                      )).toList(),
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