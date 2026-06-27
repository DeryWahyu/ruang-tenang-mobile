import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../common/widgets/app_error_widget.dart';
import '../../common/widgets/app_loading.dart';
import '../bloc/journal_bloc.dart';
import '../bloc/journal_event.dart';
import '../bloc/journal_state.dart';

class JournalDetailScreen extends StatefulWidget {
  final String uuid;

  const JournalDetailScreen({super.key, required this.uuid});

  @override
  State<JournalDetailScreen> createState() => _JournalDetailScreenState();
}

class _JournalDetailScreenState extends State<JournalDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JournalBloc>().add(JournalDetailRequested(widget.uuid));
    });
  }

  void _onDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Jurnal?'),
        content: const Text('Tindakan ini tidak dapat dibatalkan.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.destructive,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<JournalBloc>().add(JournalDeleteRequested(widget.uuid));
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _onEdit(dynamic journal) {
    context.push('/journal/create', extra: journal).then((_) {
      if (mounted) {
        context.read<JournalBloc>().add(JournalDetailRequested(widget.uuid));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<JournalBloc, JournalState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.status == JournalStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Jurnal berhasil dihapus')),
          );
          if (mounted) context.pop();
        } else if (state.status == JournalStatus.failure && state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.destructive,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state.isDetailLoading) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: AppLoadingIndicator()),
          );
        }

        final journal = state.detail;
        if (journal == null) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(backgroundColor: Colors.transparent),
            body: AppErrorWidget(
              message: state.errorMessage ?? 'Gagal memuat jurnal',
              onRetry: () => context.read<JournalBloc>().add(JournalDetailRequested(widget.uuid)),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 80,
                pinned: true,
                backgroundColor: AppColors.background,
                surfaceTintColor: Colors.transparent,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, color: AppColors.foreground),
                      onPressed: () => context.pop(),
                    ),
                  ),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.edit_rounded, color: AppColors.primary),
                      onPressed: () => _onEdit(journal),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                    decoration: BoxDecoration(
                      color: AppColors.destructive.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: AppColors.destructive),
                      onPressed: state.status == JournalStatus.loading ? null : _onDelete,
                    ),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tags row
                      if (journal.tags.isNotEmpty) ...[
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: journal.tags.map((tag) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '#$tag',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.mutedForeground,
                              ),
                            ),
                          )).toList(),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Title & Mood
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              journal.title.isEmpty ? 'Tanpa Judul' : journal.title,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppColors.foreground,
                                height: 1.2,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          if (journal.moodEmoji != null && journal.moodEmoji!.isNotEmpty) ...[
                            const SizedBox(width: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.card,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Text(
                                journal.moodEmoji!,
                                style: const TextStyle(fontSize: 32),
                              ),
                            ),
                          ],
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Metadata row
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: AppColors.border.withOpacity(0.5)),
                            bottom: BorderSide(color: AppColors.border.withOpacity(0.5)),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.calendar_month_rounded, size: 16, color: AppColors.mutedForeground),
                                const SizedBox(width: 8),
                                Text(
                                  DateFormat('dd MMMM yyyy, HH:mm').format(journal.createdAt),
                                  style: const TextStyle(color: AppColors.mutedForeground, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            if (journal.wordCount > 0)
                              Row(
                                children: [
                                  const Icon(Icons.text_snippet_rounded, size: 16, color: AppColors.mutedForeground),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${journal.wordCount} Kata',
                                    style: const TextStyle(color: AppColors.mutedForeground, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Content
                      Text(
                        journal.content,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.foreground,
                          height: 1.8,
                          letterSpacing: 0.2,
                        ),
                      ),
                      
                      const SizedBox(height: 60), // Bottom padding
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
