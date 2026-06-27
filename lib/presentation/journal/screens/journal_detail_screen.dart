import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/utils/date_utils.dart';
import '../../../domain/entities/journal.dart';
import '../../common/widgets/app_dialog.dart';
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

  void _confirmDelete(Journal journal) async {
    final confirmed = await AppDialog.showConfirmation(
      context,
      title: 'Hapus Jurnal',
      message: 'Yakin ingin menghapus jurnal "${journal.title.isEmpty ? 'Tanpa Judul' : journal.title}"? Tindakan ini tidak dapat dibatalkan.',
      confirmLabel: 'Hapus',
      cancelLabel: 'Batal',
      isDestructive: true,
      icon: Icons.delete_outline_rounded,
    );
    if (confirmed == true && mounted) {
      context.read<JournalBloc>().add(JournalDeleteRequested(journal.uuid));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<JournalBloc, JournalState>(
      listenWhen: (prev, curr) =>
          prev.successMessage != curr.successMessage ||
          prev.errorMessage != curr.errorMessage,
      listener: (context, state) {
        if (state.successMessage != null &&
            (state.status == JournalStatus.success)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: AppColors.success,
            ),
          );
          context.pop(true);
        }
        if (state.errorMessage != null && !state.isSubmitting) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.destructive,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.card,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.pop(),
            ),
            actions: [
              if (state.detail != null && !state.isSubmitting)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded),
                  onSelected: (value) {
                    final journal = state.detail!;
                    if (value == 'edit') {
                      context.push('/journal/create', extra: journal).then((_) {
                        if (mounted) {
                          context.read<JournalBloc>().add(JournalDetailRequested(widget.uuid));
                        }
                      });
                    } else if (value == 'delete') {
                      _confirmDelete(journal);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 20),
                          SizedBox(width: 12),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.destructive),
                          SizedBox(width: 12),
                          Text('Hapus', style: TextStyle(color: AppColors.destructive)),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
          body: _buildBody(state),
        );
      },
    );
  }

  Widget _buildBody(JournalState state) {
    if (state.isDetailLoading || state.detail == null) {
      if (state.status == JournalStatus.failure && state.detail == null) {
        return AppErrorWidget(
          message: state.errorMessage ?? 'Jurnal tidak ditemukan',
          onRetry: () => context.read<JournalBloc>().add(JournalDetailRequested(widget.uuid)),
        );
      }
      return const AppLoadingPage(message: 'Memuat jurnal...');
    }

    final journal = state.detail!;
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.spacingBase,
            AppDimensions.spacingBase,
            AppDimensions.spacingBase,
            AppDimensions.spacing3xl,
          ),
          children: [
            // Title
            Text(
              journal.title.isEmpty ? 'Tanpa Judul' : journal.title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.foreground,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            // Meta
            Row(
              children: [
                if (journal.moodEmoji != null && journal.moodEmoji!.isNotEmpty) ...[
                  Text(journal.moodEmoji!, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 6),
                  if (journal.moodLabel != null)
                    Text(
                      journal.moodLabel!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.mutedForeground,
                          ),
                    ),
                  const SizedBox(width: 12),
                ],
                Icon(Icons.access_time_rounded, size: 14, color: AppColors.mutedForeground),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    AppDateUtils.formatWithDay(journal.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.mutedForeground,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (journal.wordCount > 0) ...[
                  const SizedBox(width: 12),
                  Text(
                    '• ${journal.wordCount} kata',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.mutedForeground,
                        ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppDimensions.spacingBase),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: AppDimensions.spacingBase),
            // Content
            Text(
              journal.content,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.foreground,
                    height: 1.7,
                  ),
            ),
            if (journal.summary != null && journal.summary!.isNotEmpty) ...[
              const SizedBox(height: AppDimensions.spacing2xl),
              Container(
                padding: const EdgeInsets.all(AppDimensions.spacingBase),
                decoration: BoxDecoration(
                  color: AppColors.red50,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                  border: Border.all(color: AppColors.red100),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.auto_awesome_rounded, size: 20, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ringkasan AI',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: AppColors.red700,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            journal.summary!,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.secondaryForeground,
                                  height: 1.5,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (journal.tags.isNotEmpty) ...[
              const SizedBox(height: AppDimensions.spacing2xl),
              Text(
                'Tag',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.foreground,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: AppDimensions.spacingSm),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: journal.tags
                    .map((tag) => Chip(
                          label: Text('#$tag'),
                          backgroundColor: AppColors.muted,
                          labelStyle: const TextStyle(color: AppColors.foreground, fontSize: 13),
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                          ),
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
        if (state.isSubmitting)
          Container(
            color: Colors.black26,
            child: const Center(child: AppLoadingIndicator(size: 32)),
          ),
      ],
    );
  }
}
