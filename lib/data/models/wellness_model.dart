import 'package:equatable/equatable.dart';
import '../../domain/entities/wellness.dart';

class WellnessProfileModel extends Equatable {
  final int id;
  final int userId;
  final String initialMood;
  final List<String> goals;
  final List<String> habits;
  final DateTime? tourCompletedAt;
  final DateTime? onboardingCompletedAt;

  const WellnessProfileModel({
    required this.id,
    required this.userId,
    required this.initialMood,
    this.goals = const [],
    this.habits = const [],
    this.tourCompletedAt,
    this.onboardingCompletedAt,
  });

  factory WellnessProfileModel.fromJson(Map<String, dynamic> json) {
    return WellnessProfileModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userId: (json['user_id'] as num?)?.toInt() ?? 0,
      initialMood: json['initial_mood'] as String? ?? '',
      goals: (json['goals'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      habits: (json['habits'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      tourCompletedAt: _parseDate(json['tour_completed_at']),
      onboardingCompletedAt: _parseDate(json['onboarding_completed_at']),
    );
  }

  WellnessProfile toEntity() => WellnessProfile(
        id: id,
        userId: userId,
        initialMood: initialMood,
        goals: goals,
        habits: habits,
        tourCompletedAt: tourCompletedAt,
        onboardingCompletedAt: onboardingCompletedAt,
      );

  @override
  List<Object?> get props => [id, userId, initialMood, goals, habits, tourCompletedAt, onboardingCompletedAt];
}

class WellnessPlanItemModel extends Equatable {
  final String id;
  final int dayNumber;
  final String itemDate;
  final String title;
  final String description;
  final String actionType;
  final String route;
  final String status;
  final DateTime? completedAt;

  const WellnessPlanItemModel({
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

  factory WellnessPlanItemModel.fromJson(Map<String, dynamic> json) {
    return WellnessPlanItemModel(
      id: json['id'] as String? ?? '',
      dayNumber: (json['day_number'] as num?)?.toInt() ?? 0,
      itemDate: json['item_date'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      actionType: json['action_type'] as String? ?? '',
      route: json['route'] as String? ?? '',
      status: json['status'] as String? ?? '',
      completedAt: _parseDate(json['completed_at']),
    );
  }

  WellnessPlanItem toEntity() => WellnessPlanItem(
        id: id,
        dayNumber: dayNumber,
        itemDate: itemDate,
        title: title,
        description: description,
        actionType: actionType,
        route: route,
        status: status,
        completedAt: completedAt,
      );

  @override
  List<Object?> get props => [id, dayNumber, itemDate, title, description, actionType, route, status, completedAt];
}

class WellnessPlanModel extends Equatable {
  final String id;
  final String title;
  final String summary;
  final String status;
  final String startsOn;
  final String endsOn;
  final int completionPercent;
  final List<WellnessPlanItemModel> items;

  const WellnessPlanModel({
    required this.id,
    required this.title,
    required this.summary,
    required this.status,
    required this.startsOn,
    required this.endsOn,
    this.completionPercent = 0,
    this.items = const [],
  });

  factory WellnessPlanModel.fromJson(Map<String, dynamic> json) {
    return WellnessPlanModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      status: json['status'] as String? ?? '',
      startsOn: json['starts_on'] as String? ?? '',
      endsOn: json['ends_on'] as String? ?? '',
      completionPercent: (json['completion_percent'] as num?)?.toInt() ?? 0,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => WellnessPlanItemModel.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
    );
  }

  WellnessPlan toEntity() => WellnessPlan(
        id: id,
        title: title,
        summary: summary,
        status: status,
        startsOn: startsOn,
        endsOn: endsOn,
        completionPercent: completionPercent,
        items: items.map((e) => e.toEntity()).toList(),
      );

  @override
  List<Object?> get props => [id, title, summary, status, startsOn, endsOn, completionPercent, items];
}

class WellnessOnboardingResultModel extends Equatable {
  final bool needsOnboarding;
  final WellnessProfileModel? profile;
  final WellnessPlanModel? plan;

  const WellnessOnboardingResultModel({
    required this.needsOnboarding,
    this.profile,
    this.plan,
  });

  factory WellnessOnboardingResultModel.fromJson(Map<String, dynamic> json) {
    return WellnessOnboardingResultModel(
      needsOnboarding: json['needs_onboarding'] as bool? ?? false,
      profile: json['profile'] != null ? WellnessProfileModel.fromJson(Map<String, dynamic>.from(json['profile'] as Map)) : null,
      plan: json['plan'] != null ? WellnessPlanModel.fromJson(Map<String, dynamic>.from(json['plan'] as Map)) : null,
    );
  }

  WellnessOnboardingResult toEntity() => WellnessOnboardingResult(
        needsOnboarding: needsOnboarding,
        profile: profile?.toEntity(),
        plan: plan?.toEntity(),
      );

  @override
  List<Object?> get props => [needsOnboarding, profile, plan];
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  if (value is! String || value.isEmpty) return null;
  try {
    return DateTime.parse(value).toLocal();
  } catch (_) {
    return null;
  }
}