import '../../domain/entities/wellness.dart';
import '../../domain/repositories/wellness_repository.dart';
import '../datasources/remote/wellness_remote_datasource.dart';

class WellnessRepositoryImpl implements WellnessRepository {
  final WellnessRemoteDataSource _remote;

  WellnessRepositoryImpl({required WellnessRemoteDataSource remote}) : _remote = remote;

  @override
  Future<WellnessOnboardingResult> getOnboarding() async {
    final model = await _remote.getOnboarding();
    return model.toEntity();
  }

  @override
  Future<WellnessOnboardingResult> completeOnboarding(String initialMood, List<String> goals, List<String> habits) async {
    final model = await _remote.completeOnboarding(initialMood, goals, habits);
    return model.toEntity();
  }

  @override
  Future<WellnessPlan> getCurrentPlan() async {
    final model = await _remote.getCurrentPlan();
    return model.toEntity();
  }

  @override
  Future<void> completePlanItem(String itemId) async {
    await _remote.completePlanItem(itemId);
  }
}