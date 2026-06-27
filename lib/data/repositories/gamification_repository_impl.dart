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
  Future<List<ExpHistory>> getExpHistory({int page = 1, int limit = 10}) async {
    final result = await _remote.getExpHistory(page: page, limit: limit);
    final items = result['items'] as List<ExpHistoryModel>;
    return items.map((e) => e.toEntity()).toList();
  }

  @override
  Future<List<BadgeProgress>> getBadges() async {
    final models = await _remote.getBadges();
    return models.map((e) => e.toEntity()).toList();
  }

  @override
  Future<List<MysteryChest>> getChests() async {
    final models = await _remote.getChests();
    return models.map((e) => e.toEntity()).toList();
  }

  @override
  Future<Map<String, dynamic>> openChest(String chestId) async {
    return _remote.openChest(chestId);
  }

  @override
  Future<DailySpinWheel> getSpinWheel() async {
    final model = await _remote.getSpinWheel();
    return model.toEntity();
  }

  @override
  Future<Map<String, dynamic>> spinWheel() async {
    return _remote.spinWheel();
  }
}