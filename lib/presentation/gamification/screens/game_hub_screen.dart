import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_colors.dart';
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
      appBar: AppBar(
        title: const Text('Game Hub'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.leaderboard),
            onPressed: () => context.push('/gamification/leaderboard'),
          ),
        ],
      ),
      body: BlocBuilder<GamificationBloc, GamificationState>(
        builder: (context, state) {
          if (state.levelInfo == null && state.status == GamificationStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == GamificationStatus.failure && state.levelInfo == null) {
            return Center(child: Text(state.errorMessage));
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<GamificationBloc>().add(const GamificationLevelRequested());
              context.read<GamificationBloc>().add(const GamificationExpHistoryRequested(refresh: true));
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (state.levelInfo != null) _buildLevelCard(context, state),
                const SizedBox(height: 24),
                _buildMenuGrid(context),
                const SizedBox(height: 24),
                if (state.expHistory.isNotEmpty) ...[
                  Text('Riwayat EXP', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...state.expHistory.take(5).map((history) => _buildExpTile(history)),
                  if (state.expHistory.length > 5)
                    TextButton(
                      onPressed: () => context.push('/gamification/exp-history'),
                      child: const Text('Lihat Semua'),
                    ),
                ]
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLevelCard(BuildContext context, GamificationState state) {
    final info = state.levelInfo!;
    // Fake target exp for now, should calculate based on level
    final targetExp = (info.level + 1) * 1000;
    final progress = (info.currentExp / targetExp).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.accentOrange, AppColors.accentOrangeDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Level ${info.level}', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(info.badgeName.isNotEmpty ? info.badgeName : 'Pemula', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white24),
                child: Center(
                  child: Text(
                    info.badgeIcon.isNotEmpty ? info.badgeIcon : '🌟',
                    style: const TextStyle(fontSize: 30),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white24,
              color: Colors.white,
              minHeight: 12,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${info.currentExp} XP', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
              Text('$targetExp XP', style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _menuItem(context, 'Tugas Harian', Icons.checklist, AppColors.success, () {}),
        _menuItem(context, 'Badge', Icons.workspace_premium, AppColors.warning, () => context.push('/gamification/badges')),
        _menuItem(context, 'Peta Progress', Icons.map, AppColors.info, () {}),
        _menuItem(context, 'Guild', Icons.shield, AppColors.primary, () {}),
        _menuItem(context, 'Spin Harian', Icons.casino, AppColors.accentOrange, () => context.push('/gamification/spin')),
        _menuItem(context, 'Peti Misteri', Icons.card_giftcard, Colors.purple, () => context.push('/gamification/chests')),
      ],
    );
  }

  Widget _menuItem(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildExpTile(history) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: AppColors.accentOrange.withOpacity(0.1), shape: BoxShape.circle),
        child: const Icon(Icons.star, color: AppColors.accentOrange, size: 20),
      ),
      title: Text(history.activityType),
      subtitle: Text(history.description, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Text('+${history.points} XP', style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 14)),
    );
  }
}