import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/gamification.dart';
import '../../../domain/repositories/gamification_repository.dart';
import 'gamification_event.dart';
import 'gamification_state.dart';

class GamificationBloc extends Bloc<GamificationEvent, GamificationState> {
  final GamificationRepository _repository;

  GamificationBloc({required GamificationRepository repository})
      : _repository = repository,
        super(const GamificationState.initial()) {
    on<GamificationLevelRequested>(_onLevelRequested);
    on<GamificationJourneyRequested>(_onJourneyRequested);
    on<GamificationExpHistoryRequested>(_onExpHistoryRequested);
    on<GamificationExpHistoryLoadMore>(_onExpHistoryLoadMore);
    on<GamificationBadgesRequested>(_onBadgesRequested);
    on<GamificationChestsRequested>(_onChestsRequested);
    on<GamificationChestOpened>(_onChestOpened);
    on<GamificationSpinWheelRequested>(_onSpinWheelRequested);
    on<GamificationSpinRequested>(_onSpinRequested);
    on<GamificationDailyTasksRequested>(_onDailyTasksRequested);
    on<GamificationDailyTaskClaimed>(_onDailyTaskClaimed);
    on<GamificationAllTasksClaimed>(_onAllTasksClaimed);
    on<GamificationProgressMapRequested>(_onProgressMapRequested);
    on<GamificationLandmarkClaimed>(_onLandmarkClaimed);
    on<GamificationLeaderboardRequested>(_onLeaderboardRequested);
    on<GamificationRewardsRequested>(_onRewardsRequested);
    on<GamificationRewardClaimed>(_onRewardClaimed);
  }

  Future<void> _onLevelRequested(GamificationLevelRequested event, Emitter<GamificationState> emit) async {
    try {
      final info = await _repository.getUserLevelInfo();
      emit(state.copyWith(levelInfo: info));
    } catch (_) {}
  }

  Future<void> _onJourneyRequested(GamificationJourneyRequested event, Emitter<GamificationState> emit) async {
    try {
      final journey = await _repository.getPersonalJourney();
      emit(state.copyWith(journey: journey, status: GamificationStatus.success));
    } catch (_) {
      // Journey is supplementary; keep existing level info if any.
    }
  }

  Future<void> _onExpHistoryRequested(GamificationExpHistoryRequested event, Emitter<GamificationState> emit) async {
    try {
      final result = await _repository.getExpHistory(page: 1, limit: 20);
      emit(state.copyWith(
        status: GamificationStatus.success,
        expHistory: List<ExpHistory>.from(result['items'] as List),
        expHistoryPage: result['page'] as int? ?? 1,
        expHistoryTotalPages: result['total_pages'] as int? ?? 1,
      ));
    } catch (_) {
      emit(state.copyWith(status: GamificationStatus.success, expHistory: const []));
    }
  }

  Future<void> _onExpHistoryLoadMore(GamificationExpHistoryLoadMore event, Emitter<GamificationState> emit) async {
    if (!state.expHistoryHasMore || state.expHistoryLoadingMore) return;
    emit(state.copyWith(expHistoryLoadingMore: true));
    try {
      final nextPage = state.expHistoryPage + 1;
      final result = await _repository.getExpHistory(page: nextPage, limit: 20);
      emit(state.copyWith(
        expHistory: [...state.expHistory, ...List<ExpHistory>.from(result['items'] as List)],
        expHistoryPage: result['page'] as int? ?? nextPage,
        expHistoryTotalPages: result['total_pages'] as int? ?? state.expHistoryTotalPages,
        expHistoryLoadingMore: false,
      ));
    } catch (_) {
      emit(state.copyWith(expHistoryLoadingMore: false));
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
    } catch (_) {
      emit(state.copyWith(status: GamificationStatus.failure, errorMessage: 'Gagal memutar spin'));
    }
  }

  // ===== Daily Tasks =====
  Future<void> _onDailyTasksRequested(GamificationDailyTasksRequested event, Emitter<GamificationState> emit) async {
    emit(state.copyWith(status: GamificationStatus.loading));
    try {
      if (event.processLogin) {
        // Mark today's login (updates streak & login task). Ignore failures.
        try {
          await _repository.claimDailyLogin();
        } catch (_) {}
      }
      final summary = await _repository.getDailyTasks();
      emit(state.copyWith(status: GamificationStatus.success, dailyTasks: summary));
    } catch (_) {
      emit(state.copyWith(status: GamificationStatus.failure, errorMessage: 'Gagal memuat tugas harian'));
    }
  }

