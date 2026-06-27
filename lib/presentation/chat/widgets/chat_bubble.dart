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
              child: Image.asset(
                'assets/images/logo.webp',
                width: 32,
                height: 32,
              ),
            ),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(AppDimensions.spacingMd),
              decoration: BoxDecoration(
                color: isUser ? null : AppColors.card,
                gradient: isUser
                    ? const LinearGradient(
                        colors: [AppColors.primary, AppColors.destructive],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 20),
                ),
                border: !isUser ? Border.all(color: AppColors.border) : null,
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
