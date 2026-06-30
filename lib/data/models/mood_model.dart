import 'package:equatable/equatable.dart';
import '../../core/utils/json_parser.dart';
import '../../domain/entities/mood.dart';

/// Data-layer model for [UserMood]. JSON (de)serialization lives here;
/// mapping to the pure-Dart entity via [toEntity].
///
/// [MoodType] (enum) is defined in the domain entity and imported here.
class UserMoodModel extends Equatable {
  final int id;
  final MoodType mood;
  final String emoji;
  final DateTime createdAt;

  const UserMoodModel({
    required this.id,
    required this.mood,
    required this.emoji,
    required this.createdAt,
  });

  factory UserMoodModel.fromJson(Map<String, dynamic> json) {
    return UserMoodModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      mood: MoodType.fromString(json['mood'] as String?),
      emoji: (json['emoji'] as String?)?.isNotEmpty == true
          ? json['emoji'] as String
          : MoodType.fromString(json['mood'] as String?).emoji,
      createdAt: Json.date(json['created_at']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'mood': mood.value,
        'emoji': emoji,
        'created_at': createdAt.toIso8601String(),
      };

  UserMood toEntity() => UserMood(
        id: id,
        mood: mood,
        emoji: emoji,
        createdAt: createdAt,
      );

  static UserMoodModel fromEntity(UserMood e) => UserMoodModel(
        id: e.id,
        mood: e.mood,
        emoji: e.emoji,
        createdAt: e.createdAt,
      );

  @override
  List<Object?> get props => [id, mood, createdAt];
}

/// Data-layer model for [MoodHistory] — ({moods, total_count}).
class MoodHistoryModel extends Equatable {
  final List<UserMoodModel> moods;
  final int totalCount;

  const MoodHistoryModel({
    this.moods = const [],
    this.totalCount = 0,
  });

  factory MoodHistoryModel.fromJson(Map<String, dynamic> json) {
    return MoodHistoryModel(
      moods: (json['moods'] as List<dynamic>?)
              ?.map((e) => UserMoodModel.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      totalCount: (json['total_count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'moods': moods.map((e) => e.toJson()).toList(),
        'total_count': totalCount,
      };

  MoodHistory toEntity() => MoodHistory(
        moods: moods.map((e) => e.toEntity()).toList(),
        totalCount: totalCount,
      );

  @override
  List<Object?> get props => [moods, totalCount];
}

/// Data-layer model for [TodayMood] — ({has_checked, mood}).
class TodayMoodModel extends Equatable {
  final bool hasChecked;
  final UserMoodModel? mood;

  const TodayMoodModel({
    this.hasChecked = false,
    this.mood,
  });

  factory TodayMoodModel.fromJson(Map<String, dynamic> json) {
    final moodJson = json['mood'];
    return TodayMoodModel(
      hasChecked: json['has_checked'] as bool? ?? false,
      mood: moodJson is Map<String, dynamic>
          ? UserMoodModel.fromJson(Map<String, dynamic>.from(moodJson))
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'has_checked': hasChecked,
        if (mood != null) 'mood': mood!.toJson(),
      };

  TodayMood toEntity() => TodayMood(
        hasChecked: hasChecked,
        mood: mood?.toEntity(),
      );

  @override
  List<Object?> get props => [hasChecked, mood];
}

/// Data-layer model for [MoodStats] — raw `Map<String, int>` from
/// `/user-moods/stats`. Only moods with count > 0 are present.
class MoodStatsModel extends Equatable {
  final Map<MoodType, int> counts;

  const MoodStatsModel({this.counts = const {}});

  factory MoodStatsModel.fromJson(Map<String, dynamic> json) {
    final counts = <MoodType, int>{};
    json.forEach((key, value) {
      final mood = MoodType.fromString(key);
      counts[mood] = (value as num?)?.toInt() ?? 0;
    });
    return MoodStatsModel(counts: counts);
  }

  Map<String, dynamic> toJson() =>
      counts.map((key, value) => MapEntry(key.value, value));

  MoodStats toEntity() => MoodStats(counts: counts);

  @override
  List<Object?> get props => [counts];
}

