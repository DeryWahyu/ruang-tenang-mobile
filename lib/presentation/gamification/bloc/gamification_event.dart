import 'package:equatable/equatable.dart';

abstract class GamificationEvent extends Equatable {
  const GamificationEvent();
  @override
  List<Object?> get props => [];
}

class GamificationLevelRequested extends GamificationEvent {
  const GamificationLevelRequested();
}

class GamificationJourneyRequested extends GamificationEvent {
  const GamificationJourneyRequested();
}

class GamificationExpHistoryRequested extends GamificationEvent {
  final bool refresh;
  const GamificationExpHistoryRequested({this.refresh = false});
  @override
  List<Object?> get props => [refresh];
}

class GamificationExpHistoryLoadMore extends GamificationEvent {
  const GamificationExpHistoryLoadMore();
}

class GamificationBadgesRequested extends GamificationEvent {
  const GamificationBadgesRequested();
}

class GamificationChestsRequested extends GamificationEvent {
  const GamificationChestsRequested();
}

class GamificationChestOpened extends GamificationEvent {
  final String chestId;
  const GamificationChestOpened(this.chestId);
  @override
  List<Object?> get props => [chestId];
}

class GamificationSpinWheelRequested extends GamificationEvent {
  const GamificationSpinWheelRequested();
}

class GamificationSpinRequested extends GamificationEvent {
  const GamificationSpinRequested();
}

// ===== Daily Tasks =====
class GamificationDailyTasksRequested extends GamificationEvent {
  /// When true, processes the daily login (marks login task & updates streak)
  /// before loading the task list — mirrors the web login flow.
  final bool processLogin;
  const GamificationDailyTasksRequested({this.processLogin = false});
  @override
  List<Object?> get props => [processLogin];
}

class GamificationDailyTaskClaimed extends GamificationEvent {
  final int taskId;
  const GamificationDailyTaskClaimed(this.taskId);
  @override
  List<Object?> get props => [taskId];
}

class GamificationAllTasksClaimed extends GamificationEvent {
  const GamificationAllTasksClaimed();
}

// ===== Progress Map =====
class GamificationProgressMapRequested extends GamificationEvent {
  const GamificationProgressMapRequested();
}

class GamificationLandmarkClaimed extends GamificationEvent {
  final String landmarkId;
  const GamificationLandmarkClaimed(this.landmarkId);
  @override
  List<Object?> get props => [landmarkId];
}

// ===== Leaderboard / Hall of Fame =====
class GamificationLeaderboardRequested extends GamificationEvent {
  /// When [level] is null, fetches the monthly hall of fame.
  final int? level;
  const GamificationLeaderboardRequested({this.level});
  @override
  List<Object?> get props => [level];
}

// ===== Rewards Shop =====
class GamificationRewardsRequested extends GamificationEvent {
  const GamificationRewardsRequested();
}

class GamificationRewardClaimed extends GamificationEvent {
  final int rewardId;
  const GamificationRewardClaimed(this.rewardId);
  @override
  List<Object?> get props => [rewardId];
}
