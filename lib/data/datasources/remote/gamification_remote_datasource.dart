import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
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

  Future<Map<String, dynamic>> getExpHistory({int page = 1, int limit = 10}) async {
    final response = await _apiClient.getPaginated<ExpHistoryModel>(
      ApiConstants.expHistory,
      queryParameters: {'page': page, 'limit': limit},
      fromJson: (json) => ExpHistoryModel.fromJson(json),
    );
    return {
      'items': response.data,
      'total': response.totalItems,
      'page': response.page,
      'limit': response.limit,
    };
  }

  Future<List<BadgeProgressModel>> getBadges() async {
    final response = await _apiClient.get<List<dynamic>>(
      ApiConstants.badges + '/progress',
      fromJson: (json) => json as List<dynamic>,
    );
    if (!response.success || response.data == null) {
      throw Exception(response.error ?? 'Gagal memuat badges');
    }
    return response.data!
        .map((e) => BadgeProgressModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

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
      ApiConstants.chests + '/$chestId/open',
      fromJson: (json) => Map<String, dynamic>.from(json as Map),
    );
    if (!response.success || response.data == null) {
      throw Exception(response.error ?? 'Gagal membuka chest');
    }
    return response.data!;
  }

  Future<DailySpinWheelModel> getSpinWheel() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.dailySpin + '/wheel',
      fromJson: (json) => Map<String, dynamic>.from(json as Map),
    );
    if (!response.success || response.data == null) {
      throw Exception(response.error ?? 'Gagal memuat daily spin');
    }
    return DailySpinWheelModel.fromJson(response.data!);
  }

  Future<Map<String, dynamic>> spinWheel() async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.dailySpin + '/spin',
      fromJson: (json) => Map<String, dynamic>.from(json as Map),
    );
    if (!response.success || response.data == null) {
      throw Exception(response.error ?? 'Gagal memutar spin');
    }
    return response.data!;
  }
}