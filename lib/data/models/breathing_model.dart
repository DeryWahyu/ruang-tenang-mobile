import 'package:equatable/equatable.dart';
import '../../domain/entities/breathing.dart';

class BreathingTechniqueModel extends Equatable {
  final String id;
  final String name;
  final String slug;
  final String description;
  final String benefits;
  final String bestFor;
  final int inhaleDuration;
  final int inhaleHoldDuration;
  final int exhaleDuration;
  final int exhaleHoldDuration;
  final int totalCycleDuration;
  final String icon;
  final String color;
  final String animationType;
  final String difficulty;
  final String category;
  final String origin;
  final bool isSystem;
  final bool isFavorite;
  final DateTime createdAt;

  const BreathingTechniqueModel({
    required this.id,
    required this.name,
    this.slug = '',
    this.description = '',
    this.benefits = '',
    this.bestFor = '',
    required this.inhaleDuration,
    required this.inhaleHoldDuration,
    required this.exhaleDuration,
    required this.exhaleHoldDuration,
    required this.totalCycleDuration,
    required this.icon,
    required this.color,
    required this.animationType,
    required this.difficulty,
    required this.category,
    this.origin = '',
    this.isSystem = false,
    this.isFavorite = false,
    required this.createdAt,
  });

  factory BreathingTechniqueModel.fromJson(Map<String, dynamic> json) {
    return BreathingTechniqueModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String? ?? '',
      benefits: json['benefits'] as String? ?? '',
      bestFor: json['best_for'] as String? ?? '',
      inhaleDuration: (json['inhale_duration'] as num?)?.toInt() ?? 0,
      inhaleHoldDuration: (json['inhale_hold_duration'] as num?)?.toInt() ?? 0,
      exhaleDuration: (json['exhale_duration'] as num?)?.toInt() ?? 0,
      exhaleHoldDuration: (json['exhale_hold_duration'] as num?)?.toInt() ?? 0,
      totalCycleDuration: (json['total_cycle_duration'] as num?)?.toInt() ?? 0,
      icon: json['icon'] as String? ?? '',
      color: json['color'] as String? ?? '',
      animationType: json['animation_type'] as String? ?? '',
      difficulty: json['difficulty'] as String? ?? '',
      category: json['category'] as String? ?? '',
      origin: json['origin'] as String? ?? '',
      isSystem: json['is_system'] as bool? ?? false,
      isFavorite: json['is_favorite'] as bool? ?? false,
      createdAt: _parseDate(json['created_at']) ?? DateTime.now(),
    );
  }

  BreathingTechnique toEntity() => BreathingTechnique(
        id: id,
        name: name,
        slug: slug,
        description: description,
        benefits: benefits,
        bestFor: bestFor,
        inhaleDuration: inhaleDuration,
        inhaleHoldDuration: inhaleHoldDuration,
        exhaleDuration: exhaleDuration,
        exhaleHoldDuration: exhaleHoldDuration,
        totalCycleDuration: totalCycleDuration,
        icon: icon,
        color: color,
        animationType: animationType,
        difficulty: difficulty,
        category: category,
        origin: origin,
        isSystem: isSystem,
        isFavorite: isFavorite,
        createdAt: createdAt,
      );

  @override
  List<Object?> get props => [
        id,
        name,
        slug,
        description,
        benefits,
        bestFor,
        inhaleDuration,
        inhaleHoldDuration,
        exhaleDuration,
        exhaleHoldDuration,
        totalCycleDuration,
        icon,
        color,
        animationType,
        difficulty,
        category,
        origin,
        isSystem,
        isFavorite,
        createdAt,
      ];
}

class BreathingSessionModel extends Equatable {
  final String id;
  final String techniqueId;
  final BreathingTechniqueModel? technique;
  final int durationSeconds;
  final int targetDurationSeconds;
  final int cyclesCompleted;
  final bool voiceGuidanceEnabled;
  final String backgroundSound;
  final bool hapticFeedbackEnabled;
  final bool completed;
  final int completedPercentage;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int xpEarned;
  final String moodBefore;
  final String moodAfter;

  const BreathingSessionModel({
    required this.id,
    required this.techniqueId,
    this.technique,
    required this.durationSeconds,
    required this.targetDurationSeconds,
    this.cyclesCompleted = 0,
    this.voiceGuidanceEnabled = false,
    this.backgroundSound = '',
    this.hapticFeedbackEnabled = false,
    this.completed = false,
    this.completedPercentage = 0,
    required this.startedAt,
    this.endedAt,
    this.xpEarned = 0,
    this.moodBefore = '',
    this.moodAfter = '',
  });

