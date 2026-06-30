import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_colors.dart';
import '../../common/widgets/app_network_image.dart';
import '../../../domain/entities/story.dart';
import '../../common/widgets/app_error_widget.dart';
import '../bloc/story_bloc.dart';
import '../bloc/story_event.dart';
import '../bloc/story_state.dart';

class StoryDetailScreen extends StatelessWidget {
  final String id;
  const StoryDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<StoryBloc>()
        ..add(StoryDetailRequested(id))
        ..add(StoryCommentsRequested(id)),
      child: _StoryDetailView(id: id),
    );
  }
}

class _StoryDetailView extends StatefulWidget {
  final String id;
  const _StoryDetailView({required this.id});

  @override
  State<_StoryDetailView> createState() => _StoryDetailViewState();
}

class _StoryDetailViewState extends State<_StoryDetailView> {
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StoryBloc, StoryState>(
      listener: (context, state) {
        if (state.status == StoryStatus.success) {
          _commentController.clear();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.successMessage)));
        }
      },
      builder: (context, state) {
        final story = state.detail;

        return Scaffold(
          appBar: AppBar(
            title: Text(story?.title ?? 'Cerita', maxLines: 1, overflow: TextOverflow.ellipsis),
            centerTitle: true,
          ),
          body: state.status == StoryStatus.detailLoading
              ? const Center(child: CircularProgressIndicator())
              : state.status == StoryStatus.failure
                  ? AppErrorWidget(
                      message: state.errorMessage.isNotEmpty ? state.errorMessage : 'Gagal memuat cerita',
                      onRetry: () => context.read<StoryBloc>().add(StoryDetailRequested(widget.id)),
                    )
                  : story == null
                      ? const Center(child: Text('Cerita tidak ditemukan'))
                      : Column(
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (story.coverImage.isNotEmpty)
                                      AppNetworkImage(
                                        url: story.coverImage,
                                        width: double.infinity,
                                        height: 200,
                                        borderRadius: BorderRadius.circular(12),
                                        backgroundColor: AppColors.storyFrom,
                                        fallbackIcon: Icons.image,
                                        fallbackColor: AppColors.storyIcon,
                                      ),
                                    const SizedBox(height: 16),
                                    if (story.hasTriggerWarning) ...[
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(color: AppColors.warningLight, borderRadius: BorderRadius.circular(8)),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.warning_amber, color: AppColors.warning, size: 20),
                                            const SizedBox(width: 8),
                                            Expanded(child: Text(story.triggerWarningText.isNotEmpty ? story.triggerWarningText : 'Konten ini mengandung trigger warning', style: const TextStyle(fontSize: 13, color: AppColors.warning))),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                    ],
                                    Text(story.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 16,
                                          backgroundColor: AppColors.muted,
                                          child: Text(
                                            story.isAnonymous ? 'A' : (story.author?.name ?? 'A').substring(0, 1).toUpperCase(),
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(story.isAnonymous ? 'Anonim' : (story.author?.name ?? 'Anonim'), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                            if (story.publishedAt != null)
                                              Text(_formatDate(story.publishedAt!), style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        InkWell(
                                          onTap: () => context.read<StoryBloc>().add(StoryHeartToggled(widget.id)),
                                          borderRadius: BorderRadius.circular(8),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: story.hasHearted ? AppColors.red50 : AppColors.muted,
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(story.hasHearted ? Icons.favorite : Icons.favorite_border, size: 18, color: story.hasHearted ? AppColors.primary : AppColors.mutedForeground),
                                                const SizedBox(width: 4),
                                                Text('${story.heartCount}', style: TextStyle(fontSize: 13, color: story.hasHearted ? AppColors.primary : AppColors.mutedForeground)),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(color: AppColors.muted, borderRadius: BorderRadius.circular(20)),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.visibility_outlined, size: 18, color: AppColors.mutedForeground),
                                              const SizedBox(width: 4),
                                              Text('${story.viewCount}', style: const TextStyle(fontSize: 13, color: AppColors.mutedForeground)),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(color: AppColors.muted, borderRadius: BorderRadius.circular(20)),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.chat_bubble_outline, size: 18, color: AppColors.mutedForeground),
                                              const SizedBox(width: 4),
                                              Text('${story.commentCount}', style: const TextStyle(fontSize: 13, color: AppColors.mutedForeground)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (story.categories.isNotEmpty) ...[
                                      const SizedBox(height: 12),
                                      Wrap(
                                        spacing: 6,
                                        children: story.categories.map((cat) => Chip(
                                          label: Text(cat.name, style: const TextStyle(fontSize: 12)),
                                          backgroundColor: AppColors.storyIconBg,
                                          side: BorderSide.none,
                                          padding: EdgeInsets.zero,
                                          visualDensity: VisualDensity.compact,
                                        )).toList(),
                                      ),
                                    ],
                                    const Divider(height: 32),
                                    SelectableText(story.content, style: const TextStyle(fontSize: 15, height: 1.7)),
                                    const Divider(height: 32),
                                    Text('Komentar (${state.comments.length})', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 12),
                                    if (state.comments.isEmpty)
                                      const Padding(
                                        padding: EdgeInsets.all(16),
                                        child: Center(child: Text('Belum ada komentar', style: TextStyle(color: AppColors.mutedForeground))),
                                      ),
                                    ...state.comments.map((c) => _buildComment(context, c)),
                                    const SizedBox(height: 80),
                                  ],
                                ),
                              ),
                            ),
                            _buildCommentBar(context, state),
                          ],
                        ),
        );
      },
    );
  }

  Widget _buildComment(BuildContext context, StoryComment comment) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: AppColors.muted,
            child: Text(
              (comment.author?.name ?? 'A').substring(0, 1).toUpperCase(),
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(comment.author?.name ?? 'Anonim', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(width: 8),
                    Text(_formatDate(comment.createdAt), style: const TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(comment.content, style: const TextStyle(fontSize: 13, height: 1.4)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.favorite, size: 14, color: comment.hasHearted ? AppColors.primary : AppColors.mutedForeground),
                    const SizedBox(width: 4),
                    Text('${comment.heartCount}', style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentBar(BuildContext context, StoryState state) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: 'Tulis komentar dukungan...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  isDense: true,
                ),
                maxLines: null,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: state.status == StoryStatus.submitting
                  ? null
                  : () {
                      final text = _commentController.text.trim();
                      if (text.isEmpty) return;
                      context.read<StoryBloc>().add(StoryCommentCreateRequested(storyId: widget.id, content: text));
                    },
              icon: state.status == StoryStatus.submitting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.send),
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inHours < 1) return '${diff.inMinutes}m lalu';
    if (diff.inDays < 1) return '${diff.inHours}j lalu';
    if (diff.inDays < 30) return '${diff.inDays}h lalu';
    return '${date.day}/${date.month}/${date.year}';
  }
}