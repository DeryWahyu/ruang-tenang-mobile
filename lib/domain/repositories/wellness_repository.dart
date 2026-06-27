import '../entities/wellness.dart';

abstract class WellnessRepository {
  Future<WellnessOnboardingResult> getOnboarding();
  Future<WellnessOnboardingResult> completeOnboarding(String initialMood, List<String> goals, List<String> habits);
  Future<WellnessPlan> getCurrentPlan();
  Future<void> completePlanItem(String itemId);
}