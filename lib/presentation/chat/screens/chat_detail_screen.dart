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
  final String? uuid;

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
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _sendMessage(String text) {
    if (_isNewSession) {
      final title = text.length > 30 ? '${text.substring(0, 30)}...' : text;
      context.read<ChatBloc>().add(ChatSessionCreateRequested(title: title));
      _pendingFirstMessage = text;
    } else {
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
        if (prev.status != ChatStatus.success && curr.status == ChatStatus.success && _isNewSession) {
          return true;
        }
        if (prev.currentSession?.messages.length != curr.currentSession?.messages.length) {
          return true;
        }
        return false;
      },
      listener: (context, state) {
        if (state.status == ChatStatus.success && _isNewSession) {
          if (mounted) {
            context.pop();
          }
        }
        if (state.status == ChatStatus.detailSuccess) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
        }
      },
      builder: (context, state) {
        final session = state.currentSession;
        final title = _isNewSession ? 'Konseling Baru' : (session?.title ?? 'Memuat...');

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Row(
              children: [
                const CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.auto_awesome, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const Text('Ruang Tenang AI', style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.card,
            surfaceTintColor: Colors.transparent,
            elevation: 1,
            shadowColor: Colors.black.withOpacity(0.05),
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_awesome, size: 48, color: AppColors.primary),
              ),
              const SizedBox(height: 24),
              Text(
                'Halo! Saya AI Ruang Tenang.',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.foreground,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Ruang aman untuk Anda bercerita, tanpa menghakimi. Apa yang ingin Anda diskusikan hari ini?',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.mutedForeground,
                        height: 1.5,
                      ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      itemCount: messages.length + (state.isSendingMessage ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == messages.length && state.isSendingMessage) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 12),
                  child: const CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.auto_awesome, color: Colors.white, size: 16),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(20).copyWith(
                      bottomLeft: const Radius.circular(4),
                    ),
                    border: Border.all(color: AppColors.border.withOpacity(0.5)),
                  ),
                  child: const SizedBox(
                    width: 32,
                    height: 16,
                    child: AppLoadingIndicator(size: 16, strokeWidth: 2.5),
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
