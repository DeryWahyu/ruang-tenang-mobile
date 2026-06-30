import '../../core/utils/json_parser.dart';
import '../../domain/entities/community.dart';

/// Data-layer model untuk [CommunityStats]. Mem-parse payload
/// `GET /community/stats` lalu memetakannya ke entity via [toEntity].
class CommunityStatsModel {
  final int totalXpEarned;
  final int activeMembers;
  final int totalAchievements;
  final double growthPercentage;
  final int newMembers;
  final int totalStoriesPublished;
  final int totalArticlesPublished;
  final int month;
  final int year;

  const CommunityStatsModel({
    required this.totalXpEarned,
    required this.activeMembers,
    required this.totalAchievements,
    required this.growthPercentage,
    required this.newMembers,
    required this.totalStoriesPublished,
    required this.totalArticlesPublished,
    required this.month,
    required this.year,
  });

  factory CommunityStatsModel.fromJson(Map<String, dynamic> json) {
    return CommunityStatsModel(
      totalXpEarned: Json.intValue(json['total_xp_earned']),
      activeMembers: Json.intValue(json['active_members']),
      totalAchievements: Json.intValue(json['total_achievements']),
      growthPercentage: Json.doubleValue(json['growth_percentage']),
      newMembers: Json.intValue(json['new_members']),
      totalStoriesPublished: Json.intValue(json['total_stories_published']),
      totalArticlesPublished: Json.intValue(json['total_articles_published']),
      month: Json.intValue(json['month']),
      year: Json.intValue(json['year']),
    );
  }

  CommunityStats toEntity() => CommunityStats(
        totalXpEarned: totalXpEarned,
        activeMembers: activeMembers,
        totalAchievements: totalAchievements,
        growthPercentage: growthPercentage,
        newMembers: newMembers,
        totalStoriesPublished: totalStoriesPublished,
        totalArticlesPublished: totalArticlesPublished,
        month: month,
        year: year,
      );
}
