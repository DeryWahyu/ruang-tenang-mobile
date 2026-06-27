import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/forum.dart';
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
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == ForumStatus.failure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: AppColors.mutedForeground),
                  const SizedBox(height: 16),
                  Text(state.errorMessage, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<ForumBloc>().add(const ForumListRequested(refresh: true)),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          if (state.threads.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.forum_outlined, size: 64, color: AppColors.mutedForeground.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  const Text('Belum ada diskusi', style: TextStyle(color: AppColors.mutedForeground)),
                  const SizedBox(height: 8),
                  const Text('Mulai diskusi baru!', style: TextStyle(color: AppColors.mutedForeground, fontSize: 13)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => context.read<ForumBloc>().add(const ForumListRequested(refresh: true)),
            child: ListView.builder(
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
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/forum/${thread.slug}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.red100,
                    child: Text(
                      (thread.user?.name ?? 'U').substring(0, 1).toUpperCase(),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(thread.user?.name ?? 'Anonim', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        Text(_formatDate(thread.createdAt), style: const TextStyle(color: AppColors.mutedForeground, fontSize: 11)),
                      ],
                    ),
                  ),
                  if (thread.hasAcceptedAnswer)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.successLight,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('Terjawab', style: TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.w600)),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(thread.title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
              if (thread.content.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(thread.content, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.mutedForeground, fontSize: 13)),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.favorite, size: 18, color: thread.isLiked ? AppColors.primary : AppColors.mutedForeground),
                  const SizedBox(width: 4),
                  Text('${thread.likesCount}', style: const TextStyle(fontSize: 13, color: AppColors.mutedForeground)),
                  const SizedBox(width: 16),
                  const Icon(Icons.chat_bubble_outline, size: 18, color: AppColors.mutedForeground),
                  const SizedBox(width: 4),
                  Text('${thread.repliesCount} balasan', style: const TextStyle(fontSize: 13, color: AppColors.mutedForeground)),
                  const Spacer(),
                  if (thread.category != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.red50, borderRadius: BorderRadius.circular(4)),
                      child: Text(thread.category!.name, style: const TextStyle(fontSize: 11, color: AppColors.primary)),
                    ),
                ],
              ),
            ],
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