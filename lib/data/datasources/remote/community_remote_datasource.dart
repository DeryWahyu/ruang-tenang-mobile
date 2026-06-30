import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../models/community_model.dart';

/// Sumber data remote untuk fitur Komunitas.
class CommunityRemoteDataSource {
  final ApiClient _apiClient;

  CommunityRemoteDataSource(this._apiClient);

  /// Mengambil statistik komunitas bulan berjalan: `GET /community/stats`.
  Future<CommunityStatsModel> getStats() async {
    final res = await _apiClient.get<Map<String, dynamic>>(
      '${ApiConstants.community}/stats',
      fromJson: (j) => Map<String, dynamic>.from(j as Map),
    );
    if (!res.success || res.data == null) {
      throw Exception(res.error ?? 'Gagal memuat statistik komunitas');
    }
    return CommunityStatsModel.fromJson(res.data!);
  }
}
