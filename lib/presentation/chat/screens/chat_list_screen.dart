import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../common/widgets/app_empty_state.dart';
import '../../common/widgets/app_error_widget.dart';
import '../../common/widgets/app_loading.dart';
import '../../common/widgets/app_skeleton.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import 'package:intl/intl.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Konseling AI', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(
              'Teman cerita virtual Anda',
              style: TextStyle(fontSize: 12, color: AppColors.mutedForeground, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/chat/new').then((_) {
            if (mounted) {
              context.read<ChatBloc>().add(const ChatSessionsRequested(refresh: true));
            }
          });
        },
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

          if (state.isLoading && state.sessions.isEmpty) {
            return ListView(
              padding: const EdgeInsets.all(AppDimensions.spacingBase),
              children: List.generate(
                5,
                (_) => const Padding(
                  padding: EdgeInsets.only(bottom: AppDimensions.spacingMd),
                  child: AppSkeleton(height: 85, borderRadius: AppDimensions.radiusLg),
                ),
              ),
            );
          }

          if (state.sessions.isEmpty) {
            return AppEmptyState(
              icon: Icons.forum_rounded,
              title: 'Mulai Cerita Anda',
              subtitle: 'Ruang Tenang AI siap mendengarkan tanpa menghakimi. Mulai percakapan sekarang.',
            );
          }

          return RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: AppColors.card,
            onRefresh: () async {
              context.read<ChatBloc>().add(const ChatSessionsRequested(refresh: true));
            },
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: state.sessions.length + (state.hasNextPage ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= state.sessions.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: AppLoadingIndicator(size: 24)),
                  );
                }
                final session = state.sessions[index];
                final dateStr = DateFormat('dd MMM yyyy, HH:mm').format(session.createdAt);
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () {
                      context.push('/chat/${session.uuid}').then((_) {
                        if (mounted) {
                          context.read<ChatBloc>().add(const ChatSessionsRequested(refresh: true));
                        }
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border.withOpacity(0.5)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.auto_awesome,
                              color: AppColors.primary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  session.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.access_time_rounded, size: 12, color: AppColors.mutedForeground),
                                    const SizedBox(width: 4),
                                    Text(
                                      dateStr,
                                      style: TextStyle(
                                        color: AppColors.mutedForeground,
                                        fontSize: 12,
                                      ),
                                    ),
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
                );
              },
            ),
          );
        },
      ),
    );
  }
}
