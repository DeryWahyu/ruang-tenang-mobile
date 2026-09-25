import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/network/api_client.dart';
import '../../../domain/repositories/upload_repository.dart';
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
  final ApiClient _api = sl<ApiClient>();

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
    final content = text.trim();
    if (content.isEmpty) return;

    if (_isNewSession) {
      // Obrolan baru: buat sesi tanpa judul lalu kirim pesan pertama. Judul
      // dibuat otomatis oleh backend dari pesan pertama ini
      // (mirip GPT/Gemini/Claude).
      context.read<ChatBloc>().add(ChatFirstMessageSent(content: content));
    } else {
      final sessionUuid =
          context.read<ChatBloc>().state.currentSession?.uuid ?? widget.uuid!;
      context.read<ChatBloc>().add(
        ChatMessageSendRequested(uuid: sessionUuid, content: content),
      );
    }
  }

  Future<void> _sendAudio(File file) async {
    try {
      final url = await sl<UploadRepository>().uploadAudio(file);
      if (!mounted) return;
      if (_isNewSession) {
        context.read<ChatBloc>().add(
          ChatFirstMessageSent(content: url, type: 'audio'),
        );
      } else {
        final sessionUuid =
            context.read<ChatBloc>().state.currentSession?.uuid ?? widget.uuid!;
        context.read<ChatBloc>().add(
          ChatMessageSendRequested(
            uuid: sessionUuid,
            content: url,
            type: 'audio',
          ),
        );
      }
    } finally {
      if (await file.exists()) await file.delete();
    }
  }

  String? get _sessionUuid =>
      context.read<ChatBloc>().state.currentSession?.uuid ?? widget.uuid;

  Future<void> _showContext() async {
    final uuid = _sessionUuid;
    if (uuid == null) return;
    try {
      final response = await _api.get<Map<String, dynamic>>(
        '/chat-sessions/$uuid/context-state',
        fromJson: (value) => Map<String, dynamic>.from(value as Map),
      );
      final preferences = Map<String, dynamic>.from(
        response.data?['preferences'] as Map? ?? {},
      );
      final runtime = Map<String, dynamic>.from(
        response.data?['runtime'] as Map? ?? {},
      );
      if (!mounted) return;
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (sheetContext) => StatefulBuilder(
          builder: (sheetContext, update) => SafeArea(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.75,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Konteks obrolan',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sumber aktif: ${(runtime['effective_sources'] as List? ?? []).join(', ')}',
                  ),
                  const SizedBox(height: 12),
                  ...const <String, String>{
                    'enable_mood_context': 'Mood',
                    'enable_journal_context': 'Jurnal',
                    'enable_daily_task_context': 'Misi harian',
                    'enable_xp_level_context': 'Level dan XP',
                    'enable_playlist_context': 'Playlist',
                    'enable_rewards_context': 'Hadiah',
                    'enable_progress_map_context': 'Peta perjalanan',
                    'enable_social_context': 'Komunitas',
                  }.entries.map(
                    (entry) => SwitchListTile(
                      title: Text(entry.value),
                      value: preferences[entry.key] == true,
                      onChanged: (value) async {
                        try {
                          final changed = await _api.put<Map<String, dynamic>>(
                            '/chat-sessions/$uuid/context-preferences',
                            data: {entry.key: value},
                            fromJson: (json) =>
                                Map<String, dynamic>.from(json as Map),
                          );
                          if (!changed.success) throw Exception(changed.error);
                          update(() => preferences[entry.key] = value);
                        } catch (_) {
                          _showError('Preferensi konteks belum tersimpan.');
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } catch (_) {
      _showError('Konteks obrolan belum berhasil dimuat.');
    }
  }

  Future<void> _showSummary() async {
    final uuid = _sessionUuid;
    if (uuid == null) return;
    try {
      Map<String, dynamic>? summary;
      try {
        final response = await _api.get<Map<String, dynamic>>(
          '/chat-sessions/$uuid/summary',
          fromJson: (value) => Map<String, dynamic>.from(value as Map),
        );
        summary = response.data;
      } catch (_) {
        /* A new conversation has no summary yet. */
      }
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (dialogContext, update) => AlertDialog(
            title: const Text('Ringkasan obrolan'),
            content: SingleChildScrollView(
              child: Text(
                summary?['summary']?.toString() ?? 'Belum ada ringkasan.',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Tutup'),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    final generated = await _api.post<Map<String, dynamic>>(
                      '/chat-sessions/$uuid/summary',
                      data: {},
                      fromJson: (value) =>
                          Map<String, dynamic>.from(value as Map),
                    );
                    update(() => summary = generated.data);
                  } catch (_) {
                    _showError('Ringkasan belum berhasil dibuat.');
                  }
                },
                child: const Text('Buat ringkasan'),
              ),
            ],
          ),
        ),
      );
    } catch (_) {
      _showError('Ringkasan belum berhasil dimuat.');
    }
  }

  Future<void> _export(String format) async {
    final uuid = _sessionUuid;
    if (uuid == null) return;
    try {
      final response = await _api.post<Map<String, dynamic>>(
        '/chat-sessions/$uuid/export',
        data: {'format': format},
        fromJson: (value) => Map<String, dynamic>.from(value as Map),
      );
      if (!response.success || response.data == null) {
        throw Exception(response.error);
      }
      final data = response.data!;
      final filename = (data['filename'] as String? ?? 'obrolan.$format')
          .replaceAll(RegExp(r'[/\\]'), '_');
      final file = File('${(await getTemporaryDirectory()).path}/$filename');
      if (format == 'pdf') {
        await file.writeAsBytes(base64Decode(data['content'] as String));
      } else {
        await file.writeAsString(data['content'] as String);
      }
      await Share.shareXFiles([
        XFile(
          file.path,
          mimeType: format == 'pdf' ? 'application/pdf' : 'text/plain',
        ),
      ], subject: 'Ekspor obrolan');
    } catch (_) {
      _showError('Obrolan belum berhasil diekspor.');
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _togglePin(int messageId) async {
    try {
      await _api.put<dynamic>('/chat-messages/$messageId/pin');
      final uuid = _sessionUuid;
      if (mounted && uuid != null) {
        context.read<ChatBloc>().add(ChatSessionDetailRequested(uuid));
      }
    } catch (_) {
      _showError('Pesan belum berhasil disematkan.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatBloc, ChatState>(
      listenWhen: (prev, curr) {
        if (prev.status != ChatStatus.createSuccess &&
            curr.status == ChatStatus.createSuccess &&
            _isNewSession) {
          return true;
        }
        if (prev.currentSession?.messages.length !=
            curr.currentSession?.messages.length) {
          return true;
        }
        // Tampilkan error yang baru muncul (mis. gagal kirim / kuota chat habis).
        if (curr.errorMessage != null &&
            curr.errorMessage!.isNotEmpty &&
            curr.errorMessage != prev.errorMessage) {
          return true;
        }
        return false;
      },
      listener: (context, state) {
        if (state.status == ChatStatus.createSuccess && _isNewSession) {
          // Sesi baru sudah dibuat dan pesan pertama sedang dikirim oleh bloc.
          // Tetap di layar ini (tanpa navigasi ulang) dan render dari
          // currentSession agar tidak balapan dengan proses pengiriman.
          if (mounted) {
            setState(() => _isNewSession = false);
          }
        }
        if (state.status == ChatStatus.detailSuccess) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _scrollToBottom(),
          );
        }
        // Umpan balik kegagalan kirim pesan / kuota habis kepada pengguna.
        final error = state.errorMessage;
        if (error != null && error.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error),
              backgroundColor: AppColors.destructive,
            ),
          );
        }
      },
      builder: (context, state) {
        final session = state.currentSession;
        final title = _isNewSession
            ? 'Obrolan Baru'
            : (session?.title ?? 'Memuat...');

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
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Text(
                            'Ruang Tenang AI • Online',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.mutedForeground,
                            ),
                          ),
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
            shadowColor: Colors.black.withValues(alpha: 0.05),
            actions: [
              if (!_isNewSession)
                PopupMenuButton<String>(
                  tooltip: 'Opsi obrolan',
                  onSelected: (action) {
                    if (action == 'context') _showContext();
                    if (action == 'summary') _showSummary();
                    if (action == 'txt' || action == 'pdf') _export(action);
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'context', child: Text('Konteks AI')),
                    PopupMenuItem(value: 'summary', child: Text('Ringkasan')),
                    PopupMenuItem(value: 'txt', child: Text('Ekspor TXT')),
                    PopupMenuItem(value: 'pdf', child: Text('Ekspor PDF')),
                  ],
                ),
            ],
          ),
          body: Column(
            children: [
              Expanded(child: _buildMessageList(state)),
              ChatInput(
                onSend: _sendMessage,
                onSendAudio: _sendAudio,
                isLoading:
                    state.isSendingMessage ||
                    (state.isLoading && _isNewSession),
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
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset('assets/images/logo.webp', fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildMessageList(ChatState state) {
    if (state.status == ChatStatus.failure && state.currentSession == null) {
      return AppErrorWidget(
        message: state.errorMessage ?? 'Gagal memuat pesan',
        onRetry: () {
          if (!_isNewSession && widget.uuid != null) {
            context.read<ChatBloc>().add(
              ChatSessionDetailRequested(widget.uuid!),
            );
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
      cacheExtent: 800,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      itemCount: messages.length + (state.isSendingMessage ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == messages.length && state.isSendingMessage) {
          return _typingBubble();
        }
        return ChatBubble(
          message: messages[index],
          onPin: () => _togglePin(messages[index].id),
          onLike: () => context.read<ChatBloc>().add(
            ChatMessageLikeToggled(messages[index].id),
          ),
          onDislike: () => context.read<ChatBloc>().add(
            ChatMessageDislikeToggled(messages[index].id),
          ),
        );
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
                colors: [
                  Color(0xFFFB7185),
                  Color(0xFFEF4444),
                  Color(0xFFDC2626),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.psychology_alt_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Halo! Saya AI Ruang Tenang',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.foreground,
            ),
          ),
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
                Icon(
                  Icons.bolt_rounded,
                  size: 16,
                  color: AppColors.accentOrange,
                ),
                const SizedBox(width: 6),
                Text(
                  'Mulai cepat',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.mutedForeground,
                  ),
                ),
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
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.6),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 16,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    text,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_outward_rounded,
                  size: 16,
                  color: AppColors.mutedForeground,
                ),
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
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _aiAvatar(16),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(
                20,
              ).copyWith(bottomLeft: const Radius.circular(4)),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.5),
              ),
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

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
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
                    color: AppColors.primary.withValues(
                      alpha: 0.5 + 0.5 * (1 - (2 * t - 1).abs()),
                    ),
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
