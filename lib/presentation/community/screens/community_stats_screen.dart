import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/community.dart';
import '../cubit/community_cubit.dart';
import '../../gamification/cubit/view_state.dart';

/// Layar **Statistik Komunitas** — paritas dengan halaman Komunitas di web.
///
/// Menampilkan pencapaian agregat komunitas pada periode berjalan
/// (total XP, anggota aktif, anggota baru, pencapaian, kisah & artikel).
class CommunityStatsScreen extends StatelessWidget {
  const CommunityStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CommunityCubit>()..load(),
      child: const _CommunityStatsView(),
    );
  }
}

class _CommunityStatsView extends StatelessWidget {
  const _CommunityStatsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Statistik Komunitas', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: AppColors.card,
        surfaceTintColor: Colors.transparent,
        elevation: 1,
      ),
      body: BlocBuilder<CommunityCubit, ViewState<CommunityStats>>(
        builder: (context, state) {
          if (state.data == null && state.status == ViewStatus.loading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (state.data == null) {
            return _Retry(message: state.error, onRetry: () => context.read<CommunityCubit>().load());
          }

          final stats = state.data!;
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => context.read<CommunityCubit>().load(),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _PeriodHeader(month: stats.month, year: stats.year),
                const SizedBox(height: 20),
                _StatsGrid(stats: stats),
                const SizedBox(height: 24),
                _ImpactSection(stats: stats),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Header periode (mis. "Juni 2026") + ringkasan pertumbuhan.
class _PeriodHeader extends StatelessWidget {
  final int month;
  final int year;
  const _PeriodHeader({required this.month, required this.year});

  @override
  Widget build(BuildContext context) {
    // month==0 berarti backend tidak mengirim periode; sembunyikan labelnya.
    final periodLabel = (month >= 1 && month <= 12)
        ? '${DateFormat.MMMM('id_ID').format(DateTime(year, month))} $year'
        : 'Periode berjalan';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFFEF4444)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.groups_rounded, color: Colors.white, size: 22),
              SizedBox(width: 8),
              Text('Pencapaian Komunitas',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          Text(periodLabel,
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ],
      ),
    );
  }
}

/// Grid kartu metrik utama.
class _StatsGrid extends StatelessWidget {
  final CommunityStats stats;
  const _StatsGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat.decimalPattern('id_ID');
    final cards = <_StatCardData>[
      _StatCardData(
        icon: Icons.bolt_rounded,
        color: AppColors.accentOrange,
        label: 'Total XP',
        value: numberFormat.format(stats.totalXpEarned),
      ),
      _StatCardData(
        icon: Icons.people_alt_rounded,
        color: AppColors.info,
        label: 'Anggota Aktif',
        value: numberFormat.format(stats.activeMembers),
      ),
      _StatCardData(
        icon: Icons.emoji_events_rounded,
        color: Colors.amber.shade700,
        label: 'Pencapaian',
        value: numberFormat.format(stats.totalAchievements),
      ),
      _StatCardData(
        icon: Icons.person_add_alt_1_rounded,
        color: AppColors.success,
        label: 'Anggota Baru',
        value: '+${numberFormat.format(stats.newMembers)}',
      ),
    ];

    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 240,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        mainAxisExtent: 140,
      ),
      children: cards.map((c) => _StatCard(data: c)).toList(),
    );
  }
}

class _StatCardData {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  const _StatCardData({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });
}

class _StatCard extends StatelessWidget {
  final _StatCardData data;
  const _StatCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(data.icon, color: data.color, size: 22),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(data.value,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(data.label,
                  style: const TextStyle(color: AppColors.mutedForeground, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

/// Bagian "Hall of Impact": pertumbuhan + kontribusi konten komunitas.
class _ImpactSection extends StatelessWidget {
  final CommunityStats stats;
  const _ImpactSection({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.local_fire_department_rounded, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text('Dampak Komunitas',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          _ImpactRow(
            label: 'Pertumbuhan komunitas',
            value: '${stats.growthPercentage >= 0 ? '+' : ''}${stats.growthPercentage.toStringAsFixed(1)}%',
            valueColor: stats.growthPercentage >= 0 ? AppColors.success : AppColors.destructive,
          ),
          const Divider(height: 24),
          _ImpactRow(
            label: 'Kisah dipublikasikan',
            value: '${stats.totalStoriesPublished}',
          ),
          const Divider(height: 24),
          _ImpactRow(
            label: 'Artikel dipublikasikan',
            value: '${stats.totalArticlesPublished}',
          ),
        ],
      ),
    );
  }
}

class _ImpactRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _ImpactRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.mutedForeground)),
        Text(value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: valueColor ?? AppColors.foreground,
            )),
      ],
    );
  }
}

/// Tampilan error + tombol coba lagi.
class _Retry extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _Retry({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.mutedForeground),
            const SizedBox(height: 16),
            Text(
              message.isNotEmpty ? message : 'Gagal memuat statistik komunitas',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.mutedForeground),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Coba Lagi')),
          ],
        ),
      ),
    );
  }
}
