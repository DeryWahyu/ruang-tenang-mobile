import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../domain/entities/journal.dart';

class JournalCard extends StatelessWidget {
  final JournalListItem journal;
  final VoidCallback? onTap;

  const JournalCard({super.key, required this.journal, this.onTap});

  @override
  Widget build(BuildContext context) {
    final moodLabel = journal.moodLabel?.trim();
    final hasMoodLabel = moodLabel != null && moodLabel.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
        boxShadow: [
          BoxShadow(
            color: AppColors.foreground.withValues(alpha: 0.035),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(17, 16, 17, 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const _JournalAccentMark(),
                    const SizedBox(width: 8),
                    Text(
                      AppDateUtils.formatRelative(journal.createdAt),
                      style: const TextStyle(
                        color: AppColors.mutedForeground,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    if (hasMoodLabel)
                      Container(
                        constraints: const BoxConstraints(maxWidth: 128),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.red50,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          moodLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.red700,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  journal.title.isEmpty ? 'Tanpa Judul' : journal.title,
                  style: const TextStyle(
                    color: AppColors.foreground,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    height: 1.35,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (journal.preview.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    journal.preview,
                    style: const TextStyle(
                      color: AppColors.mutedForeground,
                      height: 1.5,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (journal.tags.isNotEmpty) ...[
                  const SizedBox(height: 11),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      ...journal.tags.take(3).map(_tag),
                      if (journal.tags.length > 3)
                        _tag('+${journal.tags.length - 3}'),
                    ],
                  ),
                ],
                const SizedBox(height: 13),
                const Divider(height: 1, color: AppColors.border),
                const SizedBox(height: 11),
                Row(
                  children: [
                    Text(
                      '${journal.wordCount} kata',
                      style: const TextStyle(
                        color: AppColors.mutedForeground,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    if (journal.shareWithAI)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.red50,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.psychology_alt_rounded,
                              size: 13,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Dibagikan ke AI',
                              style: TextStyle(
                                color: AppColors.red700,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tag(String tag) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: AppColors.muted,
      borderRadius: BorderRadius.circular(9),
    ),
    child: Text(
      tag.startsWith('+') ? tag : '#$tag',
      style: const TextStyle(
        color: AppColors.gray600,
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

class _JournalAccentMark extends StatelessWidget {
  const _JournalAccentMark();

  @override
  Widget build(BuildContext context) => Container(
    width: 8,
    height: 8,
    decoration: const BoxDecoration(
      color: AppColors.primary,
      shape: BoxShape.circle,
    ),
  );
}

class JournalCardSkeleton extends StatelessWidget {
  const JournalCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 12,
            width: 86,
            decoration: BoxDecoration(
              color: AppColors.muted,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 15),
          Container(
            height: 17,
            width: MediaQuery.sizeOf(context).width * 0.58,
            decoration: BoxDecoration(
              color: AppColors.muted,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 13,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.muted.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 13,
            width: MediaQuery.sizeOf(context).width * 0.68,
            decoration: BoxDecoration(
              color: AppColors.muted.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 17),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 13),
          Container(
            height: 12,
            width: 110,
            decoration: BoxDecoration(
              color: AppColors.muted,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ],
      ),
    );
  }
}
