import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/utils/date_utils.dart';
import '../../../domain/entities/journal.dart';
import '../../common/widgets/app_chip.dart';
import '../../common/widgets/app_skeleton.dart';

/// A single journal entry tile used in the list / search results.
class JournalCard extends StatelessWidget {
  final JournalListItem journal;
  final VoidCallback? onTap;

  const JournalCard({super.key, required this.journal, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingMd),
      padding: const EdgeInsets.all(AppDimensions.spacingBase),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (journal.moodEmoji != null && journal.moodEmoji!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(right: AppDimensions.spacingSm, top: 2),
                      child: Text(
                        journal.moodEmoji!,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  Expanded(
                    child: Text(
                      journal.title.isEmpty ? 'Tanpa Judul' : journal.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.foreground,
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (journal.preview.isNotEmpty) ...[
                const SizedBox(height: AppDimensions.spacingXs),
                Text(
                  journal.preview,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.mutedForeground,
                        height: 1.4,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (journal.tags.isNotEmpty) ...[
                const SizedBox(height: AppDimensions.spacingSm),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: journal.tags
                      .take(3)
                      .map((tag) => AppChip(
                            label: '#$tag',
                            isSelected: false,
                          ))
                      .toList(),
                ),
              ],
              const SizedBox(height: AppDimensions.spacingSm),
              Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 14,
                    color: AppColors.mutedForeground,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      AppDateUtils.formatRelative(journal.createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.mutedForeground,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Spacer(),
                  if (journal.wordCount > 0)
                    Text(
                      '${journal.wordCount} kata',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.mutedForeground,
                          ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Skeleton placeholder for [JournalCard] while loading.
class JournalCardSkeleton extends StatelessWidget {
  const JournalCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingMd),
      padding: const EdgeInsets.all(AppDimensions.spacingBase),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSkeleton(height: 18, width: 200, borderRadius: 4),
          SizedBox(height: 8),
          AppSkeleton(height: 14, borderRadius: 4),
          SizedBox(height: 6),
          AppSkeleton(height: 14, width: 150, borderRadius: 4),
        ],
      ),
    );
  }
}
