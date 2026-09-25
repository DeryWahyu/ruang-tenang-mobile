import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/chat.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../common/widgets/app_avatar.dart';
import 'audio_message_player.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onPin;
  final VoidCallback? onLike;
  final VoidCallback? onDislike;

  const ChatBubble({
    super.key,
    required this.message,
    this.onPin,
    this.onLike,
    this.onDislike,
  });

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthBloc>().state.user;
    final isUser = message.role == 'user';
    final timeStr = DateFormat('HH:mm').format(message.createdAt);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser)
            Container(
              margin: const EdgeInsets.only(right: 12),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFFECEE),
                border: Border.all(color: AppColors.red100),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(1),
                child: Image.asset(
                  'assets/images/mascot/chat-listen.webp',
                  fit: BoxFit.contain,
                  excludeFromSemantics: true,
                ),
              ),
            )
          else
            const SizedBox(width: 44),
          Flexible(
            child: GestureDetector(
              onLongPress: () => showModalBottomSheet<void>(
                context: context,
                builder: (sheetContext) => SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: Icon(
                          message.isPinned
                              ? Icons.push_pin
                              : Icons.push_pin_outlined,
                        ),
                        title: Text(
                          message.isPinned ? 'Lepas sematan' : 'Sematkan pesan',
                        ),
                        onTap: () {
                          Navigator.pop(sheetContext);
                          onPin?.call();
                        },
                      ),
                      if (!isUser) ...[
                        ListTile(
                          leading: const Icon(Icons.thumb_up_outlined),
                          title: const Text('Suka'),
                          onTap: () {
                            Navigator.pop(sheetContext);
                            onLike?.call();
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.thumb_down_outlined),
                          title: const Text('Tidak suka'),
                          onTap: () {
                            Navigator.pop(sheetContext);
                            onDislike?.call();
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isUser ? AppColors.primary : AppColors.card,
                  borderRadius: BorderRadius.circular(20).copyWith(
                    bottomRight: isUser
                        ? const Radius.circular(4)
                        : const Radius.circular(20),
                    bottomLeft: !isUser
                        ? const Radius.circular(4)
                        : const Radius.circular(20),
                  ),
                  border: isUser
                      ? null
                      : Border.all(
                          color: AppColors.border.withValues(alpha: 0.5),
                        ),
                  boxShadow: [
                    BoxShadow(
                      color: isUser
                          ? AppColors.primary.withValues(alpha: 0.2)
                          : Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: isUser
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    if (message.type == 'audio')
                      AudioMessagePlayer(
                        source: message.content,
                        isUser: isUser,
                      )
                    else
                      Text(
                        message.content,
                        style: TextStyle(
                          color: isUser
                              ? AppColors.primaryForeground
                              : AppColors.foreground,
                          fontSize: 15,
                          height: 1.4,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      timeStr,
                      style: TextStyle(
                        fontSize: 10,
                        color: isUser
                            ? Colors.white70
                            : AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isUser)
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: AppAvatar(
                imageUrl: user?.avatar,
                name: user?.name ?? 'User',
                size: 32,
              ),
            )
          else
            const SizedBox(width: 44),
        ],
      ),
    );
  }
}
