import 'package:equatable/equatable.dart';

/// Mood type as defined by the backend enum (model/user_mood.go).
///
/// Pure Dart: value/label/emoji/fromString only. The `color` getter
/// lives in the `MoodTypeColorX` extension (core/utils/extensions.dart)
/// because it needs Flutter's [Color].
enum MoodType {
  happy,
  neutral,
  angry,
  disappointed,
  sad,
  crying;

  /// Parse from the backend string ("happy", "neutral", ...).
  /// Falls back to [neutral] for unknown values.
  static MoodType fromString(String? value) {
    switch (value) {
      case 'happy':
        return MoodType.happy;
      case 'neutral':
        return MoodType.neutral;
      case 'angry':
        return MoodType.angry;
      case 'disappointed':
        return MoodType.disappointed;
      case 'sad':
        return MoodType.sad;
      case 'crying':
        return MoodType.crying;
      default:
        return MoodType.neutral;
    }
  }

  /// Backend API value.
  String get value => name;

  /// Indonesian label.
  String get label {
    switch (this) {
      case MoodType.happy:
        return 'Senang';
      case MoodType.neutral:
        return 'Netral';
      case MoodType.angry:
        return 'Marah';
      case MoodType.disappointed:
        return 'Kecewa';
      case MoodType.sad:
        return 'Sedih';
      case MoodType.crying:
        return 'Menangis';
    }
  }

  /// Emoji unicode (fallback if server doesn't provide one).
  String get emoji {
    switch (this) {
      case MoodType.happy:
        return '\u{1F60A}'; // 😊
      case MoodType.neutral:
        return '\u{1F610}'; // 😐
      case MoodType.angry:
        return '\u{1F620}'; // 😠
      case MoodType.disappointed:
        return '\u{1F61E}'; // 😞
      case MoodType.sad:
        return '\u{1F622}'; // 😢
      case MoodType.crying:
        return '\u{1F62D}'; // 😭
    }
  }
}

/// A single user mood record (domain entity).
class UserMood extends Equatable {
  final int id;
  final MoodType mood;
  final String emoji;
  final DateTime createdAt;

  const UserMood({
    required this.id,
    required this.mood,
    required this.emoji,
    required this.createdAt,
  });

  /// Convenience emoji (server-provided or fallback).
  String get displayEmoji => emoji.isNotEmpty ? emoji : mood.emoji;

  @override
  List<Object?> get props => [id, mood, createdAt];
}

/// Mood history entity — ({moods, total_count}).
class MoodHistory extends Equatable {
  final List<UserMood> moods;
  final int totalCount;

  const MoodHistory({
    this.moods = const [],
    this.totalCount = 0,
  });

  @override
  List<Object?> get props => [moods, totalCount];
}

/// Today's mood status entity — ({has_checked, mood}).
class TodayMood extends Equatable {
  final bool hasChecked;
  final UserMood? mood;

  const TodayMood({
    this.hasChecked = false,
    this.mood,
  });

  @override
  List<Object?> get props => [hasChecked, mood];
}

/// Mood statistics — counts per mood. Only moods with count > 0 are
/// present in the raw backend map; [countOf] returns 0 for absent moods.
class MoodStats extends Equatable {
  final Map<MoodType, int> counts;

  const MoodStats({this.counts = const {}});

  int get total => counts.values.fold(0, (sum, c) => sum + c);

  /// Count for a specific mood (0 if absent).
  int countOf(MoodType mood) => counts[mood] ?? 0;

  /// All moods ordered by count desc (for chart).
  List<MapEntry<MoodType, int>> get sortedEntries {
    final list = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return list;
  }

  @override
  List<Object?> get props => [counts];
}
