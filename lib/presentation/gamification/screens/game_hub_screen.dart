import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/gamification.dart';
import '../../common/widgets/level_badge.dart';
import '../bloc/gamification_bloc.dart';
import '../bloc/gamification_event.dart';
import '../bloc/gamification_state.dart';

class GameHubScreen extends StatelessWidget {
  const GameHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<GamificationBloc>()
        ..add(const GamificationLevelRequested())
        ..add(const GamificationJourneyRequested())
        ..add(const GamificationExpHistoryRequested()),
      child: const _GameHubView(),
    );
  }
}

class _GameHubView extends StatelessWidget {
  const _GameHubView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Game Hub', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.leaderboard_rounded, color: AppColors.foreground),
              onPressed: () => context.push('/gamification/leaderboard'),
              tooltip: 'Papan Peringkat',
            ),
          ),
        ],
      ),
      body: BlocBuilder<GamificationBloc, GamificationState>(
        builder: (context, state) {
          if (state.levelInfo == null && state.status == GamificationStatus.loading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (state.status == GamificationStatus.failure && state.levelInfo == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: AppColors.destructive),
                  const SizedBox(height: 16),
                  Text(state.errorMessage, style: const TextStyle(color: AppColors.mutedForeground)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<GamificationBloc>().add(const GamificationLevelRequested());
                    },
                    child: const Text('Coba Lagi'),
                  )
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: AppColors.card,
            onRefresh: () async {
              context.read<GamificationBloc>().add(const GamificationLevelRequested());
              context.read<GamificationBloc>().add(const GamificationExpHistoryRequested(refresh: true));
            },
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(24),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      if (state.journey != null || state.levelInfo != null) _buildLevelCard(context, state),
                      const SizedBox(height: 32),
                      
                      const Text(
                        'Aktivitas Harian',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.foreground),
                      ),
                      const SizedBox(height: 16),
                      _buildDailyActivitiesGrid(context),
                      
                      const SizedBox(height: 32),
                      const Text(
                        'Eksplorasi Fitur',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.foreground),
                      ),
                      const SizedBox(height: 16),
                      _buildExplorationList(context),

                      const SizedBox(height: 32),
                      const Text(
                        'Komunitas & Kompetisi',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.foreground),
                      ),
                      const SizedBox(height: 16),
                      _buildSecondaryList(context),

                      if (state.expHistory.isNotEmpty) ...[
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Riwayat EXP',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.foreground),
                            ),
                            if (state.expHistory.length > 5)
                              TextButton(
                                onPressed: () => context.push('/gamification/exp-history'),
                                child: const Text('Lihat Semua', style: TextStyle(color: AppColors.primary)),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                          ),
                          child: Column(
                            children: state.expHistory.take(5).map((history) => _buildExpTile(history)).toList(),
                          ),
                        ),
                      ],
                      const SizedBox(height: 40),
                    ]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLevelCard(BuildContext context, GamificationState state) {
    final journey = state.journey;
    final info = state.levelInfo;

    // Prefer real journey data; fall back to /auth/me level info.
    final level = journey?.currentLevel ?? info?.level ?? 1;
    final badgeName = (journey?.badgeName.isNotEmpty ?? false)
        ? journey!.badgeName
        : (info?.badgeName.isNotEmpty ?? false ? info!.badgeName : 'Pemula');
    final badgeIcon = (journey?.badgeIcon.isNotEmpty ?? false)
        ? journey!.badgeIcon
        : (info?.badgeIcon.isNotEmpty ?? false ? info!.badgeIcon : '🌱');
    final currentExp = journey?.currentExp ?? info?.currentExp ?? 0;

    // Progress comes from the backend (progress_percent + exp_to_next_level).
    final double progress = journey != null
        ? (journey.progressPercent / 100).clamp(0.0, 1.0)
        : 0.0;
    final String progressLabel = journey != null
        ? (journey.expToNextLevel > 0
            ? '${journey.expToNextLevel} XP lagi ke Level ${level + 1}'
            : 'Level maksimum tercapai')
        : '$currentExp XP';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.shade400,
            Colors.orange.shade600,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 2),
                ),
                child: Center(
                  child: LevelBadge(icon: badgeIcon, size: 46, fallbackColor: Colors.white),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Level $level',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        badgeName,
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              if (journey != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 18),
                        const SizedBox(width: 4),
                        Text('${journey.currentStreak}',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    const Text('streak', style: TextStyle(color: Colors.white70, fontSize: 11)),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 28),
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  color: Colors.white,
                  minHeight: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$currentExp XP',
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Text(
                progressLabel,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDailyActivitiesGrid(BuildContext context) {
    return _buildListCard(
      context,
      title: 'Tugas Harian',
      subtitle: 'Selesaikan misi harianmu',
      icon: Icons.checklist_rounded,
      color: Colors.teal,
      onTap: () => context.push('/gamification/daily-tasks'),
    );
  }

  Widget _buildExplorationList(BuildContext context) {
    return Column(
      children: [
        _buildListCard(
          context,
          title: 'Koleksi Badge',
          subtitle: 'Lihat pencapaian yang telah kamu raih',
          icon: Icons.workspace_premium_rounded,
          color: Colors.amber.shade600,
          onTap: () => context.push('/gamification/badges'),
        ),
        const SizedBox(height: 12),
        _buildListCard(
          context,
          title: 'Toko Hadiah',
          subtitle: 'Tukar koin emas dengan hadiah',
          icon: Icons.storefront_rounded,
          color: AppColors.accentOrange,
          onTap: () => context.push('/gamification/rewards'),
        ),
        const SizedBox(height: 12),
        _buildListCard(
          context,
          title: 'Peta Progress',
          subtitle: 'Perjalanan kesehatan mentalmu',
          icon: Icons.map_rounded,
          color: Colors.blue,
          onTap: () => context.push('/gamification/progress-map'),
        ),
        const SizedBox(height: 12),
        _buildListCard(
          context,
          title: 'Papan Peringkat',
          subtitle: 'Lihat pencapaian komunitas',
          icon: Icons.leaderboard_rounded,
          color: AppColors.primary,
          onTap: () => context.push('/gamification/leaderboard'),
        ),
        const SizedBox(height: 12),
        _buildListCard(
          context,
          title: 'Mini Game',
          subtitle: 'Mindful Runner — bisa dimainkan offline',
          icon: Icons.videogame_asset_rounded,
          color: Colors.deepPurple,
          onTap: () => context.push('/game'),
        ),
      ],
    );
  }

  Widget _buildSecondaryList(BuildContext context) {
    return Column(
      children: [
        _buildListCard(
          context,
          title: 'Guild',
          subtitle: 'Bergabung & tumbuh bersama komunitas',
          icon: Icons.shield_rounded,
          color: Colors.indigo,
          onTap: () => context.push('/gamification/guild'),
        ),
        const SizedBox(height: 12),
        _buildListCard(
          context,
          title: 'Statistik Komunitas',
          subtitle: 'Lihat pencapaian & pertumbuhan komunitas',
          icon: Icons.insights_rounded,
          color: AppColors.info,
          onTap: () => context.push('/community'),
        ),
        const SizedBox(height: 12),
        _buildListCard(
          context,
          title: 'XP Boost & Combo',
          subtitle: 'Pacu perolehan XP dengan multiplier',
          icon: Icons.flash_on_rounded,
          color: AppColors.accentOrange,
          onTap: () => context.push('/gamification/xp-boost'),
        ),
      ],
    );
  }

  Widget _buildListCard(BuildContext context, {required String title, required String subtitle, required IconData icon, required Color color, required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => WidgetsBinding.instance.addPostFrameCallback((_) => onTap()),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(subtitle, style: const TextStyle(color: AppColors.mutedForeground, fontSize: 13)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: AppColors.mutedForeground.withValues(alpha: 0.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpTile(ExpHistory history) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppColors.accentOrange.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Icon(_expIconFor(history.activityType), color: AppColors.accentOrange, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      history.activityType, 
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      history.description, 
                      maxLines: 1, 
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.mutedForeground, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '+${history.points} XP', 
                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        Divider(height: 1, color: AppColors.border.withValues(alpha: 0.3), indent: 70),
      ],
    );
  }

  IconData _expIconFor(String activityType) {
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
}
