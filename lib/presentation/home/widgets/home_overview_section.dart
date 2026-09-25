import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/extensions.dart';
import '../../../domain/entities/mood.dart';
import '../../../domain/repositories/mood_repository.dart';

class HomeOverviewState {
  final bool loading;
  final List<UserMood> moods;

  const HomeOverviewState({this.loading = false, this.moods = const []});
}

class HomeOverviewCubit extends Cubit<HomeOverviewState> {
  final MoodRepository _moods;

  HomeOverviewCubit(this._moods) : super(const HomeOverviewState());

  Future<void> load() async {
    emit(const HomeOverviewState(loading: true));
    try {
      final history = await _moods.history(limit: 100);
      if (!isClosed) emit(HomeOverviewState(moods: history.moods));
    } catch (_) {
      if (!isClosed) emit(const HomeOverviewState());
    }
  }
}

class HomeOverviewSection extends StatelessWidget {
  const HomeOverviewSection({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => sl<HomeOverviewCubit>()..load(),
    child: BlocBuilder<HomeOverviewCubit, HomeOverviewState>(
      builder: (context, state) {
        if (state.loading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final now = DateTime.now();
        final monthStart = DateTime(now.year, now.month);
        final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
        final leadingDays = monthStart.weekday - 1;
        final cellCount = ((leadingDays + daysInMonth + 6) ~/ 7) * 7;
        final moodByDay = <int, UserMood>{};
        for (final mood in state.moods) {
          if (mood.createdAt.year == now.year &&
              mood.createdAt.month == now.month) {
            moodByDay.putIfAbsent(mood.createdAt.day, () => mood);
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ritme bulan ini',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.7),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.foreground.withValues(alpha: 0.025),
                    blurRadius: 12,
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
                          'Kalender mood',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        '${_monthNames[now.month - 1]} ${now.year}',
                        style: const TextStyle(
                          color: AppColors.mutedForeground,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: _weekdayLabels
                        .map(
                          (label) => Expanded(
                            child: Center(
                              child: Text(
                                label,
                                style: const TextStyle(
                                  color: AppColors.mutedForeground,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 7),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cellCount,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          mainAxisExtent: 46,
                          mainAxisSpacing: 3,
                          crossAxisSpacing: 2,
                        ),
                    itemBuilder: (context, index) {
                      final day = index - leadingDays + 1;
                      if (day < 1 || day > daysInMonth) {
                        return const SizedBox.shrink();
                      }

                      final isToday = day == now.day;
                      return _MoodCalendarDay(
                        day: day,
                        mood: moodByDay[day],
                        isToday: isToday,
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => context.push('/mood/stats'),
                    icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                    label: const Text('Lihat riwayat mood'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    ),
  );
}

const _monthNames = [
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

const _weekdayLabels = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

class _MoodCalendarDay extends StatelessWidget {
  final int day;
  final UserMood? mood;
  final bool isToday;

  const _MoodCalendarDay({
    required this.day,
    required this.mood,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    final dayMood = mood;
    return Semantics(
      label: dayMood == null
          ? 'Tanggal $day, belum ada catatan mood'
          : 'Tanggal $day, mood ${dayMood.mood.label}',
      selected: isToday,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 25,
            height: 18,
            alignment: Alignment.center,
            decoration: isToday
                ? BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(7),
                  )
                : null,
            child: Text(
              '$day',
              style: TextStyle(
                color: isToday ? Colors.white : AppColors.foreground,
                fontSize: 10,
                fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 2),
          if (dayMood != null)
            Container(
              width: 24,
              height: 24,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: dayMood.mood.color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                dayMood.mood.activeImagePath,
                fit: BoxFit.contain,
                excludeFromSemantics: true,
              ),
            )
          else
            SizedBox(
              width: 24,
              height: 24,
              child: Center(
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
