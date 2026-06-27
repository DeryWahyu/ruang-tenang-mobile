import 'package:equatable/equatable.dart';

class WellnessProfile extends Equatable {
  final int id;
  final int userId;
  final String initialMood;
  final List<String> goals;
  final List<String> habits;
  final DateTime? tourCompletedAt;
  final DateTime? onboardingCompletedAt;

  const WellnessProfile({
    required this.id,
    required this.userId,
    required this.initialMood,
    this.goals = const [],
    this.habits = const [],
    this.tourCompletedAt,
    this.onboardingCompletedAt,
  });

  @override
  List<Object?> get props => [id, userId, initialMood, goals, habits, tourCompletedAt, onboardingCompletedAt];
}

class WellnessPlanItem extends Equatable {
  final String id;
  final int dayNumber;
  final String itemDate;
  final String title;
  final String description;
  final String actionType;
  final String route;
  final String status;
  final DateTime? completedAt;

  const WellnessPlanItem({
    required this.id,
    required this.dayNumber,
    required this.itemDate,
    required this.title,
    required this.description,
    required this.actionType,
    required this.route,
    required this.status,
    this.completedAt,
  });

  @override
  List<Object?> get props => [id, dayNumber, itemDate, title, description, actionType, route, status, completedAt];
}

class WellnessPlan extends Equatable {
  final String id;
  final String title;
  final String summary;
  final String status;
  final String startsOn;
  final String endsOn;
  final int completionPercent;
  final List<WellnessPlanItem> items;

  const WellnessPlan({
    required this.id,
    required this.title,
    required this.summary,
    required this.status,
    required this.startsOn,
    required this.endsOn,
    this.completionPercent = 0,
    this.items = const [],
  });

  @override
  List<Object?> get props => [id, title, summary, status, startsOn, endsOn, completionPercent, items];
}

class WellnessOnboardingResult extends Equatable {
  final bool needsOnboarding;
  final WellnessProfile? profile;
  final WellnessPlan? plan;

  const WellnessOnboardingResult({
    required this.needsOnboarding,
    this.profile,
    this.plan,
  });

  @override
  List<Object?> get props => [needsOnboarding, profile, plan];
}