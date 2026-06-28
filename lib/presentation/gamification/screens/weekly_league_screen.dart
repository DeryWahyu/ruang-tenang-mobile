import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/media_url.dart';
import '../../common/widgets/app_avatar.dart';
import '../../../domain/entities/secondary_gamification.dart';
import '../cubit/secondary_cubits.dart';
import '../cubit/view_state.dart';

class WeeklyLeagueScreen extends StatelessWidget {
  const WeeklyLeagueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<WeeklyLeagueCubit>()..load(),
      child: const _WeeklyLeagueView(),
    );
  }
}

class _WeeklyLeagueView extends StatelessWidget {
  const _WeeklyLeagueView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Liga Mingguan', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: AppColors.card,
        surfaceTintColor: Colors.transparent,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.05),
      ),
      body: BlocBuilder<WeeklyLeagueCubit, ViewState<LeagueOverview>>(
        builder: (context, state) {
          if (state.status == ViewStatus.loading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (state.status == ViewStatus.failure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.emoji_events_outlined, size: 48, color: AppColors.mutedForeground),
                  const SizedBox(height: 16),
                  Text(state.error.isEmpty ? 'Gagal memuat liga' : state.error,
                      style: const TextStyle(color: AppColors.mutedForeground)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                      onPressed: () => context.read<WeeklyLeagueCubit>().load(), child: const Text('Coba Lagi')),
                ],
              ),
            );
          }
          final ov = state.data;
          if (ov == null) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Text('Belum ada musim liga yang aktif saat ini.',
                    textAlign: TextAlign.center, style: TextStyle(color: AppColors.mutedForeground)),
              ),
            );
          }
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => context.read<WeeklyLeagueCubit>().load(),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _divisionCard(ov),
                const SizedBox(height: 20),
                _promotionLegend(ov.division),
                const SizedBox(height: 16),
                const Text('Klasemen',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                const SizedBox(height: 12),
                ...ov.leaderboard.map((p) => _participantTile(p, ov.division)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _divisionCard(LeagueOverview ov) {
    final color = _hexColor(ov.division.color) ?? Colors.amber;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color, color.withOpacity(0.7)]),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Text(ov.division.icon, style: const TextStyle(fontSize: 40)),
          const SizedBox(height: 6),
          Text('Divisi ${ov.division.name}',
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          Text('Pekan ${ov.season.weekNumber} • ${ov.season.year}',
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _stat('#${ov.myRank}', 'Peringkatmu'),
              _stat('${ov.myWeeklyXp}', 'XP Pekan Ini'),
              _stat(_fmtTime(ov.timeLeftSeconds), 'Sisa Waktu'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _promotionLegend(LeagueDivision d) {
    return Row(
      children: [
        if (d.promotionSlots > 0) ...[
          const Icon(Icons.arrow_upward_rounded, color: AppColors.success, size: 16),
          const SizedBox(width: 4),
          Text('${d.promotionSlots} promosi',
              style: const TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(width: 16),
        ],
        if (d.demotionSlots > 0) ...[
          const Icon(Icons.arrow_downward_rounded, color: AppColors.destructive, size: 16),
          const SizedBox(width: 4),
          Text('${d.demotionSlots} degradasi',
              style: const TextStyle(color: AppColors.destructive, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ],
    );
  }

  Widget _participantTile(LeagueParticipant p, LeagueDivision d) {
    Color? edge;
    if (p.isPromoted) {
      edge = AppColors.success;
    } else if (p.isDemoted) {
      edge = AppColors.destructive;
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: p.isMe ? AppColors.secondary : AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: edge ?? (p.isMe ? AppColors.primary : AppColors.border.withOpacity(0.5)),
          width: (edge != null || p.isMe) ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text('#${p.rank}',
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.mutedForeground)),
          ),
          AppAvatar(
            imageUrl: resolveMediaUrl(p.avatar),
            name: p.username,
            size: 32,
            backgroundColor: AppColors.muted,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(p.isMe ? '${p.username} (kamu)' : p.username,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontWeight: p.isMe ? FontWeight.bold : FontWeight.w600, fontSize: 14)),
          ),
          if (p.isPromoted) const Icon(Icons.arrow_upward_rounded, color: AppColors.success, size: 16),
          if (p.isDemoted) const Icon(Icons.arrow_downward_rounded, color: AppColors.destructive, size: 16),
          const SizedBox(width: 6),
          Text('${p.weeklyXp} XP',
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.accentOrange, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _stat(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }

  String _fmtTime(int seconds) {
    if (seconds <= 0) return 'Selesai';
    final d = seconds ~/ 86400;
    final h = (seconds % 86400) ~/ 3600;
    if (d > 0) return '${d}h ${h}j';
    final m = (seconds % 3600) ~/ 60;
    return '${h}j ${m}m';
  }

  Color? _hexColor(String hex) {
    if (hex.isEmpty) return null;
    var h = hex.replaceAll('#', '').trim();
    if (h.length == 6) h = 'FF$h';
    if (h.length != 8) return null;
    final value = int.tryParse(h, radix: 16);
    return value == null ? null : Color(value);
  }
}
