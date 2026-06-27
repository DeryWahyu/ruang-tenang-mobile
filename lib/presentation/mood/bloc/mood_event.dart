import 'package:equatable/equatable.dart';
import '../../../domain/entities/mood.dart';

abstract class MoodEvent extends Equatable {
  const MoodEvent();

  @override
  List<Object?> get props => [];
}

/// Load today's mood status (called on mood tracker screen open).
class MoodTodayRequested extends MoodEvent {
  const MoodTodayRequested();
}

/// Load the latest recorded mood.
class MoodLatestRequested extends MoodEvent {
  const MoodLatestRequested();
}

/// Record today's mood.
class MoodRecordRequested extends MoodEvent {
  final MoodType mood;

  const MoodRecordRequested(this.mood);

  @override
  List<Object?> get props => [mood];
}

/// Load mood history (for the tracker list).
class MoodHistoryRequested extends MoodEvent {
  final DateTime? startDate;
  final DateTime? endDate;

  const MoodHistoryRequested({this.startDate, this.endDate});

  @override
  List<Object?> get props => [startDate, endDate];
}

/// Load mood stats (for the stats screen chart).
class MoodStatsRequested extends MoodEvent {
  final int days;

  const MoodStatsRequested({this.days = 30});

  @override
  List<Object?> get props => [days];
}
