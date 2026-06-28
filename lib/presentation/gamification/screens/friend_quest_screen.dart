import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/secondary_gamification.dart';
import '../cubit/secondary_cubits.dart';
import '../cubit/view_state.dart';

class FriendQuestScreen extends StatelessWidget {
  const FriendQuestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<FriendQuestCubit>()..load(),
      child: const _FriendQuestView(),
    );
  }
}

class _FriendQuestView extends StatelessWidget {
  const _FriendQuestView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Friend Quest', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: AppColors.card,
        surfaceTintColor: Colors.transparent,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.05),
      ),
      body: BlocConsumer<FriendQuestCubit, ViewState<List<FriendQuest>>>(
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
                  const Icon(Icons.people_outline_rounded, size: 48, color: AppColors.mutedForeground),
                  const SizedBox(height: 16),
                  Text(state.error.isEmpty ? 'Gagal memuat' : state.error,
                      style: const TextStyle(color: AppColors.mutedForeground)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                      onPressed: () => context.read<FriendQuestCubit>().load(), child: const Text('Coba Lagi')),
                ],
              ),
            );
          }
          final quests = state.data!;
          if (quests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
                    child: const Icon(Icons.handshake_rounded, size: 56, color: AppColors.primary),
                  ),
                  const SizedBox(height: 20),
                  const Text('Belum Ada Friend Quest', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Text('Ajak teman untuk menyelesaikan misi bersama dan raih hadiah kolaboratif!',
                        textAlign: TextAlign.center, style: TextStyle(color: AppColors.mutedForeground)),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => context.read<FriendQuestCubit>().load(),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: quests.map((q) => _questCard(context, q, state)).toList(),
            ),
          );
        },
      ),
    );
  }

  Widget _questCard(BuildContext context, FriendQuest q, ViewState<List<FriendQuest>> state) {
    final isPending = q.status == 'pending';
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(q.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
              _statusChip(q.status),
            ],
          ),
          const SizedBox(height: 4),
          Text(q.description, style: const TextStyle(color: AppColors.mutedForeground, fontSize: 12)),
          const SizedBox(height: 12),
          Row(
            children: [
              _userChip(q.requester, 'Pengajak'),
              const SizedBox(width: 8),
              const Icon(Icons.handshake_rounded, color: AppColors.mutedForeground, size: 18),
              const SizedBox(width: 8),
              _userChip(q.partner, 'Partner'),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (q.progressPercent / 100).clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: AppColors.muted,
              color: q.status == 'completed' ? AppColors.success : AppColors.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text('${q.totalProgress}/${q.targetValue} • +${q.xpReward} XP • +${q.coinReward} koin',
              style: const TextStyle(color: AppColors.mutedForeground, fontSize: 11)),
          if (isPending) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: state.submitting ? null : () => context.read<FriendQuestCubit>().accept(q.id),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white),
                    child: const Text('Terima'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: state.submitting ? null : () => context.read<FriendQuestCubit>().decline(q.id),
                    style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.destructive,
                        side: const BorderSide(color: AppColors.destructive)),
                    child: const Text('Tolak'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _userChip(QuestUser u, String role) {
    return Expanded(
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: AppColors.secondary,
            backgroundImage: u.avatar.isNotEmpty ? NetworkImage(u.avatar) : null,
            child: u.avatar.isEmpty
                ? Text(u.username.isNotEmpty ? u.username[0].toUpperCase() : '?',
                    style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold))
                : null,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(u.username,
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                Text(role, style: const TextStyle(color: AppColors.mutedForeground, fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    final map = {
      'pending': (AppColors.warning, 'Menunggu'),
      'active': (AppColors.info, 'Aktif'),
      'completed': (AppColors.success, 'Selesai'),
      'expired': (AppColors.mutedForeground, 'Kedaluwarsa'),
      'declined': (AppColors.destructive, 'Ditolak'),
    };
    final entry = map[status] ?? (AppColors.mutedForeground, status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: entry.$1.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
      child: Text(entry.$2, style: TextStyle(color: entry.$1, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }

  void _snack(BuildContext context, String msg, Color color) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }
}
