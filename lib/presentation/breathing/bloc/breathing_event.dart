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
  final String moodBefore;
  final String backgroundSound;
  final bool voiceGuidanceEnabled;
  final bool hapticFeedbackEnabled;
  const BreathingSessionStarted({
    required this.technique,
    required this.targetDurationSeconds,
    this.moodBefore = '',
    this.backgroundSound = '',
    this.voiceGuidanceEnabled = false,
    this.hapticFeedbackEnabled = true,
  });
  @override
  List<Object?> get props => [
        technique,
        targetDurationSeconds,
        moodBefore,
        backgroundSound,
        voiceGuidanceEnabled,
        hapticFeedbackEnabled,
      ];
}

class BreathingSessionCompleted extends BreathingEvent {
  final String sessionId;
  final int durationSeconds;
  final int cyclesCompleted;
  final bool completed;
  final int completedPercentage;
  final String moodAfter;
  const BreathingSessionCompleted({
    required this.sessionId,
    required this.durationSeconds,
    required this.cyclesCompleted,
    required this.completed,
    required this.completedPercentage,
    this.moodAfter = '',
  });
  @override
  List<Object?> get props => [sessionId, durationSeconds, cyclesCompleted, completed, completedPercentage, moodAfter];
}