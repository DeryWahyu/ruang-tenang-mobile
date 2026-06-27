import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/forum.dart';
import '../bloc/forum_bloc.dart';
import '../bloc/forum_event.dart';
import '../bloc/forum_state.dart';

class ForumDetailScreen extends StatelessWidget {
  final String slug;
  const ForumDetailScreen({super.key, required this.slug});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ForumBloc>()
        ..add(ForumDetailRequested(slug))
        ..add(ForumPostsRequested(slug)),
      child: _ForumDetailView(slug: slug),
    );
  }
}

class _ForumDetailView extends StatefulWidget {
  final String slug;
  const _ForumDetailView({required this.slug});

  @override
  State<_ForumDetailView> createState() => _ForumDetailViewState();
}

class _ForumDetailViewState extends State<_ForumDetailView> {
  final _replyController = TextEditingController();

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ForumBloc, ForumState>(
      listener: (context, state) {
        if (state.status == ForumStatus.success) {
          _replyController.clear();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.successMessage)));
        }
      },
      builder: (context, state) {
        final forum = state.detail;

        return Scaffold(
          appBar: AppBar(
            title: Text(forum?.title ?? 'Diskusi', maxLines: 1, overflow: TextOverflow.ellipsis),
            centerTitle: true,
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) {
                  context.read<ForumBloc>().add(ForumPostsRequested(widget.slug, sortBy: value));
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'newest', child: Text('Terbaru')),
                  const PopupMenuItem(value: 'oldest', child: Text('Terlama')),
                  const PopupMenuItem(value: 'top', child: Text('Terpopuler')),
                ],
                icon: const Icon(Icons.sort),
              ),
            ],
          ),
          body: state.status == ForumStatus.detailLoading
              ? const Center(child: CircularProgressIndicator())
              : state.status == ForumStatus.failure
                  ? Center(child: Text(state.errorMessage))
                  : Column(
                      children: [
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: () async {
                              context.read<ForumBloc>().add(ForumDetailRequested(widget.slug));
                              context.read<ForumBloc>().add(ForumPostsRequested(widget.slug, sortBy: state.sortBy));
                            },
                            child: ListView(
                              padding: const EdgeInsets.all(16),
                              children: [
                                if (forum != null) _buildForumHeader(context, forum, state),
                                const SizedBox(height: 16),
                                Text('Balasan (${state.posts.length})', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 12),
                                if (state.posts.isEmpty)
                                  const Padding(
                                    padding: EdgeInsets.all(24),
                                    child: Center(child: Text('Belum ada balasan', style: TextStyle(color: AppColors.mutedForeground))),
                                  ),
                                ...state.posts.map((post) => _buildPostCard(context, post)),
                              ],
                            ),
                          ),
                        ),
                        _buildReplyBar(context, state),
                      ],
                    ),
        );
      },
    );
  }

  Widget _buildForumHeader(BuildContext context, ForumThread forum, ForumState state) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.red100,
                  child: Text(
                    (forum.user?.name ?? 'U').substring(0, 1).toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(forum.user?.name ?? 'Anonim', style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text(_formatDate(forum.createdAt), style: const TextStyle(color: AppColors.mutedForeground, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(forum.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            if (forum.content.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(forum.content, style: const TextStyle(fontSize: 14, height: 1.5)),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                InkWell(
                  onTap: () => context.read<ForumBloc>().add(ForumLikeToggled(forum.id)),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        Icon(forum.isLiked ? Icons.favorite : Icons.favorite_border, size: 20, color: forum.isLiked ? AppColors.primary : AppColors.mutedForeground),
                        const SizedBox(width: 4),
                        Text('${forum.likesCount}', style: const TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.chat_bubble_outline, size: 20, color: AppColors.mutedForeground),
                const SizedBox(width: 4),
                Text('${forum.repliesCount}', style: const TextStyle(fontSize: 13, color: AppColors.mutedForeground)),
                if (forum.category != null) ...[
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.red50, borderRadius: BorderRadius.circular(4)),
                    child: Text(forum.category!.name, style: const TextStyle(fontSize: 11, color: AppColors.primary)),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard(BuildContext context, ForumPost post) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 0,
      color: post.isAcceptedAnswer ? AppColors.successLight : null,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.muted,
                  child: Text((post.user?.name ?? 'U').substring(0, 1).toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.user?.name ?? 'Anonim', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      Text(_formatDate(post.createdAt), style: const TextStyle(color: AppColors.mutedForeground, fontSize: 11)),
                    ],
                  ),
                ),
                if (post.isAcceptedAnswer)
                  const Icon(Icons.check_circle, color: AppColors.success, size: 20),
              ],
            ),
            const SizedBox(height: 10),
            Text(post.content, style: const TextStyle(fontSize: 14, height: 1.4)),
            const SizedBox(height: 10),
            Row(
              children: [
                _voteButton(
                  context,
                  icon: Icons.arrow_upward,
                  isActive: post.hasUserVoted && post.userVoteType == 'upvote',
                  onTap: () => context.read<ForumBloc>().add(ForumPostVoteRequested(postId: post.id, voteType: 'upvote')),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    '${post.netVotes}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: post.netVotes > 0 ? AppColors.success : post.netVotes < 0 ? AppColors.destructive : AppColors.mutedForeground,
                    ),
                  ),
                ),
                _voteButton(
                  context,
                  icon: Icons.arrow_downward,
                  isActive: post.hasUserVoted && post.userVoteType == 'downvote',
                  onTap: () => context.read<ForumBloc>().add(ForumPostVoteRequested(postId: post.id, voteType: 'downvote')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _voteButton(BuildContext context, {required IconData icon, required bool isActive, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 20, color: isActive ? AppColors.primary : AppColors.mutedForeground),
      ),
    );
  }

  Widget _buildReplyBar(BuildContext context, ForumState state) {
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
                controller: _replyController,
                decoration: InputDecoration(
                  hintText: 'Tulis balasan...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  isDense: true,
                ),
                maxLines: null,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: state.status == ForumStatus.submitting
                  ? null
                  : () {
                      final text = _replyController.text.trim();
                      if (text.isEmpty) return;
                      context.read<ForumBloc>().add(ForumPostCreateRequested(slug: widget.slug, content: text));
                    },
              icon: state.status == ForumStatus.submitting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.send),
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr).toLocal();
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 1) return 'Baru saja';
      if (diff.inHours < 1) return '${diff.inMinutes} menit lalu';
      if (diff.inDays < 1) return '${diff.inHours} jam lalu';
      if (diff.inDays < 30) return '${diff.inDays} hari lalu';
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return dateStr;
    }
  }
}