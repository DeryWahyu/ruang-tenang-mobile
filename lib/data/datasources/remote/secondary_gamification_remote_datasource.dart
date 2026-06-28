import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../domain/entities/secondary_gamification.dart';
import '../../models/secondary_gamification_model.dart';

class SecondaryGamificationRemoteDataSource {
  final ApiClient _apiClient;

  SecondaryGamificationRemoteDataSource(this._apiClient);

  // ==========================================
  // Guild
  // ==========================================
  Future<MyGuild> getMyGuild() async {
    final res = await _apiClient.get<Map<String, dynamic>>(
      '${ApiConstants.guilds}/my-guild',
      fromJson: (j) => Map<String, dynamic>.from(j as Map),
    );
    if (!res.success || res.data == null) {
      throw Exception(res.error ?? 'Gagal memuat info guild');
    }
    return MyGuildModel.fromJson(res.data!);
  }

  Future<GuildDetail> getGuildDetail(String guildId) async {
    final res = await _apiClient.get<Map<String, dynamic>>(
      '${ApiConstants.guilds}/$guildId',
      fromJson: (j) => Map<String, dynamic>.from(j as Map),
    );
    if (!res.success || res.data == null) {
      throw Exception(res.error ?? 'Gagal memuat detail guild');
    }
    return GuildDetailModel.fromJson(res.data!);
  }

