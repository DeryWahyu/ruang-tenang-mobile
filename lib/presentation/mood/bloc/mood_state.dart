import 'package:equatable/equatable.dart';
import '../../../domain/entities/mood.dart';

enum MoodStatus {
  initial,
  loading,
  todayLoaded,
  recording,
  recorded,
  historyLoading,
  historyLoaded,
  statsLoading,
  statsLoaded,
  failure,
}

class MoodState extends Equatable {
  final MoodStatus status;
  final TodayMood? today;
  final UserMood? latest;
  final MoodHistory? history;
  final MoodStats? stats;
  final String? errorMessage;
  final String? successMessage;
  final bool fromCache;

  const MoodState({
    this.status = MoodStatus.initial,
    this.today,
    this.latest,
    this.history,
    this.stats,
    this.errorMessage,
    this.successMessage,
    this.fromCache = false,
  });

  const MoodState.initial() : this(status: MoodStatus.initial);

  bool get isLoading => status == MoodStatus.loading || status == MoodStatus.historyLoading || status == MoodStatus.statsLoading;
  bool get isRecording => status == MoodStatus.recording;

  MoodState copyWith({
    MoodStatus? status,
    TodayMood? today,
    UserMood? latest,
    MoodHistory? history,
    MoodStats? stats,
    String? errorMessage,
    String? successMessage,
    bool? fromCache,
  }) {
    return MoodState(
      status: status ?? this.status,
      today: today ?? this.today,
      latest: latest ?? this.latest,
      history: history ?? this.history,
      stats: stats ?? this.stats,
      errorMessage: errorMessage,
      successMessage: successMessage,
      fromCache: fromCache ?? this.fromCache,
    );
  }

  @override
  List<Object?> get props => [
        status,
        today,
        latest,
        history,
        stats,
        errorMessage,
        successMessage,
        fromCache,
      ];
}
