import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/error_message.dart';
import '../../../domain/entities/mood.dart';
import '../../../domain/usecases/mood/mood_usecases.dart';
import 'mood_event.dart';
import 'mood_state.dart';

class MoodBloc extends Bloc<MoodEvent, MoodState> {
  final MoodUseCases _useCases;

  MoodBloc({required MoodUseCases moodUseCases})
      : _useCases = moodUseCases,
        super(const MoodState.initial()) {
    on<MoodTodayRequested>(_onTodayRequested);
    on<MoodLatestRequested>(_onLatestRequested);
    on<MoodRecordRequested>(_onRecord);
    on<MoodHistoryRequested>(_onHistory);
    on<MoodStatsRequested>(_onStats);
  }

  Future<void> _onTodayRequested(
    MoodTodayRequested event,
    Emitter<MoodState> emit,
  ) async {
    emit(state.copyWith(status: MoodStatus.loading, errorMessage: null));
    try {
      final today = await _useCases.getToday();
      emit(state.copyWith(status: MoodStatus.todayLoaded, today: today));
    } catch (e) {
      emit(state.copyWith(
        status: MoodStatus.failure,
        errorMessage: ErrorMessage.from(e, 'Gagal memeriksa mood hari ini.'),
      ));
    }
  }

  Future<void> _onLatestRequested(
    MoodLatestRequested event,
    Emitter<MoodState> emit,
  ) async {
    try {
      final latest = await _useCases.getLatest();
      emit(state.copyWith(latest: latest));
    } catch (_) {
      // Non-fatal — latest is optional.
    }
  }

  Future<void> _onRecord(
    MoodRecordRequested event,
    Emitter<MoodState> emit,
  ) async {
    emit(state.copyWith(status: MoodStatus.recording, errorMessage: null));
    try {
      final recorded = await _useCases.record(event.mood);
      emit(state.copyWith(
        status: MoodStatus.recorded,
        today: TodayMood(hasChecked: true, mood: recorded),
        latest: recorded,
        successMessage: 'Mood ${event.mood.label.toLowerCase()} tersimpan!',
      ));
      // Refresh history & stats after recording.
      try {
        final history = await _useCases.getHistory();
        final stats = await _useCases.getStats();
        emit(state.copyWith(history: history, stats: stats));
      } catch (_) {
        // Background refresh is best-effort.
      }
    } catch (e) {
      emit(state.copyWith(
        status: MoodStatus.failure,
        errorMessage: ErrorMessage.from(e, 'Gagal menyimpan mood. Silakan coba lagi.'),
      ));
    }
  }

  Future<void> _onHistory(
    MoodHistoryRequested event,
    Emitter<MoodState> emit,
  ) async {
    emit(state.copyWith(status: MoodStatus.historyLoading, errorMessage: null));
    try {
      final history = await _useCases.getHistory(
        startDate: event.startDate,
        endDate: event.endDate,
      );
      emit(state.copyWith(status: MoodStatus.historyLoaded, history: history));
    } catch (e) {
      emit(state.copyWith(
        status: MoodStatus.failure,
        errorMessage: ErrorMessage.from(e, 'Gagal memuat riwayat mood.'),
      ));
    }
  }

  Future<void> _onStats(
    MoodStatsRequested event,
    Emitter<MoodState> emit,
  ) async {
    emit(state.copyWith(status: MoodStatus.statsLoading, errorMessage: null));
    try {
      final stats = await _useCases.getStats(days: event.days);
      emit(state.copyWith(status: MoodStatus.statsLoaded, stats: stats));
    } catch (e) {
      emit(state.copyWith(
        status: MoodStatus.failure,
        errorMessage: ErrorMessage.from(e, 'Gagal memuat statistik mood.'),
      ));
    }
  }
}
