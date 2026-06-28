import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../domain/entities/gamification.dart';
import '../../models/gamification_model.dart';

class GamificationRemoteDataSource {
  final ApiClient _apiClient;

  GamificationRemoteDataSource(this._apiClient);

  Future<UserLevelInfoModel> getUserLevelInfo() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.me,
      fromJson: (json) => Map<String, dynamic>.from(json as Map),
    );
    if (!response.success || response.data == null) {
      throw Exception(response.error ?? 'Gagal memuat level user');
    }
    return UserLevelInfoModel.fromJson(response.data!['user'] ?? response.data!);
  }

  /// Personal journey — sumber kebenaran untuk level, XP, progress, tier, streak.
  Future<PersonalJourney> getPersonalJourney() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '${ApiConstants.community}/my-journey',
      fromJson: (json) => Map<String, dynamic>.from(json as Map),
    );
    if (!response.success || response.data == null) {
      throw Exception(response.error ?? 'Gagal memuat perjalanan personal');
    }
    return PersonalJourneyModel.fromJson(response.data!);
  }

  /// EXP history. Backend mengembalikan envelope:
  /// { success, data: { data: [...], total, page, limit, total_pages } }
  Future<Map<String, dynamic>> getExpHistory({int page = 1, int limit = 10}) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.expHistory,
      queryParameters: {'page': page, 'limit': limit},
      fromJson: (json) => Map<String, dynamic>.from(json as Map),
    );
    if (!response.success || response.data == null) {
      throw Exception(response.error ?? 'Gagal memuat riwayat EXP');
    }
    final data = response.data!;
    final items = (data['data'] as List<dynamic>?)
            ?.map((e) => ExpHistoryModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList() ??
        [];
    return {
      'items': items,
      'total': (data['total'] as num?)?.toInt() ?? items.length,
      'page': (data['page'] as num?)?.toInt() ?? page,
      'limit': (data['limit'] as num?)?.toInt() ?? limit,
      'total_pages': (data['total_pages'] as num?)?.toInt() ?? 1,
    };
  }

  Future<List<BadgeProgressModel>> getBadges() async {
    final response = await _apiClient.get<List<dynamic>>(
      '${ApiConstants.badges}/progress',
      fromJson: (json) => json as List<dynamic>,
    );
    if (!response.success || response.data == null) {
      throw Exception(response.error ?? 'Gagal memuat badges');
    }
    return response.data!
        .map((e) => BadgeProgressModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  // ==========================================
  // Daily Tasks
  // ==========================================
  Future<DailyTaskSummary> getDailyTasks() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.dailyTasks,
      fromJson: (json) => Map<String, dynamic>.from(json as Map),
    );
    if (!response.success || response.data == null) {
      throw Exception(response.error ?? 'Gagal memuat daily tasks');
    }
    return DailyTaskSummaryModel.fromJson(response.data!);
  }

  Future<Map<String, dynamic>> claimDailyTask(int taskId) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '${ApiConstants.dailyTasks}/$taskId/claim',
      fromJson: (json) => Map<String, dynamic>.from(json as Map),
    );
    if (!response.success) {
      throw Exception(response.error ?? response.message ?? 'Gagal mengklaim reward');
    }
    return {'message': response.message, ...?response.data};
  }

  Future<Map<String, dynamic>> claimAllDailyTasks() async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '${ApiConstants.dailyTasks}/claim-all',
      fromJson: (json) => Map<String, dynamic>.from(json as Map),
    );
    if (!response.success) {
      throw Exception(response.error ?? response.message ?? 'Gagal mengklaim reward');
    }
    return {'message': response.message, ...?response.data};
  }

  Future<Map<String, dynamic>> claimDailyLogin() async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '${ApiConstants.dailyTasks}/login',
      fromJson: (json) => Map<String, dynamic>.from(json as Map),
    );
    if (!response.success) {
      throw Exception(response.error ?? response.message ?? 'Gagal memproses login harian');
    }
    return {'message': response.message, ...?response.data};
  }

  // ==========================================
  // Progress Map
  // ==========================================
  Future<ProgressMap> getProgressMap() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.map,
      fromJson: (json) => Map<String, dynamic>.from(json as Map),
    );
    if (!response.success || response.data == null) {
      throw Exception(response.error ?? 'Gagal memuat peta progress');
    }
    return ProgressMapModel.fromJson(response.data!);
  }

  Future<Map<String, dynamic>> claimLandmark(String landmarkId) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '${ApiConstants.map}/landmarks/$landmarkId/claim',
      fromJson: (json) => Map<String, dynamic>.from(json as Map),
    );
    if (!response.success) {
      throw Exception(response.error ?? response.message ?? 'Gagal mengklaim hadiah landmark');
    }
    return {'message': response.message, ...?response.data};
  }

  // ==========================================
  // Hall of Fame / Leaderboard
  // ==========================================
  Future<List<HallOfFameEntry>> getMonthlyHallOfFame({required int month, required int year, String? category}) async {
    final response = await _apiClient.get<List<dynamic>>(
      '${ApiConstants.community}/hall-of-fame/monthly',
      queryParameters: {
        'month': month,
        'year': year,
        if (category != null && category.isNotEmpty) 'category': category,
      },
      fromJson: (json) => (json as List<dynamic>?) ?? <dynamic>[],
    );
    if (!response.success || response.data == null) {
      throw Exception(response.error ?? 'Gagal memuat papan peringkat');
    }
    return response.data!
        .map((e) => HallOfFameEntryModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<List<HallOfFameEntry>> getLevelHallOfFame(int level, {int limit = 10}) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '${ApiConstants.community}/hall-of-fame/level/$level',
      queryParameters: {'limit': limit},
      fromJson: (json) => Map<String, dynamic>.from(json as Map),
    );
    if (!response.success || response.data == null) {
      throw Exception(response.error ?? 'Gagal memuat papan peringkat');
    }
    final featured = response.data!['featured_users'] as List<dynamic>? ?? [];
    return featured
        .map((e) => HallOfFameEntryModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  // ==========================================
  // Rewards Shop
  // ==========================================
  Future<List<Reward>> getRewards() async {
    final response = await _apiClient.get<List<dynamic>>(
      ApiConstants.rewards,
      fromJson: (json) => (json as List<dynamic>?) ?? <dynamic>[],
    );
    if (!response.success || response.data == null) {
      throw Exception(response.error ?? 'Gagal memuat daftar hadiah');
    }
    return response.data!
        .map((e) => RewardModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<int> getCoinBalance() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '${ApiConstants.rewards}/balance',
      fromJson: (json) => Map<String, dynamic>.from(json as Map),
    );
    if (!response.success || response.data == null) {
      throw Exception(response.error ?? 'Gagal memuat saldo koin');
    }
    return (response.data!['gold_coins'] as num?)?.toInt() ?? 0;
  }

  Future<Map<String, dynamic>> claimReward(int rewardId) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '${ApiConstants.rewards}/$rewardId/claim',
      fromJson: (json) => Map<String, dynamic>.from(json as Map),
    );
    if (!response.success) {
      throw Exception(response.error ?? response.message ?? 'Gagal mengklaim hadiah');
    }
    return {'message': response.message, ...?response.data};
  }

  // ==========================================
  // Mystery Chest
  // ==========================================
  Future<List<MysteryChestModel>> getChests() async {
    final response = await _apiClient.get<List<dynamic>>(
      ApiConstants.chests,
      fromJson: (json) => json as List<dynamic>,
    );
    if (!response.success || response.data == null) {
      throw Exception(response.error ?? 'Gagal memuat mystery chests');
    }
    return response.data!
        .map((e) => MysteryChestModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<Map<String, dynamic>> openChest(String chestId) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '${ApiConstants.chests}/$chestId/open',
      fromJson: (json) => Map<String, dynamic>.from(json as Map),
    );
    if (!response.success || response.data == null) {
      throw Exception(response.error ?? 'Gagal membuka chest');
    }
    return response.data!;
  }

  // ==========================================
  // Daily Spin
  // ==========================================
  Future<DailySpinWheelModel> getSpinWheel() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '${ApiConstants.dailySpin}/wheel',
      fromJson: (json) => Map<String, dynamic>.from(json as Map),
    );
    if (!response.success || response.data == null) {
      throw Exception(response.error ?? 'Gagal memuat daily spin');
    }
    return DailySpinWheelModel.fromJson(response.data!);
  }

  Future<Map<String, dynamic>> spinWheel() async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '${ApiConstants.dailySpin}/spin',
      fromJson: (json) => Map<String, dynamic>.from(json as Map),
    );
    if (!response.success || response.data == null) {
      throw Exception(response.error ?? 'Gagal memutar spin');
    }
    return response.data!;
  }
}
