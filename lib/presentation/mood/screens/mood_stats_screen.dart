import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/utils/extensions.dart';
import '../../../domain/entities/mood.dart';
import '../../common/widgets/app_empty_state.dart';
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
  int _selectedDays = 30;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MoodBloc>().add(MoodStatsRequested(days: _selectedDays));
    });
  }

  void _changeRange(int days) {
    setState(() => _selectedDays = days);
    context.read<MoodBloc>().add(MoodStatsRequested(days: days));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Statistik Mood'),
        centerTitle: false,
        backgroundColor: AppColors.card,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocBuilder<MoodBloc, MoodState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(AppDimensions.spacingBase),
            children: [
              _buildRangeSelector(),
              const SizedBox(height: AppDimensions.spacingBase),
              if (state.status == MoodStatus.statsLoading && state.stats == null)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppDimensions.spacing3xl),
                  child: Center(child: AppLoadingIndicator(size: 32)),
                )
              else if (state.stats == null || state.stats!.total == 0)
                AppEmptyState(
                  icon: Icons.bar_chart_rounded,
                  title: 'Belum ada data',
                  subtitle: 'Catat moodmu beberapa hari untuk melihat statistik.',
                  iconSize: 48,
                )
              else ...[
                _buildSummaryCard(state.stats!),
                const SizedBox(height: AppDimensions.spacingBase),
                _buildDistributionCard(state.stats!),
                const SizedBox(height: AppDimensions.spacingBase),
                _buildBreakdownCard(state.stats!),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildRangeSelector() {
    final ranges = [
      (7, '7 Hari'),
      (30, '30 Hari'),
      (90, '90 Hari'),
    ];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.muted,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      ),
      child: Row(
        children: ranges
            .map((r) {
              final isSelected = _selectedDays == r.$1;
              return Expanded(
                child: GestureDetector(
                  onTap: () => _changeRange(r.$1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.card : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      r.$2,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? AppColors.foreground : AppColors.mutedForeground,
                      ),
                    ),
                  ),
                ),
              );
            })
            .toList(),
      ),
    );
  }

  Widget _buildSummaryCard(MoodStats stats) {
    final entries = stats.sortedEntries;
    final dominant = entries.isNotEmpty ? entries.first : null;
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingBase),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            dominant?.key.color.withValues(alpha: 0.15) ?? AppColors.red50,
            AppColors.card,
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: (dominant?.key.color ?? AppColors.primary).withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                dominant?.key.emoji ?? '🙂',
                style: const TextStyle(fontSize: 30),
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.spacingBase),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mood Paling Sering',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  dominant != null ? dominant.key.label : '-',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.foreground,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${stats.total}',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.foreground,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              Text(
                'catatan',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.mutedForeground,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDistributionCard(MoodStats stats) {
    final entries = stats.sortedEntries;
    final maxCount = entries.isEmpty ? 1 : entries.first.value;
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingBase),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Distribusi Mood',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.foreground,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppDimensions.spacingBase),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (maxCount * 1.2).ceilToDouble(),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, gIdx, rod, rIdx) {
                      return BarTooltipItem(
                        '${rod.toY.toInt()}',
                        const TextStyle(
                          color: AppColors.foreground,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 || i >= entries.length) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            entries[i].key.emoji,
                            style: const TextStyle(fontSize: 16),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(entries.length, (i) {
                  final e = entries[i];
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: e.value.toDouble(),
                        color: e.key.color,
                        width: 26,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownCard(MoodStats stats) {
    final total = stats.total;
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingBase),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rincian',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.foreground,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          // Ensure all 6 moods show (even zero counts) for a complete picture.
          ...MoodType.values.map((mood) {
            final count = stats.countOf(mood);
            final percent = total > 0 ? (count / total) * 100 : 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.spacingSm),
              child: Row(
                children: [
                  Text(mood.emoji, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 70,
                    child: Text(
                      mood.label,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.foreground,
                          ),
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                      child: LinearProgressIndicator(
                        value: count == 0 ? 0 : percent / 100,
                        backgroundColor: AppColors.muted,
                        color: mood.color,
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 48,
                    child: Text(
                      count == 0 ? '-' : '$count',
                      textAlign: TextAlign.end,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.mutedForeground,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
