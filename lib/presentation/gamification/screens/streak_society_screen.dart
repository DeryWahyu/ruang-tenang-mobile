import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/secondary_gamification.dart';
import '../cubit/secondary_cubits.dart';
import '../cubit/view_state.dart';

class StreakSocietyScreen extends StatelessWidget {
  const StreakSocietyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<StreakSocietyCubit>()..load(),
      child: const _StreakSocietyView(),
    );
  }
}

class _StreakSocietyView extends StatelessWidget {
  const _StreakSocietyView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Streak Society', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: AppColors.card,
        surfaceTintColor: Colors.transparent,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.05),
      ),
      body: BlocConsumer<StreakSocietyCubit, ViewState<StreakSocietyOverview>>(
        listenWhen: (p, c) => p.actionMessage != c.actionMessage || p.error != c.error,
        listener: (context, state) {
          if (state.actionMessage.isNotEmpty) {
            _snack(context, state.actionMessage, AppColors.success);
          } else if (state.error.isNotEmpty && state.status == ViewStatus.failure) {
            _snack(context, state.error, AppColors.destructive);
          }
        },
        builder: (context, state) {
          if (state.data == null && state.status == ViewStatus.loading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (state.data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.local_fire_department_outlined, size: 48, color: AppColors.mutedForeground),
                  const SizedBox(height: 16),
                  Text(state.error.isEmpty ? 'Gagal memuat data' : state.error,
                      style: const TextStyle(color: AppColors.mutedForeground)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                      onPressed: () => context.read<StreakSocietyCubit>().load(), child: const Text('Coba Lagi')),
                ],
              ),
            );
          }
          final ov = state.data!;
          // Find the next society the user can still aim for.
          StreakSociety? nextSociety;
          for (final s in ov.allSocieties) {
            if (ov.currentStreak < s.minStreak) {
              nextSociety = s;
              break;
            }
          }
          final canJoin = ov.allSocieties.any((s) => ov.currentStreak >= s.minStreak && !s.isMember);

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => context.read<StreakSocietyCubit>().load(),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _streakCard(ov, nextSociety),
                if (canJoin) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: state.submitting ? null : () => context.read<StreakSocietyCubit>().join(),
                      icon: const Icon(Icons.group_add_rounded),
                      label: const Text('Gabung Society'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                const Text('Tingkatan Society',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                const SizedBox(height: 12),
                ...ov.allSocieties.map((s) => _societyTile(s, ov.currentStreak)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _streakCard(StreakSocietyOverview ov, StreakSociety? next) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.orange.shade400, Colors.red.shade400]),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 48),
          const SizedBox(height: 8),
          Text('${ov.currentStreak} hari',
              style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          const Text('Streak saat ini', style: TextStyle(color: Colors.white70, fontSize: 13)),
          if (ov.currentSociety != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
              child: Text('${ov.currentSociety!.icon} ${ov.currentSociety!.name}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
          if (next != null) ...[
            const SizedBox(height: 12),
            Text('${next.minStreak - ov.currentStreak} hari lagi menuju ${next.name}',
                style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ],
      ),
    );
  }

  Widget _societyTile(StreakSociety s, int currentStreak) {
    final reached = currentStreak >= s.minStreak;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: s.isMember ? AppColors.accentOrange : AppColors.border.withOpacity(0.5),
          width: s.isMember ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Opacity(
            opacity: reached ? 1 : 0.4,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: AppColors.accentOrangeLight, borderRadius: BorderRadius.circular(12)),
              child: Center(child: Text(s.icon, style: const TextStyle(fontSize: 22))),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    if (s.isMember) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.check_circle_rounded, color: AppColors.accentOrange, size: 14),
                    ],
                  ],
                ),
                Text('Min. ${s.minStreak} hari • ${s.memberCount} anggota',
                    style: const TextStyle(color: AppColors.mutedForeground, fontSize: 11)),
              ],
            ),
          ),
          if (s.exclusiveChat)
            const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.mutedForeground, size: 16),
        ],
      ),
    );
  }

  void _snack(BuildContext context, String msg, Color color) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }
}