  factory BreathingSessionModel.fromJson(Map<String, dynamic> json) {
    return BreathingSessionModel(
      id: json['id'] as String? ?? '',
      techniqueId: json['technique_id'] as String? ?? '',
      technique: json['technique'] != null
          ? BreathingTechniqueModel.fromJson(Map<String, dynamic>.from(json['technique'] as Map))
          : null,
      durationSeconds: (json['duration_seconds'] as num?)?.toInt() ?? 0,
      targetDurationSeconds: (json['target_duration_seconds'] as num?)?.toInt() ?? 0,
      cyclesCompleted: (json['cycles_completed'] as num?)?.toInt() ?? 0,
      voiceGuidanceEnabled: json['voice_guidance_enabled'] as bool? ?? false,
      backgroundSound: json['background_sound'] as String? ?? '',
      hapticFeedbackEnabled: json['haptic_feedback_enabled'] as bool? ?? false,
      completed: json['completed'] as bool? ?? false,
      completedPercentage: (json['completed_percentage'] as num?)?.toInt() ?? 0,
      startedAt: _parseDate(json['started_at']) ?? DateTime.now(),
      endedAt: _parseDate(json['ended_at']),
      xpEarned: (json['xp_earned'] as num?)?.toInt() ?? 0,
      moodBefore: json['mood_before'] as String? ?? '',
      moodAfter: json['mood_after'] as String? ?? '',
    );
  }

  BreathingSession toEntity() => BreathingSession(
        id: id,
        techniqueId: techniqueId,
        technique: technique?.toEntity(),
        durationSeconds: durationSeconds,
        targetDurationSeconds: targetDurationSeconds,
        cyclesCompleted: cyclesCompleted,
        voiceGuidanceEnabled: voiceGuidanceEnabled,
        backgroundSound: backgroundSound,
        hapticFeedbackEnabled: hapticFeedbackEnabled,
        completed: completed,
        completedPercentage: completedPercentage,
        startedAt: startedAt,
        endedAt: endedAt,
        xpEarned: xpEarned,
        moodBefore: moodBefore,
        moodAfter: moodAfter,
      );

  @override
  List<Object?> get props => [
        id,
        techniqueId,
        technique,
        durationSeconds,
        targetDurationSeconds,
        cyclesCompleted,
        voiceGuidanceEnabled,
        backgroundSound,
        hapticFeedbackEnabled,
        completed,
        completedPercentage,
        startedAt,
        endedAt,
        xpEarned,
        moodBefore,
        moodAfter,
      ];
}

class BreathingStatsModel extends Equatable {
  final Map<String, dynamic> today;
  final Map<String, dynamic> overall;
  final Map<String, dynamic> streakInfo;

  const BreathingStatsModel({
    required this.today,
    required this.overall,
    required this.streakInfo,
  });

  factory BreathingStatsModel.fromJson(Map<String, dynamic> json) {
    return BreathingStatsModel(
      today: Map<String, dynamic>.from(json['today'] as Map? ?? {}),
      overall: Map<String, dynamic>.from(json['overall'] as Map? ?? {}),
      streakInfo: Map<String, dynamic>.from(json['streak_info'] as Map? ?? {}),
    );
  }

  BreathingStats toEntity() => BreathingStats(
        today: BreathingDailyStats(
          date: today['date'] as String? ?? '',
          sessionsCount: (today['sessions_count'] as num?)?.toInt() ?? 0,
          totalMinutes: (today['total_minutes'] as num?)?.toInt() ?? 0,
          favoriteTechnique: today['favorite_technique'] as String? ?? '',
        ),
        overall: BreathingOverallStats(
          totalSessions: (overall['total_sessions'] as num?)?.toInt() ?? 0,
          totalMinutes: (overall['total_minutes'] as num?)?.toInt() ?? 0,
          currentStreak: (overall['current_streak'] as num?)?.toInt() ?? 0,
          longestStreak: (overall['longest_streak'] as num?)?.toInt() ?? 0,
          mostUsedTechnique: overall['most_used_technique'] as String? ?? '',
          mostUsedTechniqueId: overall['most_used_technique_id'] as String? ?? '',
          averageSessionsPerWeek: (overall['average_sessions_per_week'] as num?)?.toDouble() ?? 0.0,
          completionRate: (overall['completion_rate'] as num?)?.toDouble() ?? 0.0,
        ),
        streakInfo: BreathingStreakInfo(
          currentStreak: (streakInfo['current_streak'] as num?)?.toInt() ?? 0,
          longestStreak: (streakInfo['longest_streak'] as num?)?.toInt() ?? 0,
          lastPracticeDate: streakInfo['last_practice_date'] as String? ?? '',
          streakFreezeAvailable: streakInfo['streak_freeze_available'] as bool? ?? false,
          daysUntilStreakBreak: (streakInfo['days_until_streak_break'] as num?)?.toInt() ?? 0,
        ),
      );

  @override
  List<Object?> get props => [today, overall, streakInfo];
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
