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
  Future<StreakSocietyOverview> getStreakSocietyOverview() => _remote.getStreakSocietyOverview();

  @override
  Future<String> joinStreakSociety() => _remote.joinStreakSociety();

  @override
  Future<List<TimedChallengeTemplate>> getTimedChallengeTemplates() => _remote.getTimedChallengeTemplates();

  @override
  Future<UserTimedChallenge?> getActiveTimedChallenge() => _remote.getActiveTimedChallenge();

  @override
  Future<UserTimedChallenge> startTimedChallenge(int templateId) => _remote.startTimedChallenge(templateId);

  @override
  Future<UserTimedChallenge> completeTimedChallenge(String challengeId) =>
      _remote.completeTimedChallenge(challengeId);

  @override
  Future<XPBoost?> getActiveBoost() => _remote.getActiveBoost();

  @override
  Future<ComboStatus> getComboStatus() => _remote.getComboStatus();

  @override
  Future<double> getEffectiveMultiplier() => _remote.getEffectiveMultiplier();

  @override
  Future<List<FriendQuest>> getMyFriendQuests({String? status, int page = 1, int limit = 20}) =>
      _remote.getMyFriendQuests(status: status, page: page, limit: limit);

  @override
  Future<void> acceptFriendQuest(String questId) => _remote.acceptFriendQuest(questId);

  @override
  Future<void> declineFriendQuest(String questId) => _remote.declineFriendQuest(questId);

  @override
  Future<LeagueOverview?> getLeagueOverview() => _remote.getLeagueOverview();

  @override
  Future<List<LeagueDivision>> getLeagueDivisions() => _remote.getLeagueDivisions();
}
