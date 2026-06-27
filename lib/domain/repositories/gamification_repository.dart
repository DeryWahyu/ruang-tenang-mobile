import '../entities/gamification.dart';

abstract class GamificationRepository {
  // Level & XP
  Future<UserLevelInfo> getUserLevelInfo();
  Future<List<ExpHistory>> getExpHistory({int page = 1, int limit = 10});
  
  // Badges
  Future<List<BadgeProgress>> getBadges();
  
  // Mystery Chests
  Future<List<MysteryChest>> getChests();
  Future<Map<String, dynamic>> openChest(String chestId);
  
  // Daily Spin
  Future<DailySpinWheel> getSpinWheel();
  Future<Map<String, dynamic>> spinWheel();
}