import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_colors.dart';
import '../../common/widgets/app_skeleton.dart';
import '../bloc/gamification_bloc.dart';
import '../bloc/gamification_event.dart';
import '../bloc/gamification_state.dart';

class ExpHistoryScreen extends StatelessWidget {
  const ExpHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<GamificationBloc>()..add(const GamificationExpHistoryRequested()),
      child: const _ExpHistoryView(),
    );
  }
}

class _ExpHistoryView extends StatefulWidget {
  const _ExpHistoryView();

  @override
  State<_ExpHistoryView> createState() => _ExpHistoryViewState();
}

class _ExpHistoryViewState extends State<_ExpHistoryView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<GamificationBloc>().add(const GamificationExpHistoryLoadMore());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Riwayat EXP', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: AppColors.card,
        surfaceTintColor: Colors.transparent,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.05),
      ),
      body: BlocBuilder<GamificationBloc, GamificationState>(
        builder: (context, state) {
          if (state.expHistory.isEmpty && state.status == GamificationStatus.loading) {
            return ListView(
              padding: const EdgeInsets.all(20),
              children: List.generate(8, (_) => const AppSkeletonListItem()),
            );
          }
          if (state.expHistory.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: AppColors.accentOrangeLight, shape: BoxShape.circle),
                    child: const Icon(Icons.history_rounded, size: 56, color: AppColors.accentOrange),
                  ),
                  const SizedBox(height: 20),
                  const Text('Belum Ada Riwayat', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Mulai beraktivitas untuk mendapatkan XP!',
                      style: TextStyle(color: AppColors.mutedForeground)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async =>
                context.read<GamificationBloc>().add(const GamificationExpHistoryRequested(refresh: true)),
            child: ListView.separated(
              controller: _scrollController,
              cacheExtent: 600,
              padding: const EdgeInsets.all(20),
              itemCount: state.expHistory.length + (state.expHistoryHasMore ? 1 : 0),
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                if (index >= state.expHistory.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                  );
                }
                final h = state.expHistory[index];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: AppColors.accentOrange.withValues(alpha: 0.1), shape: BoxShape.circle),
                        child: Icon(_iconFor(h.activityType), color: AppColors.accentOrange, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_label(h.activityType),
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                            const SizedBox(height: 2),
                            Text(h.description,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: AppColors.mutedForeground, fontSize: 12)),
                            const SizedBox(height: 2),
                            Text(_formatDate(h.createdAt),
                                style: const TextStyle(color: AppColors.mutedForeground, fontSize: 11)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                        child: Text('+${h.points} XP',
                            style: const TextStyle(
                                color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _label(String activityType) {
    if (activityType.isEmpty) return 'Aktivitas';
    return activityType
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  IconData _iconFor(String activityType) {
    switch (activityType) {
      case 'chat_ai':
        return Icons.chat_bubble_outline_rounded;
      case 'upload_article':
        return Icons.edit_note_rounded;
      case 'forum_comment':
        return Icons.forum_outlined;
      case 'breathing':
        return Icons.air_rounded;
      case 'accepted_answer':
        return Icons.check_circle_outline_rounded;
      case 'post_upvote_given':
        return Icons.thumb_up_outlined;
      case 'post_upvote_removed':
        return Icons.thumb_down_outlined;
      case 'story_approved':
        return Icons.menu_book_rounded;
      case 'heart_received':
        return Icons.favorite_border_rounded;
      default:
        return Icons.star_rounded;
    }
  }

  String _formatDate(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    return '${d.day} ${months[d.month - 1]} ${d.year}, $hh:$mm';
  }
}