  Future<List<GuildLeaderboardEntry>> getGuildLeaderboard({int limit = 20}) async {
    final res = await _apiClient.get<List<dynamic>>(
      '${ApiConstants.guilds}/leaderboard',
      queryParameters: {'limit': limit},
      fromJson: (j) => (j as List<dynamic>?) ?? <dynamic>[],
    );
    if (!res.success || res.data == null) {
      throw Exception(res.error ?? 'Gagal memuat leaderboard guild');
    }
    return res.data!
        .map((e) => GuildLeaderboardEntryModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<List<Guild>> getPublicGuilds({int page = 1, int limit = 20}) async {
    final res = await _apiClient.getPaginated<Guild>(
      ApiConstants.guilds,
      queryParameters: {'page': page, 'limit': limit},
      fromJson: (j) => GuildModel.fromJson(j),
    );
    return res.data;
  }

  Future<Guild> createGuild({
    required String name,
    required String description,
    required String icon,
    required bool isPublic,
  }) async {
    final res = await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.guilds,
      data: {'name': name, 'description': description, 'icon': icon, 'is_public': isPublic},
      fromJson: (j) => Map<String, dynamic>.from(j as Map),
    );
    if (!res.success || res.data == null) {
      throw Exception(res.error ?? res.message ?? 'Gagal membuat guild');
    }
    return GuildModel.fromJson(res.data!);
  }

  Future<void> joinGuild(String guildId) async {
    final res = await _apiClient.post<dynamic>('${ApiConstants.guilds}/$guildId/join');
    if (!res.success) {
      throw Exception(res.error ?? res.message ?? 'Gagal bergabung ke guild');
    }
  }

  Future<void> joinGuildByCode(String code) async {
    final res = await _apiClient.post<dynamic>('${ApiConstants.guilds}/join/$code');
    if (!res.success) {
      throw Exception(res.error ?? res.message ?? 'Kode undangan tidak valid');
    }
  }

  Future<void> leaveGuild(String guildId) async {
    final res = await _apiClient.post<dynamic>('${ApiConstants.guilds}/$guildId/leave');
    if (!res.success) {
      throw Exception(res.error ?? res.message ?? 'Gagal meninggalkan guild');
    }
  }

  // ==========================================
  // Streak Society
  // ==========================================
  Future<StreakSocietyOverview> getStreakSocietyOverview() async {
    final res = await _apiClient.get<Map<String, dynamic>>(
      '${ApiConstants.streakSociety}/overview',
      fromJson: (j) => Map<String, dynamic>.from(j as Map),
    );
    if (!res.success || res.data == null) {
      throw Exception(res.error ?? 'Gagal memuat streak society');
    }
    return StreakSocietyOverviewModel.fromJson(res.data!);
  }

  Future<String> joinStreakSociety() async {
    final res = await _apiClient.post<Map<String, dynamic>>(
      '${ApiConstants.streakSociety}/join',
      fromJson: (j) => Map<String, dynamic>.from(j as Map),
    );
    if (!res.success) {
      throw Exception(res.error ?? res.message ?? 'Gagal bergabung ke streak society');
    }
    return res.message ?? 'Berhasil bergabung ke streak society!';
  }

  // ==========================================
  // Timed Challenge (Quest Kilat)
  // ==========================================
  Future<List<TimedChallengeTemplate>> getTimedChallengeTemplates() async {
    final res = await _apiClient.get<List<dynamic>>(
      '${ApiConstants.challenges}/templates',
      fromJson: (j) => (j as List<dynamic>?) ?? <dynamic>[],
    );
    if (!res.success || res.data == null) {
      throw Exception(res.error ?? 'Gagal memuat template challenge');
    }
    return res.data!
        .map((e) => TimedChallengeTemplateModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// Returns null when the user has no active challenge (backend returns 404).
  Future<UserTimedChallenge?> getActiveTimedChallenge() async {
    try {
      final res = await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.challenges}/active',
        fromJson: (j) => Map<String, dynamic>.from(j as Map),
      );
      if (!res.success || res.data == null) return null;
      return UserTimedChallengeModel.fromJson(res.data!);
    } on NotFoundException {
      return null;
    }
  }

  Future<UserTimedChallenge> startTimedChallenge(int templateId) async {
    final res = await _apiClient.post<Map<String, dynamic>>(
      '${ApiConstants.challenges}/start',
      data: {'template_id': templateId},
      fromJson: (j) => Map<String, dynamic>.from(j as Map),
    );
    if (!res.success || res.data == null) {
      throw Exception(res.error ?? res.message ?? 'Gagal memulai challenge');
    }
    return UserTimedChallengeModel.fromJson(res.data!);
  }

  Future<UserTimedChallenge> completeTimedChallenge(String challengeId) async {
    final res = await _apiClient.post<Map<String, dynamic>>(
      '${ApiConstants.challenges}/$challengeId/complete',
      fromJson: (j) => Map<String, dynamic>.from(j as Map),
    );
    if (!res.success || res.data == null) {
      throw Exception(res.error ?? res.message ?? 'Gagal menyelesaikan challenge');
    }
    return UserTimedChallengeModel.fromJson(res.data!);
  }

  // ==========================================
  // XP Boost / Combo
  // ==========================================
  /// Returns null when no boost is active (backend returns 404).
  Future<XPBoost?> getActiveBoost() async {
    try {
      final res = await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.xpBoost}/active',
        fromJson: (j) => Map<String, dynamic>.from(j as Map),
      );
      if (!res.success || res.data == null) return null;
      return XPBoostModel.fromJson(res.data!);
    } on NotFoundException {
      return null;
    }
  }

  Future<ComboStatus> getComboStatus() async {
    final res = await _apiClient.get<Map<String, dynamic>>(
      '${ApiConstants.combo}/status',
      fromJson: (j) => Map<String, dynamic>.from(j as Map),
    );
    if (!res.success || res.data == null) {
      throw Exception(res.error ?? 'Gagal memuat status combo');
    }
    return ComboStatusModel.fromJson(res.data!);
  }

  Future<double> getEffectiveMultiplier() async {
    final res = await _apiClient.get<Map<String, dynamic>>(
      '${ApiConstants.xpBoost}/multiplier',
      fromJson: (j) => Map<String, dynamic>.from(j as Map),
    );
    if (!res.success || res.data == null) return 1.0;
    return (res.data!['effective_multiplier'] as num?)?.toDouble() ?? 1.0;
  }

  // ==========================================
  // Friend Quest
  // ==========================================
  Future<List<FriendQuest>> getMyFriendQuests({String? status, int page = 1, int limit = 20}) async {
    final res = await _apiClient.getPaginated<FriendQuest>(
      ApiConstants.friendQuests,
      queryParameters: {
        'page': page,
        'limit': limit,
        if (status != null && status.isNotEmpty) 'status': status,
      },
      fromJson: (j) => FriendQuestModel.fromJson(j),
    );
    return res.data;
  }

  Future<void> acceptFriendQuest(String questId) async {
    final res = await _apiClient.post<dynamic>('${ApiConstants.friendQuests}/$questId/accept');
    if (!res.success) {
      throw Exception(res.error ?? res.message ?? 'Gagal menerima quest');
    }
  }

  Future<void> declineFriendQuest(String questId) async {
    final res = await _apiClient.post<dynamic>('${ApiConstants.friendQuests}/$questId/decline');
    if (!res.success) {
      throw Exception(res.error ?? res.message ?? 'Gagal menolak quest');
    }
  }

  // ==========================================
  // Weekly League
  // ==========================================
  /// Returns null when there is no active league season (backend returns 404).
  Future<LeagueOverview?> getLeagueOverview() async {
    try {
      final res = await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.leagues}/overview',
        fromJson: (j) => Map<String, dynamic>.from(j as Map),
      );
      if (!res.success || res.data == null) return null;
      return LeagueOverviewModel.fromJson(res.data!);
    } on NotFoundException {
      return null;
    }
  }

  Future<List<LeagueDivision>> getLeagueDivisions() async {
    final res = await _apiClient.get<List<dynamic>>(
      '${ApiConstants.leagues}/divisions',
      fromJson: (j) => (j as List<dynamic>?) ?? <dynamic>[],
    );
    if (!res.success || res.data == null) {
      throw Exception(res.error ?? 'Gagal memuat divisi liga');
    }
    return res.data!
        .map((e) => LeagueDivisionModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}
