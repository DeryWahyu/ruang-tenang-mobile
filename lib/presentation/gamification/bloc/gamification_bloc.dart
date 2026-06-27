import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../domain/repositories/gamification_repository.dart';
import 'gamification_event.dart';
import 'gamification_state.dart';

class GamificationBloc extends Bloc<GamificationEvent, GamificationState> {
  final GamificationRepository _repository;

  GamificationBloc({required GamificationRepository repository})
      : _repository = repository,
        super(const GamificationState.initial()) {
    on<GamificationLevelRequested>(_onLevelRequested);
    on<GamificationExpHistoryRequested>(_onExpHistoryRequested);
    on<GamificationBadgesRequested>(_onBadgesRequested);
    on<GamificationChestsRequested>(_onChestsRequested);
    on<GamificationChestOpened>(_onChestOpened);
    on<GamificationSpinWheelRequested>(_onSpinWheelRequested);
    on<GamificationSpinRequested>(_onSpinRequested);
  }

  Future<void> _onLevelRequested(GamificationLevelRequested event, Emitter<GamificationState> emit) async {
    try {
      final info = await _repository.getUserLevelInfo();
      emit(state.copyWith(levelInfo: info));
    } catch (_) {}
  }

  Future<void> _onExpHistoryRequested(GamificationExpHistoryRequested event, Emitter<GamificationState> emit) async {
    emit(state.copyWith(status: GamificationStatus.loading));
    try {
      final history = await _repository.getExpHistory(page: 1, limit: 20);
      emit(state.copyWith(status: GamificationStatus.success, expHistory: history));
    } on ApiException catch (e) {
      emit(state.copyWith(status: GamificationStatus.failure, errorMessage: e.message));
    } catch (_) {
      emit(state.copyWith(status: GamificationStatus.failure, errorMessage: 'Gagal memuat riwayat EXP'));
    }
  }

  Future<void> _onBadgesRequested(GamificationBadgesRequested event, Emitter<GamificationState> emit) async {
    emit(state.copyWith(status: GamificationStatus.loading));
    try {
      final badges = await _repository.getBadges();
      emit(state.copyWith(status: GamificationStatus.success, badges: badges));
    } catch (_) {
      emit(state.copyWith(status: GamificationStatus.failure, errorMessage: 'Gagal memuat badge'));
    }
  }

  Future<void> _onChestsRequested(GamificationChestsRequested event, Emitter<GamificationState> emit) async {
    emit(state.copyWith(status: GamificationStatus.loading));
    try {
      final chests = await _repository.getChests();
      emit(state.copyWith(status: GamificationStatus.success, chests: chests));
    } catch (_) {
      emit(state.copyWith(status: GamificationStatus.failure, errorMessage: 'Gagal memuat peti misteri'));
    }
  }

  Future<void> _onChestOpened(GamificationChestOpened event, Emitter<GamificationState> emit) async {
    emit(state.copyWith(status: GamificationStatus.submitting, clearResults: true));
    try {
      final result = await _repository.openChest(event.chestId);
      final updatedChests = state.chests.where((c) => c.id != event.chestId).toList();
      emit(state.copyWith(status: GamificationStatus.success, openChestResult: result, chests: updatedChests));
    } on ApiException catch (e) {
      emit(state.copyWith(status: GamificationStatus.failure, errorMessage: e.message));
    } catch (_) {
      emit(state.copyWith(status: GamificationStatus.failure, errorMessage: 'Gagal membuka peti'));
    }
  }

  Future<void> _onSpinWheelRequested(GamificationSpinWheelRequested event, Emitter<GamificationState> emit) async {
    emit(state.copyWith(status: GamificationStatus.loading));
    try {
      final wheel = await _repository.getSpinWheel();
      emit(state.copyWith(status: GamificationStatus.success, spinWheel: wheel));
    } catch (_) {
      emit(state.copyWith(status: GamificationStatus.failure, errorMessage: 'Gagal memuat spin'));
    }
  }

  Future<void> _onSpinRequested(GamificationSpinRequested event, Emitter<GamificationState> emit) async {
    emit(state.copyWith(status: GamificationStatus.submitting, clearResults: true));
    try {
      final result = await _repository.spinWheel();
      emit(state.copyWith(status: GamificationStatus.success, spinResult: result));
    } on ApiException catch (e) {
      emit(state.copyWith(status: GamificationStatus.failure, errorMessage: e.message));
    } catch (_) {
      emit(state.copyWith(status: GamificationStatus.failure, errorMessage: 'Gagal memutar spin'));
    }
  }
}