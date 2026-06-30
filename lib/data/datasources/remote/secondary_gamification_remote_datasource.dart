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
}
