import 'package:equatable/equatable.dart';

abstract class WellnessEvent extends Equatable {
  const WellnessEvent();
  @override
  List<Object?> get props => [];
}

class WellnessOnboardingRequested extends WellnessEvent {
  const WellnessOnboardingRequested();
}

class WellnessOnboardingSubmitted extends WellnessEvent {
  final String initialMood;
  final List<String> goals;
  final List<String> habits;
  const WellnessOnboardingSubmitted({required this.initialMood, required this.goals, required this.habits});
  @override
  List<Object?> get props => [initialMood, goals, habits];
}

class WellnessPlanRequested extends WellnessEvent {
  const WellnessPlanRequested();
}

class WellnessPlanItemCompleted extends WellnessEvent {
  final String itemId;
  const WellnessPlanItemCompleted(this.itemId);
  @override
  List<Object?> get props => [itemId];
}