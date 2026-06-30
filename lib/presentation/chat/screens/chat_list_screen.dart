import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../common/widgets/app_error_widget.dart';
import '../../common/widgets/app_loading.dart';
import '../../common/widgets/app_skeleton.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import 'chat_detail_screen.dart' show kChatSuggestions;

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatBloc>().add(const ChatSessionsRequested());
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll - currentScroll <= 200) {
      context.read<ChatBloc>().add(const ChatSessionsLoadMoreRequested());
    }
  }

  void _openNewChat({String? prompt}) {
    // Langsung masuk ke layar obrolan baru tanpa meminta judul terlebih
    // dahulu (mirip GPT/Gemini/Claude). Judul dibuat otomatis dari pesan
    // pertama. Prompt opsional diteruskan sebagai teks awal input.
    context.push('/chat/new', extra: prompt).then((_) {
      if (mounted) {
        context.read<ChatBloc>().add(const ChatSessionsRequested(refresh: true));
      }
    });
  }

  void _openSession(String uuid) {
    context.push('/chat/$uuid').then((_) {
      if (mounted) {
        context.read<ChatBloc>().add(const ChatSessionsRequested(refresh: true));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Konseling AI', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Teman cerita virtual Anda',
                style: TextStyle(fontSize: 12, color: AppColors.mutedForeground, fontWeight: FontWeight.normal)),
          ],
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openNewChat(),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.maps_ugc_rounded),
        label: const Text('Obrolan Baru', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          if (state.status == ChatStatus.failure && state.sessions.isEmpty) {
            return AppErrorWidget(
              message: state.errorMessage ?? 'Gagal memuat sesi obrolan',
              onRetry: () => context.read<ChatBloc>().add(const ChatSessionsRequested(refresh: true)),
            );
          }

          final loadingInitial = state.isLoading && state.sessions.isEmpty;

          return RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: AppColors.card,
            onRefresh: () async => context.read<ChatBloc>().add(const ChatSessionsRequested(refresh: true)),
            child: CustomScrollView(
              controller: _scrollController,
              cacheExtent: 600,
              slivers: [
                SliverToBoxAdapter(child: _hero()),
                SliverToBoxAdapter(child: _suggestions()),
                SliverToBoxAdapter(child: _sectionHeader()),
                if (loadingInitial)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, _) => const Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: AppSkeleton(height: 76, borderRadius: AppDimensions.radiusLg),
                        ),
                        childCount: 4,
                      ),
                    ),
                  )
                else if (state.sessions.isEmpty)
                  SliverToBoxAdapter(child: _emptyHint())
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index >= state.sessions.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Center(child: AppLoadingIndicator(size: 24)),
                            );
                          }
                          return _sessionCard(state.sessions[index].uuid, state.sessions[index].title,
                              state.sessions[index].createdAt);
                        },
                        childCount: state.sessions.length + (state.hasNextPage ? 1 : 0),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _hero() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFB7185), Color(0xFFEF4444), Color(0xFFDC2626)],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ruang Tenang AI',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('Siap mendengarkan kapan pun, tanpa menghakimi.',
                      style: TextStyle(color: Colors.white, fontSize: 12, height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _suggestions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: Row(
            children: [
              const Icon(Icons.bolt_rounded, size: 16, color: AppColors.accentOrange),
              const SizedBox(width: 6),
              Text('Mulai cepat',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.mutedForeground)),
            ],
          ),
        ),
        SizedBox(
          height: 42,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: kChatSuggestions.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final s = kChatSuggestions[i];
              return _chip(s);
            },
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _chip(String text) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _openNewChat(prompt: text),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add_rounded, size: 15, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.foreground)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Text('Riwayat Obrolan',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.foreground)),
    );
  }

  Widget _emptyHint() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        ),
        child: Column(
          children: [
            Icon(Icons.forum_outlined, size: 44, color: AppColors.mutedForeground.withValues(alpha: 0.7)),
            const SizedBox(height: 12),
            const Text('Belum ada obrolan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 6),
            const Text('Mulai percakapan pertamamu lewat tombol di atas atau pilih topik cepat.',
                textAlign: TextAlign.center, style: TextStyle(color: AppColors.mutedForeground, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _sessionCard(String uuid, String title, DateTime createdAt) {
    final dateStr = DateFormat('dd MMM yyyy').format(createdAt);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => _openSession(uuid),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
            ),
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFFB7185), Color(0xFFEF4444), Color(0xFFDC2626)],
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(Icons.auto_awesome, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded, size: 12, color: AppColors.mutedForeground),
                          const SizedBox(width: 4),
                          Text(dateStr, style: const TextStyle(color: AppColors.mutedForeground, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.mutedForeground),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

