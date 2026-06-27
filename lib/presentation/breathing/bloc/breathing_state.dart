import 'package:equatable/equatable.dart';
import '../../../domain/entities/breathing.dart';

enum BreathingStatus { initial, loading, success, failure, sessionStarting, sessionActive, sessionCompleting, sessionCompleted }

class BreathingState extends Equatable {
  final BreathingStatus status;
  final List<BreathingTechnique> techniques;
  final BreathingStats? stats;
  final BreathingSession? activeSession;
  final Map<String, dynamic>? sessionResult;
  final String errorMessage;

  const BreathingState({
    this.status = BreathingStatus.initial,
    this.techniques = const [],
    this.stats,
    this.activeSession,
    this.sessionResult,
    this.errorMessage = '',
  });

  const BreathingState.initial() : this();

  BreathingState copyWith({
    BreathingStatus? status,
    List<BreathingTechnique>? techniques,
    BreathingStats? stats,
    BreathingSession? activeSession,
    Map<String, dynamic>? sessionResult,
    String? errorMessage,
    bool clearSession = false,
  }) {
    return BreathingState(
      status: status ?? this.status,
      techniques: techniques ?? this.techniques,
      stats: stats ?? this.stats,
      activeSession: clearSession ? null : (activeSession ?? this.activeSession),
      sessionResult: sessionResult ?? this.sessionResult,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, techniques, stats, activeSession, sessionResult, errorMessage];
}