  Future<void> _onDailyTaskClaimed(GamificationDailyTaskClaimed event, Emitter<GamificationState> emit) async {
    emit(state.copyWith(status: GamificationStatus.submitting, clearMessages: true));
    try {
      final result = await _repository.claimDailyTask(event.taskId);
      final summary = await _repository.getDailyTasks();
      emit(state.copyWith(
        status: GamificationStatus.success,
        dailyTasks: summary,
        successMessage: (result['message'] as String?) ?? 'Reward berhasil diklaim',
      ));
    } catch (e) {
      emit(state.copyWith(status: GamificationStatus.failure, errorMessage: _msg(e, 'Gagal mengklaim reward')));
    }
  }

  Future<void> _onAllTasksClaimed(GamificationAllTasksClaimed event, Emitter<GamificationState> emit) async {
    emit(state.copyWith(status: GamificationStatus.submitting, clearMessages: true));
    try {
      final result = await _repository.claimAllDailyTasks();
      final summary = await _repository.getDailyTasks();
      emit(state.copyWith(
        status: GamificationStatus.success,
        dailyTasks: summary,
        successMessage: (result['message'] as String?) ?? 'Semua reward berhasil diklaim',
      ));
    } catch (e) {
      emit(state.copyWith(status: GamificationStatus.failure, errorMessage: _msg(e, 'Gagal mengklaim reward')));
    }
  }

  // ===== Progress Map =====
  Future<void> _onProgressMapRequested(GamificationProgressMapRequested event, Emitter<GamificationState> emit) async {
    emit(state.copyWith(status: GamificationStatus.loading));
    try {
      final map = await _repository.getProgressMap();
      emit(state.copyWith(status: GamificationStatus.success, progressMap: map));
    } catch (_) {
      emit(state.copyWith(status: GamificationStatus.failure, errorMessage: 'Gagal memuat peta progress'));
    }
  }

  Future<void> _onLandmarkClaimed(GamificationLandmarkClaimed event, Emitter<GamificationState> emit) async {
    emit(state.copyWith(status: GamificationStatus.submitting, clearMessages: true));
    try {
      final result = await _repository.claimLandmark(event.landmarkId);
      final map = await _repository.getProgressMap();
      emit(state.copyWith(
        status: GamificationStatus.success,
        progressMap: map,
        successMessage: (result['message'] as String?) ?? 'Hadiah berhasil diklaim',
      ));
    } catch (e) {
      emit(state.copyWith(status: GamificationStatus.failure, errorMessage: _msg(e, 'Gagal mengklaim hadiah')));
    }
  }

  // ===== Leaderboard =====
  Future<void> _onLeaderboardRequested(GamificationLeaderboardRequested event, Emitter<GamificationState> emit) async {
    emit(state.copyWith(status: GamificationStatus.loading));
    try {
      final List<HallOfFameEntry> entries;
      if (event.level != null) {
        entries = await _repository.getLevelHallOfFame(event.level!, limit: 50);
      } else {
        final now = DateTime.now();
        entries = await _repository.getMonthlyHallOfFame(month: now.month, year: now.year);
      }
      emit(state.copyWith(status: GamificationStatus.success, leaderboard: entries));
    } catch (_) {
      emit(state.copyWith(status: GamificationStatus.failure, errorMessage: 'Gagal memuat papan peringkat'));
    }
  }

  // ===== Rewards =====
  Future<void> _onRewardsRequested(GamificationRewardsRequested event, Emitter<GamificationState> emit) async {
    emit(state.copyWith(status: GamificationStatus.loading));
    try {
      final rewards = await _repository.getRewards();
      int balance = 0;
      try {
        balance = await _repository.getCoinBalance();
      } catch (_) {}
      emit(state.copyWith(status: GamificationStatus.success, rewards: rewards, coinBalance: balance));
    } catch (_) {
      emit(state.copyWith(status: GamificationStatus.failure, errorMessage: 'Gagal memuat daftar hadiah'));
    }
  }

  Future<void> _onRewardClaimed(GamificationRewardClaimed event, Emitter<GamificationState> emit) async {
    emit(state.copyWith(status: GamificationStatus.submitting, clearMessages: true));
    try {
      final result = await _repository.claimReward(event.rewardId);
      final rewards = await _repository.getRewards();
      int balance = state.coinBalance;
      final remaining = result['remaining_coins'];
      if (remaining is num) {
        balance = remaining.toInt();
      } else {
        try {
          balance = await _repository.getCoinBalance();
        } catch (_) {}
      }
      emit(state.copyWith(
        status: GamificationStatus.success,
        rewards: rewards,
        coinBalance: balance,
        successMessage: (result['message'] as String?) ?? 'Hadiah berhasil diklaim',
      ));
    } catch (e) {
      emit(state.copyWith(status: GamificationStatus.failure, errorMessage: _msg(e, 'Gagal mengklaim hadiah')));
    }
  }

  String _msg(Object e, String fallback) {
    final s = e.toString().replaceFirst('Exception: ', '');
    return s.isEmpty ? fallback : s;
  }
}
