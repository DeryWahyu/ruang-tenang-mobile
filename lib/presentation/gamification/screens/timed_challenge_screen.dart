import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/secondary_gamification.dart';
import '../cubit/secondary_cubits.dart';
import '../cubit/view_state.dart';

class TimedChallengeScreen extends StatelessWidget {
  const TimedChallengeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<TimedChallengeCubit>()..load(),
      child: const _TimedChallengeView(),
    );
  }
}

class _TimedChallengeView extends StatelessWidget {
  const _TimedChallengeView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Quest Kilat', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: AppColors.card,
        surfaceTintColor: Colors.transparent,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.05),
      ),
      body: BlocConsumer<TimedChallengeCubit, ViewState<TimedChallengeData>>(
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
                  const Icon(Icons.bolt_outlined, size: 48, color: AppColors.mutedForeground),
                  const SizedBox(height: 16),
                  Text(state.error.isEmpty ? 'Gagal memuat' : state.error,
                      style: const TextStyle(color: AppColors.mutedForeground)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                      onPressed: () => context.read<TimedChallengeCubit>().load(), child: const Text('Coba Lagi')),
                ],
              ),
            );
          }
          final data = state.data!;
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => context.read<TimedChallengeCubit>().load(),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (data.active != null)
                  _activeCard(context, data.active!, state)
                else
                  _noActiveBanner(),
                const SizedBox(height: 24),
                const Text('Pilih Quest Kilat',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                const SizedBox(height: 4),
                const Text('Selesaikan dalam batas waktu untuk hadiah XP & koin!',
                    style: TextStyle(color: AppColors.mutedForeground, fontSize: 12)),
                const SizedBox(height: 12),
                ...data.templates.map((t) => _templateCard(context, t, data.active != null, state)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _noActiveBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.accentOrangeSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accentOrangeBorder),
      ),
      child: const Row(
        children: [
          Icon(Icons.bolt_rounded, color: AppColors.accentOrange, size: 32),
          SizedBox(width: 14),
          Expanded(
            child: Text('Belum ada quest aktif. Mulai satu untuk memacu fokusmu!',
                style: TextStyle(color: AppColors.accentOrangeText, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _activeCard(BuildContext context, UserTimedChallenge ch, ViewState<TimedChallengeData> state) {
    final reached = ch.currentValue >= ch.targetValue;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.deepPurple.shade400, Colors.indigo.shade500]),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(ch.template.icon, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(ch.template.title,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  const Icon(Icons.timer_outlined, color: Colors.white, size: 14),
                  const SizedBox(width: 4),
                  Text(_fmtDuration(ch.remainingSeconds),
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ]),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (ch.progressPercent / 100).clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: Colors.white.withOpacity(0.3),
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text('${ch.currentValue}/${ch.targetValue} • +${ch.template.xpReward} XP • +${ch.template.coinReward} koin',
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
          if (reached) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: state.submitting ? null : () => context.read<TimedChallengeCubit>().complete(ch.id),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.deepPurple),
                child: const Text('Selesaikan & Klaim'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _templateCard(BuildContext context, TimedChallengeTemplate t, bool hasActive, ViewState<TimedChallengeData> state) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: AppColors.accentOrangeLight, borderRadius: BorderRadius.circular(14)),
            child: Center(child: Text(t.icon, style: const TextStyle(fontSize: 24))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 2),
                Text(t.description,
                    style: const TextStyle(color: AppColors.mutedForeground, fontSize: 12),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text('${t.durationMinutes} mnt • target ${t.targetValue} • +${t.xpReward} XP',
                    style: const TextStyle(color: AppColors.mutedForeground, fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: (hasActive || state.submitting)
                ? null
                : () => context.read<TimedChallengeCubit>().start(t.id),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.muted,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
            child: const Text('Mulai'),
          ),
        ],
      ),
    );
  }

  String _fmtDuration(int seconds) {
    if (seconds <= 0) return '00:00';
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) return '${h}j ${m}m';
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _snack(BuildContext context, String msg, Color color) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }
}
