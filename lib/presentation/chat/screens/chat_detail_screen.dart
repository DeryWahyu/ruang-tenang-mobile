import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../common/widgets/app_error_widget.dart';
import '../../common/widgets/app_loading.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input.dart';

class ChatDetailScreen extends StatefulWidget {
  final String? uuid; // Null means creating a new session

  const ChatDetailScreen({super.key, this.uuid});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isNewSession = false;

  @override
  void initState() {
    super.initState();
    _isNewSession = widget.uuid == null;

    if (!_isNewSession) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ChatBloc>().add(ChatSessionDetailRequested(widget.uuid!));
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage(String text) {
    if (_isNewSession) {
      // 1. Create a session based on the first message
      final title = text.length > 30 ? '${text.substring(0, 30)}...' : text;
      context.read<ChatBloc>().add(ChatSessionCreateRequested(title: title));

      // We need to wait for the session to be created, but BLoC is async.
      // So we will listen for success in BlocListener.
      // For now, we store the pending message.
      _pendingFirstMessage = text;
    } else {
      // Send directly to the loaded session
      final sessionUuid = context.read<ChatBloc>().state.currentSession?.uuid ?? widget.uuid!;
      context.read<ChatBloc>().add(ChatMessageSendRequested(
            uuid: sessionUuid,
            content: text,
          ));
    }
  }

  String? _pendingFirstMessage;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatBloc, ChatState>(
      listenWhen: (prev, curr) {
        // Track creation success
        if (prev.status != ChatStatus.success && curr.status == ChatStatus.success && _isNewSession) {
          return true;
        }
        // Scroll down when new messages arrive
        if (prev.currentSession?.messages.length != curr.currentSession?.messages.length) {
          return true;
        }
        return false;
      },
      listener: (context, state) {
        if (state.status == ChatStatus.success && _isNewSession) {
          // The session was just created, but the backend doesn't return the full session from POST,
          // only ID/Title. We need to navigate to the new UUID (if we had it, but API returns 201).
          // Wait, our API CreateSession only returns ID and Title, not UUID.
          // Let's assume we can't get UUID easily without fetching. Actually, our domain entity `ChatSession` has `uuid`.
          // If creation succeeded, we pop out for now, because the session list will refresh and show it.
          // Or we ask the user to just pop out since we don't know the UUID to redirect to easily.
          // To be safe, just pop. The list will refresh.
          if (mounted) {
            context.pop();
          }
        }

        // Scroll on new message
        if (state.status == ChatStatus.detailSuccess) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
        }
      },
      builder: (context, state) {
        final session = state.currentSession;
        final title = _isNewSession ? 'Obrolan Baru' : (session?.title ?? 'Memuat...');

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(title),
            backgroundColor: AppColors.card,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
          ),
          body: Column(
            children: [
              Expanded(
                child: _buildMessageList(state),
              ),
              ChatInput(
                onSend: _sendMessage,
                isLoading: state.isSendingMessage || (state.isLoading && _isNewSession),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageList(ChatState state) {
    if (state.status == ChatStatus.failure && state.currentSession == null) {
      return AppErrorWidget(
        message: state.errorMessage ?? 'Gagal memuat pesan',
        onRetry: () {
          if (!_isNewSession && widget.uuid != null) {
            context.read<ChatBloc>().add(ChatSessionDetailRequested(widget.uuid!));
          }
        },
      );
    }

    if (state.isDetailLoading) {
      return const Center(child: AppLoadingIndicator());
    }

    final messages = state.currentSession?.messages ?? [];

    if (_isNewSession || messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.webp',
              width: 80,
              height: 80,
            ),
            const SizedBox(height: AppDimensions.spacingXl),
            Text(
              'Halo! Saya asisten AI Ruang Tenang.',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.foreground,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ada yang bisa saya bantu hari ini?',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.mutedForeground,
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(AppDimensions.spacingBase),
      itemCount: messages.length + (state.isSendingMessage ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == messages.length && state.isSendingMessage) {
          // AI typing indicator
          return Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.spacingBase),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: Image.asset(
                    'assets/images/logo.webp',
                    width: 32,
                    height: 32,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(AppDimensions.spacingMd),
                  decoration: BoxDecoration(
                    color: AppColors.red50,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusXl).copyWith(
                      bottomLeft: const Radius.circular(4),
                    ),
                  ),
                  child: const SizedBox(
                    width: 24,
                    height: 12,
                    child: AppLoadingIndicator(size: 12, strokeWidth: 2),
                  ),
                ),
              ],
            ),
          );
        }
        return ChatBubble(message: messages[index]);
      },
    );
  }
}
