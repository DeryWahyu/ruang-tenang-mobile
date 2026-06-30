import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../models/wellness_model.dart';

class WellnessRemoteDataSource {
  final ApiClient _apiClient;

  WellnessRemoteDataSource(this._apiClient);

  Future<WellnessOnboardingResultModel> getOnboarding() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '${ApiConstants.wellness}/onboarding',
      fromJson: (json) => Map<String, dynamic>.from(json as Map),
    );
    if (!response.success || response.data == null) {
      throw Exception(response.error ?? 'Gagal memuat onboarding wellness');
    }
    return WellnessOnboardingResultModel.fromJson(response.data!);
  }

  Future<WellnessOnboardingResultModel> completeOnboarding(String initialMood, List<String> goals, List<String> habits) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '${ApiConstants.wellness}/onboarding',
      data: {
        'initial_mood': initialMood,
        'goals': goals,
        'habits': habits,
      },
      fromJson: (json) => Map<String, dynamic>.from(json as Map),
    );
    if (!response.success || response.data == null) {
      throw Exception(response.error ?? 'Gagal menyimpan onboarding wellness');
    }
    return WellnessOnboardingResultModel.fromJson(response.data!);
  }

  Future<WellnessPlanModel> getCurrentPlan() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '${ApiConstants.wellness}/plan/current',
      fromJson: (json) => Map<String, dynamic>.from(json as Map),
    );
    if (!response.success || response.data == null) {
      throw Exception(response.error ?? 'Gagal memuat plan wellness');
    }
    return WellnessPlanModel.fromJson(response.data!);
  }

  Future<void> completePlanItem(String itemId) async {
    final response = await _apiClient.patch<dynamic>(
      '${ApiConstants.wellness}/plan/items/$itemId/complete',
    );
    if (!response.success) {
      throw Exception(response.error ?? 'Gagal menyelesaikan tugas plan');
    }
  }
}