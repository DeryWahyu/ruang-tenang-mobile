import 'package:equatable/equatable.dart';
import '../../../domain/entities/breathing.dart';

abstract class BreathingEvent extends Equatable {
  const BreathingEvent();
  @override
  List<Object?> get props => [];
}

class BreathingTechniquesRequested extends BreathingEvent {
  const BreathingTechniquesRequested();
}

class BreathingStatsRequested extends BreathingEvent {
  const BreathingStatsRequested();
}

class BreathingSessionStarted extends BreathingEvent {
  final BreathingTechnique technique;
  final int targetDurationSeconds;
  const BreathingSessionStarted({
    required this.technique,
    required this.targetDurationSeconds,
  });
  @override
  List<Object?> get props => [technique, targetDurationSeconds];
}

class BreathingSessionCompleted extends BreathingEvent {
  final String sessionId;
  final int durationSeconds;
  final int cyclesCompleted;
  final bool completed;
  final int completedPercentage;
  const BreathingSessionCompleted({
    required this.sessionId,
    required this.durationSeconds,
    required this.cyclesCompleted,
    required this.completed,
    required this.completedPercentage,
  });
  @override
  List<Object?> get props => [sessionId, durationSeconds, cyclesCompleted, completed, completedPercentage];
}