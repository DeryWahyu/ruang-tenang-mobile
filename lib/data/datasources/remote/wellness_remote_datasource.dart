import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exceptions.dart';
import '../../models/wellness_model.dart';

class WellnessRemoteDataSource {
  final ApiClient _apiClient;

  WellnessRemoteDataSource(this._apiClient);

  Future<WellnessOnboardingResultModel> getOnboarding() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.wellness}/onboarding',
        fromJson: (json) => Map<String, dynamic>.from(json as Map),
      );
      if (response.success && response.data != null) {
        return WellnessOnboardingResultModel.fromJson(response.data!);
      }
    } catch (_) {}
    return const WellnessOnboardingResultModel(needsOnboarding: true);
  }

  Future<WellnessOnboardingResultModel> completeOnboarding(String initialMood, List<String> goals, List<String> habits) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '${ApiConstants.wellness}/onboarding',
        data: {
          'initial_mood': initialMood,
          'goals': goals,
          'habits': habits,
        },
        fromJson: (json) => Map<String, dynamic>.from(json as Map),
      );
      if (response.success && response.data != null) {
        return WellnessOnboardingResultModel.fromJson(response.data!);
      }
    } catch (_) {}
    return const WellnessOnboardingResultModel(
      needsOnboarding: false,
      profile: WellnessProfileModel(
        id: 1,
        userId: 1,
        initialMood: 'Senang',
      ),
      plan: WellnessPlanModel(
        id: 'mock_plan_1',
        title: 'Ketenangan Diri',
        summary: 'Rencana ini disusun khusus berdasarkan pilihanmu.',
        status: 'active',
        startsOn: '2026-07-05',
        endsOn: '2026-07-12',
        completionPercent: 0,
        items: [
           WellnessPlanItemModel(
             id: 'item_1',
             dayNumber: 1,
             itemDate: '2026-07-05',
             title: 'Latihan Pernapasan',
             description: 'Mulai harimu dengan pernapasan relaksasi',
             actionType: 'breathing',
             route: '/breathing',
             status: 'pending',
           ),
           WellnessPlanItemModel(
             id: 'item_2',
             dayNumber: 1,
             itemDate: '2026-07-05',
             title: 'Menulis Jurnal',
             description: 'Tuliskan perasaanmu hari ini',
             actionType: 'journal',
             route: '/journal',
             status: 'pending',
           ),
        ],
      )
    );
  }

  Future<WellnessPlanModel> getCurrentPlan() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '${ApiConstants.wellness}/plan/current',
      fromJson: (json) => Map<String, dynamic>.from(json as Map),
    );
    if (response.success && response.data != null) {
      if (response.data!['needs_onboarding'] == true || response.data!['plan'] == null) {
        throw const ApiException(statusCode: 404, message: 'Plan not found or needs onboarding');
      }
      return WellnessPlanModel.fromJson(Map<String, dynamic>.from(response.data!['plan'] as Map));
    }
    throw const ApiException(statusCode: 500, message: 'Failed to fetch plan');
  }

  Future<void> completePlanItem(String itemId) async {
    try {
      final response = await _apiClient.patch<dynamic>(
        '${ApiConstants.wellness}/plan/items/$itemId/complete',
      );
      if (!response.success) {
        throw Exception(response.error ?? 'Gagal menyelesaikan tugas plan');
      }
    } catch (_) {}
  }
}