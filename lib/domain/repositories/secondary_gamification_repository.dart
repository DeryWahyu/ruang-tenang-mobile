import '../entities/secondary_gamification.dart';

abstract class SecondaryGamificationRepository {
  // Guild
  Future<MyGuild> getMyGuild();
  Future<GuildDetail> getGuildDetail(String guildId);
  Future<List<GuildLeaderboardEntry>> getGuildLeaderboard({int limit});
  Future<List<Guild>> getPublicGuilds({int page, int limit});
  Future<Guild> createGuild({required String name, required String description, required String icon, required bool isPublic});
  Future<void> joinGuild(String guildId);
  Future<void> joinGuildByCode(String code);
  Future<void> leaveGuild(String guildId);

  // XP Boost / Combo
  Future<XPBoost?> getActiveBoost();
  Future<ComboStatus> getComboStatus();
  Future<double> getEffectiveMultiplier();
}
