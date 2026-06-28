import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/extensions.dart';
import '../../../domain/entities/mood.dart';
import '../../common/widgets/app_card.dart';
import '../../common/widgets/app_error_widget.dart';
import '../../common/widgets/app_loading.dart';
import '../bloc/mood_bloc.dart';
import '../bloc/mood_event.dart';
import '../bloc/mood_state.dart';

class MoodStatsScreen extends StatefulWidget {
  const MoodStatsScreen({super.key});

  @override
  State<MoodStatsScreen> createState() => _MoodStatsScreenState();
}

class _MoodStatsScreenState extends State<MoodStatsScreen> {
  @override
  void initState() {
    super.initState();
    // Load history & stats
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MoodBloc>().add(const MoodHistoryRequested());
      context.read<MoodBloc>().add(const MoodStatsRequested());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Statistik Mood', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocBuilder<MoodBloc, MoodState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: AppLoadingIndicator());
          }
          if (state.status == MoodStatus.failure && (state.history?.moods ?? []).isEmpty) {
            return AppErrorWidget(
              message: state.errorMessage ?? 'Gagal memuat statistik',
              onRetry: () => context.read<MoodBloc>().add(const MoodHistoryRequested()),
            );
          }

          if ((state.history?.moods ?? []).isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.analytics_rounded, size: 64, color: AppColors.primary),
                  ),
                  const SizedBox(height: 24),
                  const Text('Belum Ada Data', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Catat mood pertamamu untuk melihat statistik.', style: TextStyle(color: AppColors.mutedForeground)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.push('/mood'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Catat Mood Sekarang'),
                  ),
                ],
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ringkasan',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.foreground),
                      ),
                      const SizedBox(height: 16),
                      _buildStatsOverview(context, state.stats),
                      const SizedBox(height: 32),
                      const Text(
                        'Riwayat Perasaan',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.foreground),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final mood = (state.history?.moods ?? [])[index];
                      return _buildHistoryItem(context, mood);
                    },
                    childCount: (state.history?.moods ?? []).length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatsOverview(BuildContext context, MoodStats? stats) {
    if (stats == null || stats.total == 0) return const SizedBox.shrink();
    if (stats.total == 0) return const SizedBox.shrink();

    final sorted = stats.sortedEntries;
    final topMoodType = sorted.first.key;
    final topCount = sorted.first.value;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                topMoodType.activeImagePath,
                width: 48,
                height: 48,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Paling Sering: ${topMoodType.label}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$topCount kali dicatat',
                      style: const TextStyle(color: AppColors.mutedForeground, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Distribusi Mood', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 16),
          // Simple horizontal bar chart
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 12,
              child: Row(
                children: sorted.map((entry) {
                  final flex = (entry.value / stats.total * 100).toInt();
                  return Expanded(
                    flex: flex,
                    child: Container(
                      color: entry.key.color,
                      margin: const EdgeInsets.only(right: 2), // spacing
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Legend
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: sorted.take(4).map((entry) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: entry.key.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${entry.key.label} (${(entry.value / stats.total * 100).toInt()}%)',
                    style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, UserMood mood) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: mood.mood.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Image.asset(
              mood.mood.activeImagePath,
              width: 28,
              height: 28,
            ),
          ),
        ),
        title: Text(
          mood.mood.label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          AppDateUtils.formatRelative(mood.createdAt),
          style: const TextStyle(color: AppColors.mutedForeground, fontSize: 13),
        ),
        trailing: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: mood.mood.color,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
