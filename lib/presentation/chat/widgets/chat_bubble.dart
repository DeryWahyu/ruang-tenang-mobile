import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/utils/date_utils.dart';
import '../../../domain/entities/chat.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingBase),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              margin: const EdgeInsets.only(right: 8),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.red50,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.spa_rounded, size: 18, color: AppColors.primary),
            ),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(AppDimensions.spacingMd),
              decoration: BoxDecoration(
                color: isUser ? AppColors.primary : AppColors.red50,
                borderRadius: BorderRadius.circular(AppDimensions.radiusXl).copyWith(
                  bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(AppDimensions.radiusXl),
                  bottomLeft: !isUser ? const Radius.circular(4) : const Radius.circular(AppDimensions.radiusXl),
                ),
                border: !isUser ? Border.all(color: AppColors.red100) : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isUser ? AppColors.primaryForeground : AppColors.foreground,
                          height: 1.5,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppDateUtils.formatTime(message.createdAt),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: isUser
                              ? AppColors.primaryForeground.withValues(alpha: 0.7)
                              : AppColors.mutedForeground,
                        ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 40),
        ],
      ),
    );
  }
}
