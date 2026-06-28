import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_colors.dart';
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Papan Peringkat', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: AppColors.card,
        surfaceTintColor: Colors.transparent,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.05),
      ),
      body: BlocBuilder<GamificationBloc, GamificationState>(
        builder: (context, state) {
          if (state.status == GamificationStatus.loading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
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
                if (podium.isNotEmpty) _podium(podium),
                const SizedBox(height: 20),
                ...rest.map(_row),
              ],
            ),
          );
        },
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
          CircleAvatar(
            radius: place == 1 ? 32 : 26,
            backgroundColor: color.withOpacity(0.2),
            backgroundImage: e.avatar.isNotEmpty ? NetworkImage(e.avatar) : null,
            child: e.avatar.isEmpty
                ? Text(e.userName.isNotEmpty ? e.userName[0].toUpperCase() : '?',
                    style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: place == 1 ? 24 : 18))
                : null,
          ),
          const SizedBox(height: 6),
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
                colors: [color, color.withOpacity(0.6)],
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
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text('${e.rank}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.mutedForeground)),
          ),
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.secondary,
            backgroundImage: e.avatar.isNotEmpty ? NetworkImage(e.avatar) : null,
            child: e.avatar.isEmpty
                ? Text(e.userName.isNotEmpty ? e.userName[0].toUpperCase() : '?',
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold))
                : null,
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
