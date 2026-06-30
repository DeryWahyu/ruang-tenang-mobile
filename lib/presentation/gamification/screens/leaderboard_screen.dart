import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/media_url.dart';
import '../../common/widgets/app_avatar.dart';
import '../../common/widgets/app_skeleton.dart';
import '../../../domain/entities/gamification.dart';
import '../bloc/gamification_bloc.dart';
import '../bloc/gamification_event.dart';
import '../bloc/gamification_state.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<GamificationBloc>()..add(const GamificationLeaderboardRequested()),
      child: const _LeaderboardView(),
    );
  }
}

class _LeaderboardView extends StatelessWidget {
  const _LeaderboardView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Papan Peringkat', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: AppColors.card,
        surfaceTintColor: Colors.transparent,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.05),
      ),
      body: BlocBuilder<GamificationBloc, GamificationState>(
        builder: (context, state) {
          if (state.status == GamificationStatus.loading) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: List.generate(8, (_) => const AppSkeletonListItem()),
            );
          }
          if (state.status == GamificationStatus.failure && state.leaderboard.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.mutedForeground),
                  const SizedBox(height: 16),
                  Text(state.errorMessage, style: const TextStyle(color: AppColors.mutedForeground)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<GamificationBloc>().add(const GamificationLeaderboardRequested()),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }
          if (state.leaderboard.isEmpty) {
            return const Center(
              child: Text('Belum ada peringkat bulan ini', style: TextStyle(color: AppColors.mutedForeground)),
            );
          }

          final entries = state.leaderboard;
          final podium = entries.take(3).toList();
          final rest = entries.length > 3 ? entries.sublist(3) : <HallOfFameEntry>[];

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async =>
                context.read<GamificationBloc>().add(const GamificationLeaderboardRequested()),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _headerBanner(entries.length),
                const SizedBox(height: 24),
                if (podium.isNotEmpty) _podium(podium),
                const SizedBox(height: 24),
                if (rest.isNotEmpty)
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 8),
                    child: Text('Peringkat Lainnya',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.mutedForeground)),
                  ),
                ...rest.map(_row),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _headerBanner(int total) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final now = DateTime.now();
    final monthLabel = '${months[now.month - 1]} ${now.year}';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFB300), Color(0xFFFF7043)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.orange.withValues(alpha: 0.3), blurRadius: 18, offset: const Offset(0, 8))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
            child: const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Hall of Fame',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text('$monthLabel • $total peserta',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _podium(List<HallOfFameEntry> top) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (top.length > 1) _podiumItem(top[1], 2, 90),
        if (top.isNotEmpty) _podiumItem(top[0], 1, 120),
        if (top.length > 2) _podiumItem(top[2], 3, 70),
      ],
    );
  }

  Widget _podiumItem(HallOfFameEntry e, int place, double height) {
    final colors = {
      1: Colors.amber,
      2: Colors.blueGrey.shade300,
      3: Colors.brown.shade300,
    };
    final color = colors[place] ?? AppColors.muted;
    return Expanded(
      child: Column(
        children: [
          if (place == 1)
            const Icon(Icons.workspace_premium_rounded, color: Colors.amber, size: 28)
          else
            const SizedBox(height: 28),
          const SizedBox(height: 4),
          Stack(
            alignment: Alignment.bottomCenter,
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(shape: BoxShape.circle, color: color),
                child: AppAvatar(
                  imageUrl: resolveMediaUrl(e.avatar),
                  name: e.userName,
                  size: place == 1 ? 64 : 52,
                  backgroundColor: AppColors.card,
                ),
              ),
              Positioned(
                bottom: -8,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.card, width: 2),
                  ),
                  child: Center(
                    child: Text('$place',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(e.userName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          Text('${e.monthlyXp} XP',
              style: const TextStyle(color: AppColors.mutedForeground, fontSize: 11)),
          const SizedBox(height: 6),
          Container(
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [color, color.withValues(alpha: 0.6)],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Center(
              child: Text('$place',
                  style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(HallOfFameEntry e) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.secondary,
              shape: BoxShape.circle,
            ),
            child: Text('${e.rank}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.foreground)),
          ),
          const SizedBox(width: 12),
          AppAvatar(
            imageUrl: resolveMediaUrl(e.avatar),
            name: e.userName,
            size: 36,
            backgroundColor: AppColors.secondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(e.userName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                if (e.tierName.isNotEmpty)
                  Text(e.tierName, style: const TextStyle(color: AppColors.mutedForeground, fontSize: 11)),
              ],
            ),
          ),
          Text('${e.monthlyXp} XP',
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.accentOrange)),
        ],
      ),
    );
  }
}
