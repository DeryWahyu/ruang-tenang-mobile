import 'package:equatable/equatable.dart';
import '../../../domain/entities/gamification.dart';

enum GamificationStatus { initial, loading, success, failure, submitting }

class GamificationState extends Equatable {
  final GamificationStatus status;
  final UserLevelInfo? levelInfo;
  final PersonalJourney? journey;
  final List<ExpHistory> expHistory;
  final int expHistoryPage;
  final int expHistoryTotalPages;
  final bool expHistoryLoadingMore;
  final List<BadgeProgress> badges;
  final DailyTaskSummary? dailyTasks;
  final ProgressMap? progressMap;
  final List<HallOfFameEntry> leaderboard;
  final List<Reward> rewards;
  final int coinBalance;
  final String errorMessage;
  final String successMessage;

  const GamificationState({
    this.status = GamificationStatus.initial,
    this.levelInfo,
    this.journey,
    this.expHistory = const [],
    this.expHistoryPage = 1,
    this.expHistoryTotalPages = 1,
    this.expHistoryLoadingMore = false,
    this.badges = const [],
    this.dailyTasks,
    this.progressMap,
    this.leaderboard = const [],
    this.rewards = const [],
    this.coinBalance = 0,
    this.errorMessage = '',
    this.successMessage = '',
  });

  const GamificationState.initial() : this();

  bool get expHistoryHasMore => expHistoryPage < expHistoryTotalPages;

  GamificationState copyWith({
    GamificationStatus? status,
    UserLevelInfo? levelInfo,
    PersonalJourney? journey,
    List<ExpHistory>? expHistory,
    int? expHistoryPage,
    int? expHistoryTotalPages,
    bool? expHistoryLoadingMore,
    List<BadgeProgress>? badges,
    DailyTaskSummary? dailyTasks,
    ProgressMap? progressMap,
    List<HallOfFameEntry>? leaderboard,
    List<Reward>? rewards,
    int? coinBalance,
    String? errorMessage,
    String? successMessage,
    bool clearMessages = false,
  }) {
    return GamificationState(
      status: status ?? this.status,
      levelInfo: levelInfo ?? this.levelInfo,
      journey: journey ?? this.journey,
      expHistory: expHistory ?? this.expHistory,
      expHistoryPage: expHistoryPage ?? this.expHistoryPage,
      expHistoryTotalPages: expHistoryTotalPages ?? this.expHistoryTotalPages,
      expHistoryLoadingMore: expHistoryLoadingMore ?? this.expHistoryLoadingMore,
      badges: badges ?? this.badges,
      dailyTasks: dailyTasks ?? this.dailyTasks,
      progressMap: progressMap ?? this.progressMap,
      leaderboard: leaderboard ?? this.leaderboard,
      rewards: rewards ?? this.rewards,
      coinBalance: coinBalance ?? this.coinBalance,
      errorMessage: clearMessages ? '' : (errorMessage ?? this.errorMessage),
      successMessage: clearMessages ? '' : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
        status, levelInfo, journey, expHistory, expHistoryPage, expHistoryTotalPages,
        expHistoryLoadingMore, badges, dailyTasks, progressMap,
        leaderboard, rewards, coinBalance,
        errorMessage, successMessage,
      ];
}
