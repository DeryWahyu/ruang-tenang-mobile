import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../common/widgets/app_error_widget.dart';
import '../../common/widgets/app_loading.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input.dart';

/// Quick-start prompts shown on a fresh conversation.
const List<String> kChatSuggestions = [
  'Aku merasa cemas akhir-akhir ini',
  'Butuh teman untuk bercerita',
  'Bagaimana cara mengatasi stres?',
  'Aku sulit tidur belakangan ini',
  'Aku merasa kurang semangat hari ini',
];

class ChatDetailScreen extends StatefulWidget {
  final String? uuid;
  final String? initialPrompt;

  const ChatDetailScreen({super.key, this.uuid, this.initialPrompt});

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
    } else {
      final sessionUuid = context.read<ChatBloc>().state.currentSession?.uuid ?? widget.uuid!;
      context.read<ChatBloc>().add(ChatMessageSendRequested(uuid: sessionUuid, content: text));
    }
  }

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
          if (mounted) context.pop();
        }
        if (state.status == ChatStatus.detailSuccess) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
        }
      },
      builder: (context, state) {
        final session = state.currentSession;
        final title = _isNewSession ? 'Obrolan Baru' : (session?.title ?? 'Memuat...');

        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Row(
              children: [
                _aiAvatar(18),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          Container(width: 7, height: 7, decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle)),
                          const SizedBox(width: 5),
                          const Text('Ruang Tenang AI • Online',
                              style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                        ],
                      ),
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
              Expanded(child: _buildMessageList(state)),
              ChatInput(
                onSend: _sendMessage,
                isLoading: state.isSendingMessage || (state.isLoading && _isNewSession),
                initialText: _isNewSession ? widget.initialPrompt : null,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _aiAvatar(double radius) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFB7185), Color(0xFFEF4444), Color(0xFFDC2626)],
        ),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Icon(Icons.auto_awesome, color: Colors.white, size: radius),
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
      return _welcomeState();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      itemCount: messages.length + (state.isSendingMessage ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == messages.length && state.isSendingMessage) {
          return _typingBubble();
        }
        return ChatBubble(message: messages[index]);
      },
    );
  }

  Widget _welcomeState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFB7185), Color(0xFFEF4444), Color(0xFFDC2626)],
              ),
              boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.35), blurRadius: 24, offset: const Offset(0, 10))],
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 20),
          const Text('Halo! Saya AI Ruang Tenang',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.foreground)),
          const SizedBox(height: 8),
          const Text(
            'Ruang aman untuk bercerita, tanpa menghakimi. Apa yang ingin kamu bicarakan hari ini?',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.mutedForeground, height: 1.5),
          ),
          const SizedBox(height: 28),
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Icon(Icons.bolt_rounded, size: 16, color: AppColors.accentOrange),
                const SizedBox(width: 6),
                Text('Mulai cepat',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.mutedForeground)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ...kChatSuggestions.map(_suggestionTile),
        ],
      ),
    );
  }

  Widget _suggestionTile(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _sendMessage(text),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border.withOpacity(0.6)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), shape: BoxShape.circle),
                  child: const Icon(Icons.chat_bubble_outline_rounded, size: 16, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                ),
                const Icon(Icons.arrow_outward_rounded, size: 16, color: AppColors.mutedForeground),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _typingBubble() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(padding: const EdgeInsets.only(right: 12), child: _aiAvatar(16)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(20).copyWith(bottomLeft: const Radius.circular(4)),
              border: Border.all(color: AppColors.border.withOpacity(0.5)),
            ),
            child: const _TypingDots(),
          ),
        ],
      ),
    );
  }
}

/// Animated three-dot "typing…" indicator for the AI.
class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final t = (_controller.value + i * 0.2) % 1.0;
            final scale = 0.6 + 0.4 * (1 - (2 * t - 1).abs());
            return Container(
              margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.5 + 0.5 * (1 - (2 * t - 1).abs())),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
