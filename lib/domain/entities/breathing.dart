import 'package:equatable/equatable.dart';

class BreathingTechnique extends Equatable {
  final String id; // UUID
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

  const BreathingTechnique({
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

class BreathingSession extends Equatable {
  final String id; // UUID
  final String techniqueId; // UUID
  final BreathingTechnique? technique;
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

  const BreathingSession({
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

class BreathingPreferences extends Equatable {
  final int defaultDurationSeconds;
  final String? defaultTechniqueId;
  final String voiceGuidance;
  final String backgroundSound;
  final String defaultBackgroundSound;
  final bool hapticFeedback;
  final String animationSpeed;
  final String theme;
  final bool reminderEnabled;
  final String reminderTime;
  final String reminderDays;
  final bool tutorialCompleted;

  const BreathingPreferences({
    required this.defaultDurationSeconds,
    this.defaultTechniqueId,
    required this.voiceGuidance,
    required this.backgroundSound,
    required this.defaultBackgroundSound,
    required this.hapticFeedback,
    required this.animationSpeed,
    required this.theme,
    required this.reminderEnabled,
    this.reminderTime = '',
    required this.reminderDays,
    required this.tutorialCompleted,
  });

  @override
  List<Object?> get props => [
        defaultDurationSeconds,
        defaultTechniqueId,
        voiceGuidance,
        backgroundSound,
        defaultBackgroundSound,
        hapticFeedback,
        animationSpeed,
        theme,
        reminderEnabled,
        reminderTime,
        reminderDays,
        tutorialCompleted,
      ];
}

class BreathingDailyStats extends Equatable {
  final String date;
  final int sessionsCount;
  final int totalMinutes;
  final String favoriteTechnique;

  const BreathingDailyStats({
    required this.date,
    this.sessionsCount = 0,
    this.totalMinutes = 0,
    this.favoriteTechnique = '',
  });

  @override
  List<Object?> get props => [date, sessionsCount, totalMinutes, favoriteTechnique];
}

class BreathingOverallStats extends Equatable {
  final int totalSessions;
  final int totalMinutes;
  final int currentStreak;
  final int longestStreak;
  final String mostUsedTechnique;
  final String mostUsedTechniqueId;
  final double averageSessionsPerWeek;
  final double completionRate;

  const BreathingOverallStats({
    this.totalSessions = 0,
    this.totalMinutes = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.mostUsedTechnique = '',
    this.mostUsedTechniqueId = '',
    this.averageSessionsPerWeek = 0.0,
    this.completionRate = 0.0,
  });

  @override
  List<Object?> get props => [
        totalSessions,
        totalMinutes,
        currentStreak,
        longestStreak,
        mostUsedTechnique,
        mostUsedTechniqueId,
        averageSessionsPerWeek,
        completionRate,
      ];
}

class BreathingStreakInfo extends Equatable {
  final int currentStreak;
  final int longestStreak;
  final String lastPracticeDate;
  final bool streakFreezeAvailable;
  final int daysUntilStreakBreak;

  const BreathingStreakInfo({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastPracticeDate = '',
    this.streakFreezeAvailable = false,
    this.daysUntilStreakBreak = 0,
  });

  @override
  List<Object?> get props => [
        currentStreak,
        longestStreak,
        lastPracticeDate,
        streakFreezeAvailable,
        daysUntilStreakBreak,
      ];
}

class BreathingStats extends Equatable {
  final BreathingDailyStats today;
  final BreathingOverallStats overall;
  final BreathingStreakInfo streakInfo;

  const BreathingStats({
    required this.today,
    required this.overall,
    required this.streakInfo,
  });

  @override
  List<Object?> get props => [today, overall, streakInfo];
}
