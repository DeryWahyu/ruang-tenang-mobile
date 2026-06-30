import '../entities/gamification.dart';

abstract class GamificationRepository {
  // Level & XP
  Future<UserLevelInfo> getUserLevelInfo();
  Future<PersonalJourney> getPersonalJourney();
  Future<Map<String, dynamic>> getExpHistory({int page = 1, int limit = 10});

  // Badges
  Future<List<BadgeProgress>> getBadges();

  // Daily Tasks
  Future<DailyTaskSummary> getDailyTasks();
  Future<Map<String, dynamic>> claimDailyTask(int taskId);
  Future<Map<String, dynamic>> claimAllDailyTasks();
  Future<Map<String, dynamic>> claimDailyLogin();

  // Progress Map
  Future<ProgressMap> getProgressMap();
  Future<Map<String, dynamic>> claimLandmark(String landmarkId);

  // Hall of Fame / Leaderboard
  Future<List<HallOfFameEntry>> getMonthlyHallOfFame({required int month, required int year, String? category});
  Future<List<HallOfFameEntry>> getLevelHallOfFame(int level, {int limit = 10});

  // Rewards Shop
  Future<List<Reward>> getRewards();
  Future<int> getCoinBalance();
  Future<Map<String, dynamic>> claimReward(int rewardId);
}
