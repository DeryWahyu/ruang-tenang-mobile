import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/utils/date_utils.dart';
import '../../../domain/entities/chat.dart';

class ChatSessionTile extends StatelessWidget {
  final ChatSessionListItem session;
  final VoidCallback? onTap;

  const ChatSessionTile({super.key, required this.session, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingBase),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.red50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingBase),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.title.isEmpty ? 'Obrolan Baru' : session.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.foreground,
                              fontWeight: FontWeight.w600,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        session.lastMessage.isNotEmpty
                            ? session.lastMessage
                            : 'Mulai mengobrol...',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.mutedForeground,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingSm),
                Text(
                  AppDateUtils.formatRelative(session.createdAt),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
