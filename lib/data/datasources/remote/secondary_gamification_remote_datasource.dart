import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../domain/entities/secondary_gamification.dart';
import '../../models/secondary_gamification_model.dart';

class SecondaryGamificationRemoteDataSource {
  final ApiClient _apiClient;

  SecondaryGamificationRemoteDataSource(this._apiClient);

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
