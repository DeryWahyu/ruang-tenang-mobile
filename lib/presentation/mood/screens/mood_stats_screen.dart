import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/extensions.dart';
import '../../../domain/entities/mood.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MoodBloc>().add(const MoodHistoryRequested());
      context.read<MoodBloc>().add(const MoodStatsRequested(days: 90));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'Statistik Mood',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocBuilder<MoodBloc, MoodState>(
        builder: (context, state) {
          final moods = state.history?.moods ?? const <UserMood>[];
          if (state.isLoading && moods.isEmpty) {
            return const Center(child: AppLoadingIndicator());
          }
          if (state.status == MoodStatus.failure && moods.isEmpty) {
            return AppErrorWidget(
              message: state.errorMessage ?? 'Gagal memuat statistik',
              onRetry: () =>
                  context.read<MoodBloc>().add(const MoodHistoryRequested()),
            );
          }
          if (moods.isEmpty) {
            return _emptyState();
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            children: [
              _summaryCard(moods, state.stats),
              const SizedBox(height: 20),
              _distributionCard(state.stats),
              const SizedBox(height: 20),
              _MoodCalendar(moods: moods),
            ],
          );
        },
      ),
    );
  }

  // ===== Empty =====
  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.insights_rounded,
              size: 64,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Belum Ada Data',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Catatanmu akan muncul di sini setelah menyelesaikan check-in harian di Beranda.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.mutedForeground),
            ),
          ),
        ],
      ),
    );
  }

  // ===== Summary hero =====
  Widget _summaryCard(List<UserMood> moods, MoodStats? stats) {
    final total = moods.length;
    final now = DateTime.now();
    final thisMonth = moods
        .where(
          (m) => m.createdAt.year == now.year && m.createdAt.month == now.month,
        )
        .length;
    MoodType? top;
    if (stats != null && stats.total > 0) {
      top = stats.sortedEntries.first.key;
    } else if (moods.isNotEmpty) {
      top = moods.first.mood;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.75),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          if (top != null)
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(10),
              child: Image.asset(top.activeImagePath, fit: BoxFit.contain),
            ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  top != null ? 'Mood teratas: ${top.label}' : 'Statistik Mood',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _miniStat('$total', 'Total'),
                    const SizedBox(width: 20),
                    _miniStat('$thisMonth', 'Bulan ini'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }

  // ===== Distribution donut =====
  Widget _distributionCard(MoodStats? stats) {
    if (stats == null || stats.total == 0) return const SizedBox.shrink();
    final entries = stats.sortedEntries.where((e) => e.value > 0).toList();

    return _card(
      title: 'Distribusi Mood',
      child: Row(
        children: [
          SizedBox(
            width: 130,
            height: 130,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 38,
                    startDegreeOffset: -90,
                    sections: entries.map((e) {
                      return PieChartSectionData(
                        value: e.value.toDouble(),
                        color: e.key.color,
                        radius: 20,
                        showTitle: false,
                      );
                    }).toList(),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${stats.total}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.foreground,
                      ),
                    ),
                    const Text(
                      'catatan',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: entries.map((e) {
                final pct = (e.value / stats.total * 100).round();
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: e.key.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          e.key.label,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '$pct%',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.foreground,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

/// A month calendar that shows the mood asset on recorded days and opens the
/// matching history when a day is selected.
class _MoodCalendar extends StatefulWidget {
  final List<UserMood> moods;
  const _MoodCalendar({required this.moods});

  @override
  State<_MoodCalendar> createState() => _MoodCalendarState();
}

class _MoodCalendarState extends State<_MoodCalendar> {
  late DateTime _month;

  static const _monthNames = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];
  static const _weekdayLabels = [
    'Sen',
    'Sel',
    'Rab',
    'Kam',
    'Jum',
    'Sab',
    'Min',
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
  }

  Map<int, List<UserMood>> get _moodsByDay {
    final map = <int, List<UserMood>>{};
    for (final m in widget.moods) {
      if (m.createdAt.year == _month.year &&
          m.createdAt.month == _month.month) {
        map.putIfAbsent(m.createdAt.day, () => <UserMood>[]).add(m);
      }
    }
    for (final dayMoods in map.values) {
      dayMoods.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final moodsByDay = _moodsByDay;
    final firstWeekday = DateTime(
      _month.year,
      _month.month,
      1,
    ).weekday; // 1=Mon..7=Sun
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final leading = firstWeekday - 1; // blanks before day 1
    final now = DateTime.now();

    final cells = <Widget>[];
    for (var i = 0; i < leading; i++) {
      cells.add(const SizedBox.shrink());
    }
    for (var day = 1; day <= daysInMonth; day++) {
      final dayMoods = moodsByDay[day] ?? const <UserMood>[];
      final isToday =
          now.year == _month.year &&
          now.month == _month.month &&
          now.day == day;
      cells.add(_dayCell(day, dayMoods, isToday));
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Kalender Mood',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.foreground,
                  ),
                ),
              ),
              _navBtn(Icons.chevron_left_rounded, () {
                setState(
                  () => _month = DateTime(_month.year, _month.month - 1),
                );
              }),
              const SizedBox(width: 4),
              _navBtn(Icons.chevron_right_rounded, () {
                final next = DateTime(_month.year, _month.month + 1);
                if (!next.isAfter(DateTime(now.year, now.month))) {
                  setState(() => _month = next);
                }
              }),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${_monthNames[_month.month - 1]} ${_month.year}',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.mutedForeground,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: _weekdayLabels
                .map(
                  (d) => Expanded(
                    child: Center(
                      child: Text(
                        d,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.mutedForeground,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            children: cells,
          ),
          const SizedBox(height: 10),
          const Text(
            'Ketuk tanggal dengan emote untuk melihat riwayat mood.',
            style: TextStyle(fontSize: 11, color: AppColors.mutedForeground),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: MoodType.values.map((m) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    m.activeImagePath,
                    width: 18,
                    height: 18,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    m.label,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.mutedForeground,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _navBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.muted,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: AppColors.foreground),
      ),
    );
  }

  Widget _dayCell(int day, List<UserMood> dayMoods, bool isToday) {
    final latestMood = dayMoods.isEmpty ? null : dayMoods.first.mood;
    final hasMood = latestMood != null;
    final date = DateTime(_month.year, _month.month, day);

    return Semantics(
      button: hasMood,
      label: hasMood
          ? 'Tanggal ${date.day}, ${dayMoods.length} catatan mood. Mood terakhir ${latestMood.label}. Buka riwayat.'
          : 'Tanggal ${date.day}, belum ada catatan mood',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: hasMood ? () => _showDayHistory(date, dayMoods) : null,
          borderRadius: BorderRadius.circular(11),
          child: Container(
            decoration: BoxDecoration(
              color: latestMood == null
                  ? Colors.transparent
                  : latestMood.color.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(11),
              border: isToday
                  ? Border.all(
                      color: AppColors.primary.withValues(alpha: 0.7),
                      width: 1.2,
                    )
                  : null,
            ),
            alignment: Alignment.center,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$day',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: (hasMood || isToday)
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: isToday
                          ? AppColors.primary
                          : AppColors.mutedForeground,
                    ),
                  ),
                  const SizedBox(height: 1),
                  if (latestMood != null)
                    Image.asset(
                      latestMood.activeImagePath,
                      width: 21,
                      height: 21,
                      fit: BoxFit.contain,
                      excludeFromSemantics: true,
                    )
                  else
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: AppColors.border,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showDayHistory(DateTime date, List<UserMood> dayMoods) {
    final entries = [...dayMoods]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SafeArea(
        top: false,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.62,
          ),
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
          decoration: const BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                AppDateUtils.formatWithDay(date),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.foreground,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${entries.length} catatan mood',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.mutedForeground,
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: entries.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: entry.mood.color.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: entry.mood.color.withValues(alpha: 0.12),
                        ),
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            entry.mood.activeImagePath,
                            width: 42,
                            height: 42,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              entry.mood.label,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.foreground,
                              ),
                            ),
                          ),
                          Text(
                            AppDateUtils.formatTime(entry.createdAt),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
