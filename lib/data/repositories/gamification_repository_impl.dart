import '../../domain/entities/gamification.dart';
import '../../domain/repositories/gamification_repository.dart';
import '../datasources/remote/gamification_remote_datasource.dart';
import '../models/gamification_model.dart';

class GamificationRepositoryImpl implements GamificationRepository {
  final GamificationRemoteDataSource _remote;

  GamificationRepositoryImpl({required GamificationRemoteDataSource remote}) : _remote = remote;

  @override
  Future<UserLevelInfo> getUserLevelInfo() async {
    final model = await _remote.getUserLevelInfo();
    return model.toEntity();
  }

  @override
  Future<PersonalJourney> getPersonalJourney() => _remote.getPersonalJourney();

  @override
  Future<Map<String, dynamic>> getExpHistory({int page = 1, int limit = 10}) async {
    final result = await _remote.getExpHistory(page: page, limit: limit);
    final items = (result['items'] as List<ExpHistoryModel>).map((e) => e.toEntity()).toList();
    return {
      'items': items,
      'total': result['total'],
      'page': result['page'],
      'limit': result['limit'],
      'total_pages': result['total_pages'],
    };
  }

  @override
  Future<List<BadgeProgress>> getBadges() async {
    final models = await _remote.getBadges();
    return models.map((e) => e.toEntity()).toList();
  }

  @override
  Future<DailyTaskSummary> getDailyTasks() => _remote.getDailyTasks();

  @override
  Future<Map<String, dynamic>> claimDailyTask(int taskId) => _remote.claimDailyTask(taskId);

  @override
  Future<Map<String, dynamic>> claimAllDailyTasks() => _remote.claimAllDailyTasks();

  @override
  Future<Map<String, dynamic>> claimDailyLogin() => _remote.claimDailyLogin();

  @override
  Future<ProgressMap> getProgressMap() => _remote.getProgressMap();

  @override
  Future<Map<String, dynamic>> claimLandmark(String landmarkId) => _remote.claimLandmark(landmarkId);

  @override
  Future<List<HallOfFameEntry>> getMonthlyHallOfFame({required int month, required int year, String? category}) =>
      _remote.getMonthlyHallOfFame(month: month, year: year, category: category);

  @override
  Future<List<HallOfFameEntry>> getLevelHallOfFame(int level, {int limit = 10}) =>
      _remote.getLevelHallOfFame(level, limit: limit);

  @override
  Future<List<Reward>> getRewards() => _remote.getRewards();

  @override
  Future<int> getCoinBalance() => _remote.getCoinBalance();

  @override
  Future<Map<String, dynamic>> claimReward(int rewardId) => _remote.claimReward(rewardId);
}
