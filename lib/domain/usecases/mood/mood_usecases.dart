import 'get_latest_mood_use_case.dart';
import 'get_mood_history_use_case.dart';
import 'get_mood_stats_use_case.dart';
import 'get_today_mood_use_case.dart';
import 'record_mood_use_case.dart';

/// Aggregate of all mood use cases, injected into [MoodBloc].
class MoodUseCases {
  final RecordMoodUseCase record;
  final GetTodayMoodUseCase getToday;
  final GetLatestMoodUseCase getLatest;
  final GetMoodHistoryUseCase getHistory;
  final GetMoodStatsUseCase getStats;

  const MoodUseCases({
    required this.record,
    required this.getToday,
    required this.getLatest,
    required this.getHistory,
    required this.getStats,
  });
}
