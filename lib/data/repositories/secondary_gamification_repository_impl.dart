import '../../domain/entities/secondary_gamification.dart';
import '../../domain/repositories/secondary_gamification_repository.dart';
import '../datasources/remote/secondary_gamification_remote_datasource.dart';

class SecondaryGamificationRepositoryImpl implements SecondaryGamificationRepository {
  final SecondaryGamificationRemoteDataSource _remote;

  SecondaryGamificationRepositoryImpl({required SecondaryGamificationRemoteDataSource remote}) : _remote = remote;

  @override
  Future<MyGuild> getMyGuild() => _remote.getMyGuild();

  @override
  Future<GuildDetail> getGuildDetail(String guildId) => _remote.getGuildDetail(guildId);

  @override
  Future<List<GuildLeaderboardEntry>> getGuildLeaderboard({int limit = 20}) =>
      _remote.getGuildLeaderboard(limit: limit);

  @override
  Future<List<Guild>> getPublicGuilds({int page = 1, int limit = 20}) =>
      _remote.getPublicGuilds(page: page, limit: limit);

  @override
  Future<Guild> createGuild({
    required String name,
    required String description,
    required String icon,
    required bool isPublic,
  }) =>
      _remote.createGuild(name: name, description: description, icon: icon, isPublic: isPublic);

  @override
  Future<void> joinGuild(String guildId) => _remote.joinGuild(guildId);

  @override
  Future<void> joinGuildByCode(String code) => _remote.joinGuildByCode(code);

  @override
  Future<void> leaveGuild(String guildId) => _remote.leaveGuild(guildId);

  @override
  Future<XPBoost?> getActiveBoost() => _remote.getActiveBoost();

  @override
  Future<ComboStatus> getComboStatus() => _remote.getComboStatus();

  @override
  Future<double> getEffectiveMultiplier() => _remote.getEffectiveMultiplier();
}
