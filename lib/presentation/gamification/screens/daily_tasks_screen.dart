import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/gamification.dart';
import '../bloc/gamification_bloc.dart';
import '../bloc/gamification_event.dart';
import '../bloc/gamification_state.dart';

class DailyTasksScreen extends StatelessWidget {
  const DailyTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<GamificationBloc>()..add(const GamificationDailyTasksRequested(processLogin: true)),
      child: const _DailyTasksView(),
    );
  }
}

class _DailyTasksView extends StatelessWidget {
  const _DailyTasksView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Tugas Harian', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: AppColors.card,
        surfaceTintColor: Colors.transparent,
        elevation: 1,
      ),
      body: BlocConsumer<GamificationBloc, GamificationState>(
        listenWhen: (prev, curr) =>
            prev.successMessage != curr.successMessage || prev.errorMessage != curr.errorMessage,
        listener: (context, state) {
          if (state.successMessage.isNotEmpty) {
            _snack(context, state.successMessage, AppColors.success);
          } else if (state.errorMessage.isNotEmpty && state.status == GamificationStatus.failure) {
            _snack(context, state.errorMessage, AppColors.destructive);
          }
        },
        builder: (context, state) {
          final summary = state.dailyTasks;
          if (summary == null && state.status == GamificationStatus.loading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (summary == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.mutedForeground),
                  const SizedBox(height: 16),
                  Text(state.errorMessage.isEmpty ? 'Gagal memuat tugas' : state.errorMessage,
                      style: const TextStyle(color: AppColors.mutedForeground)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<GamificationBloc>().add(const GamificationDailyTasksRequested()),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          final claimable = summary.claimableCount;
          final submitting = state.status == GamificationStatus.submitting;
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async => context.read<GamificationBloc>().add(const GamificationDailyTasksRequested()),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _summaryCard(summary),
                const SizedBox(height: 16),
                if (claimable > 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: submitting
                            ? null
                            : () => context.read<GamificationBloc>().add(const GamificationAllTasksClaimed()),
                        icon: const Icon(Icons.redeem_rounded),
                        label: Text('Klaim Semua ($claimable)'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentOrange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                  ),
                for (final task in summary.tasks) _taskTile(context, task, submitting),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _summaryCard(DailyTaskSummary s) {
    final progress = s.totalTasks == 0 ? 0.0 : (s.completedTasks / s.totalTasks).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.orange.shade400, Colors.deepOrange.shade400]),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 6),
              Text('Login Streak: ${s.loginStreak} hari',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 14),
          Text('${s.completedTasks}/${s.totalTasks} tugas selesai',
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: double.infinity,
              height: 10,
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white24,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.star_rounded, color: Colors.white, size: 16),
              const SizedBox(width: 4),
              Text('${s.totalXpEarned}/${s.totalXpPossible} XP',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(width: 16),
              const Icon(Icons.monetization_on_rounded, color: Colors.white, size: 16),
              const SizedBox(width: 4),
              Text('${s.totalCoinsEarned}/${s.totalCoinsPossible} koin',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _taskTile(BuildContext context, DailyTask task, bool submitting) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: task.isClaimed ? AppColors.success.withValues(alpha: 0.4) : AppColors.border.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.accentOrangeLight,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Text(task.taskIcon, style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        task.taskName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (task.premiumOnly) ...[
                      const SizedBox(width: 6),
                      Icon(Icons.workspace_premium_rounded, size: 15, color: Colors.amber.shade700),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  task.taskDescription,
                  style: const TextStyle(color: AppColors.mutedForeground, fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: SizedBox(
                    width: double.infinity,
                    height: 5,
                    child: LinearProgressIndicator(
                      value: task.progress,
                      backgroundColor: AppColors.muted,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        task.isCompleted ? AppColors.success : AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${task.currentCount}/${task.targetCount}  •  +${task.xpReward} XP  •  +${task.coinReward} koin',
                  style: const TextStyle(color: AppColors.mutedForeground, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 84,
            child: Align(
              alignment: Alignment.centerRight,
              child: _trailing(context, task, submitting),
            ),
          ),
        ],
      ),
    );
  }

  Widget _trailing(BuildContext context, DailyTask task, bool submitting) {
    if (task.isClaimed) {
      return const Icon(Icons.check_circle_rounded, color: AppColors.success);
    }
    if (task.isClaimable) {
      return ElevatedButton(
        onPressed: submitting
            ? null
            : () => context.read<GamificationBloc>().add(GamificationDailyTaskClaimed(task.id)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentOrange,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text('Klaim'),
      );
    }
    return const Icon(Icons.lock_outline_rounded, color: AppColors.mutedForeground);
  }

  void _snack(BuildContext context, String msg, Color color) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }
}
