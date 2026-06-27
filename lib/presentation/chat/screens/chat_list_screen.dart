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
import '../widgets/chat_session_tile.dart';

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
        title: const Text('Konseling AI'),
        centerTitle: false,
        backgroundColor: AppColors.card,
        surfaceTintColor: Colors.transparent,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Buka route 'new' untuk membuat obrolan baru
          context.push('/chat/new').then((_) {
            if (mounted) {
              context.read<ChatBloc>().add(const ChatSessionsRequested(refresh: true));
            }
          });
        },
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.primaryForeground,
        shape: const CircleBorder(),
        child: const Icon(Icons.chat_bubble_rounded),
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
                  child: AppSkeleton(height: 72, borderRadius: AppDimensions.radiusLg),
                ),
              ),
            );
          }

          if (state.sessions.isEmpty) {
            return AppEmptyState(
              icon: Icons.chat_rounded,
              title: 'Belum ada obrolan',
              subtitle: 'Mulai konseling dengan AI dengan mengetuk tombol (+)',
              actionLabel: 'Mulai Obrolan',
              onAction: () => context.push('/chat/new'),
            );
          }

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              context.read<ChatBloc>().add(const ChatSessionsRequested(refresh: true));
            },
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(AppDimensions.spacingBase),
              itemCount: state.sessions.length + (state.hasNextPage ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= state.sessions.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppDimensions.spacingBase),
                    child: Center(child: AppLoadingIndicator(size: 24)),
                  );
                }
                final session = state.sessions[index];
                return ChatSessionTile(
                  session: session,
                  onTap: () {
                    context.push('/chat/${session.uuid}').then((_) {
                      if (mounted) {
                        context.read<ChatBloc>().add(const ChatSessionsRequested(refresh: true));
                      }
                    });
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
