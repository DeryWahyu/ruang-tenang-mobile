import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_colors.dart';
import '../../common/widgets/app_skeleton.dart';
import '../../common/widgets/app_empty_state.dart';
import '../../common/widgets/app_error_widget.dart';
import '../../../domain/entities/forum.dart';
import '../../common/widgets/app_avatar.dart';
import '../bloc/forum_bloc.dart';
import '../bloc/forum_event.dart';
import '../bloc/forum_state.dart';

class ForumListScreen extends StatelessWidget {
  const ForumListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ForumBloc>()
        ..add(const ForumListRequested())
        ..add(const ForumCategoriesRequested()),
      child: const _ForumListView(),
    );
  }
}

class _ForumListView extends StatefulWidget {
  const _ForumListView();

  @override
  State<_ForumListView> createState() => _ForumListViewState();
}

class _ForumListViewState extends State<_ForumListView> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forum Komunitas'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context),
          ),
        ],
      ),
      body: BlocConsumer<ForumBloc, ForumState>(
        listener: (context, state) {
          if (state.status == ForumStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.successMessage)));
            context.read<ForumBloc>().add(const ForumListRequested(refresh: true));
          }
        },
        builder: (context, state) {
          if (state.status == ForumStatus.loading) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: List.generate(5, (_) => const AppSkeletonCard()),
            );
          }
          if (state.status == ForumStatus.failure) {
            return AppErrorWidget(
              message: state.errorMessage.isNotEmpty ? state.errorMessage : 'Gagal memuat forum',
              onRetry: () => context.read<ForumBloc>().add(const ForumListRequested(refresh: true)),
            );
          }

          if (state.threads.isEmpty) {
            return const AppEmptyState(
              icon: Icons.forum_outlined,
              title: 'Belum Ada Diskusi',
              subtitle: 'Jadilah yang pertama memulai diskusi di komunitas.',
            );
          }

          return RefreshIndicator(
            onRefresh: () async => context.read<ForumBloc>().add(const ForumListRequested(refresh: true)),
            child: ListView.builder(
              cacheExtent: 600,
              padding: const EdgeInsets.all(16),
              itemCount: state.threads.length,
              itemBuilder: (context, index) => _buildThreadCard(context, state.threads[index]),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(context),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildThreadCard(BuildContext context, ForumThread thread) {
    final authorName = thread.user?.name ?? 'Anonim';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => context.push('/forum/${thread.slug}'),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: avatar + author + time + answered badge
                Row(
                  children: [
                    AppAvatar(
                      name: authorName,
                      imageUrl: thread.user?.avatar,
                      size: 40,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(authorName,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.foreground)),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.schedule_rounded, size: 11, color: AppColors.mutedForeground),
                              const SizedBox(width: 4),
                              Text(_formatDate(thread.createdAt),
                                  style: const TextStyle(color: AppColors.mutedForeground, fontSize: 11)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (thread.hasAcceptedAnswer)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.successLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.check_circle_rounded, size: 13, color: AppColors.success),
                            SizedBox(width: 4),
                            Text('Terjawab', style: TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                  ],
                ),

                // Category badge
                if (thread.category != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.red50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.red100),
                    ),
                    child: Text(thread.category!.name,
                        style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
                  ),
                ],

                // Title + preview
                const SizedBox(height: 10),
                Text(thread.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, height: 1.3, fontSize: 16),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                if (thread.content.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(thread.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.mutedForeground, fontSize: 13, height: 1.5)),
                ],

                // Footer stats
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.only(top: 12),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: AppColors.border)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.chat_bubble_outline_rounded, size: 17, color: AppColors.mutedForeground),
                      const SizedBox(width: 5),
                      Text('${thread.repliesCount}',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.gray700)),
                      const SizedBox(width: 4),
                      const Text('balasan', style: TextStyle(fontSize: 13, color: AppColors.mutedForeground)),
                      const SizedBox(width: 18),
                      Icon(thread.isLiked ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                          size: 17, color: thread.isLiked ? AppColors.primary : AppColors.mutedForeground),
                      const SizedBox(width: 5),
                      Text('${thread.likesCount}',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.gray700)),
                      const SizedBox(width: 4),
                      const Text('suka', style: TextStyle(fontSize: 13, color: AppColors.mutedForeground)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Diskusi Baru', style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Judul Diskusi', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: contentController,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Deskripsi (opsional)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                if (titleController.text.trim().isEmpty) return;
                context.read<ForumBloc>().add(ForumCreateRequested(title: titleController.text.trim(), content: contentController.text.trim()));
                Navigator.pop(ctx);
              },
              child: const Text('Kirim'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cari Diskusi'),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(hintText: 'Kata kunci...', border: OutlineInputBorder()),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () { Navigator.pop(ctx); context.read<ForumBloc>().add(const ForumListRequested(refresh: true)); }, child: const Text('Reset')),
          FilledButton(onPressed: () { Navigator.pop(ctx); context.read<ForumBloc>().add(ForumSearchRequested(_searchController.text.trim())); }, child: const Text('Cari')),
        ],
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