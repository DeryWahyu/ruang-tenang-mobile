import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/error_message.dart';
import '../../../domain/repositories/breathing_repository.dart';
import 'breathing_event.dart';
import 'breathing_state.dart';

class BreathingBloc extends Bloc<BreathingEvent, BreathingState> {
  final BreathingRepository _repository;

  BreathingBloc({required BreathingRepository repository})
      : _repository = repository,
        super(const BreathingState.initial()) {
    on<BreathingTechniquesRequested>(_onTechniquesRequested);
    on<BreathingStatsRequested>(_onStatsRequested);
    on<BreathingSessionStarted>(_onSessionStarted);
    on<BreathingSessionCompleted>(_onSessionCompleted);
  }

  Future<void> _onTechniquesRequested(
    BreathingTechniquesRequested event,
    Emitter<BreathingState> emit,
  ) async {
    emit(state.copyWith(status: BreathingStatus.loading));
    try {
      final techniques = await _repository.getTechniques();
      emit(state.copyWith(status: BreathingStatus.success, techniques: techniques));
    } catch (e) {
      emit(state.copyWith(
        status: BreathingStatus.failure,
        errorMessage: ErrorMessage.from(e, 'Gagal memuat teknik pernapasan'),
      ));
    }
  }

  Future<void> _onStatsRequested(
    BreathingStatsRequested event,
    Emitter<BreathingState> emit,
  ) async {
    try {
      final stats = await _repository.getStats();
      emit(state.copyWith(stats: stats));
    } catch (_) {}
  }

  Future<void> _onSessionStarted(
    BreathingSessionStarted event,
    Emitter<BreathingState> emit,
  ) async {
    emit(state.copyWith(status: BreathingStatus.sessionStarting));
    try {
      final session = await _repository.startSession(
        techniqueId: event.technique.id,
        targetDurationSeconds: event.targetDurationSeconds,
        moodBefore: event.moodBefore,
        backgroundSound: event.backgroundSound,
        voiceGuidanceEnabled: event.voiceGuidanceEnabled,
        hapticFeedbackEnabled: event.hapticFeedbackEnabled,
      );
      emit(state.copyWith(status: BreathingStatus.sessionActive, activeSession: session));
    } catch (e) {
      emit(state.copyWith(
        status: BreathingStatus.failure,
        errorMessage: ErrorMessage.from(e, 'Gagal memulai sesi'),
      ));
    }
  }

  Future<void> _onSessionCompleted(
    BreathingSessionCompleted event,
    Emitter<BreathingState> emit,
  ) async {
    emit(state.copyWith(status: BreathingStatus.sessionCompleting));
    try {
      final result = await _repository.completeSession(
        sessionId: event.sessionId,
        durationSeconds: event.durationSeconds,
        cyclesCompleted: event.cyclesCompleted,
        completed: event.completed,
        completedPercentage: event.completedPercentage,
        moodAfter: event.moodAfter,
      );
      emit(state.copyWith(status: BreathingStatus.sessionCompleted, sessionResult: result, clearSession: true));
    } catch (e) {
      // Surface the failure so the UI can inform the user their session may
      // not have been saved, instead of silently pretending success.
      emit(state.copyWith(
        status: BreathingStatus.failure,
        errorMessage: ErrorMessage.from(e, 'Gagal menyimpan sesi'),
        clearSession: true,
      ));
    }
  }
}