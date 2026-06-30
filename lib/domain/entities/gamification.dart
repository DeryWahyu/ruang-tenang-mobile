import 'package:equatable/equatable.dart';

class LevelConfig extends Equatable {
  final int level;
  final int minExp;
  final String badgeName;
  final String badgeIcon;
  final String taskDescription;

  const LevelConfig({
    required this.level,
    required this.minExp,
    required this.badgeName,
    required this.badgeIcon,
    required this.taskDescription,
  });

  @override
  List<Object?> get props => [level, minExp, badgeName, badgeIcon, taskDescription];
}

class UserLevelInfo extends Equatable {
  final int level;
  final String badgeName;
  final String badgeIcon;
  final int currentExp;

  const UserLevelInfo({
    required this.level,
    required this.badgeName,
    required this.badgeIcon,
    required this.currentExp,
  });

  @override
  List<Object?> get props => [level, badgeName, badgeIcon, currentExp];
}

class ExpHistory extends Equatable {
  final int id;
  final String activityType;
  final int points;
  final String description;
  final DateTime createdAt;

  const ExpHistory({
    required this.id,
    required this.activityType,
    required this.points,
    required this.description,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, activityType, points, description, createdAt];
}

class BadgeProgress extends Equatable {
  final String badgeId;
  final String badgeKey;
  final String badgeName;
  final String description;
  final String icon;
  final String category;
  final bool earned;
  final int currentValue;
  final int targetValue;
  final double progressPercent;

  const BadgeProgress({
    required this.badgeId,
    required this.badgeKey,
    required this.badgeName,
    required this.description,
    required this.icon,
    required this.category,
    required this.earned,
    required this.currentValue,
    required this.targetValue,
    required this.progressPercent,
  });

  @override
  List<Object?> get props => [
    badgeId, badgeKey, badgeName, description, icon, category, 
    earned, currentValue, targetValue, progressPercent
  ];
}


// ==========================================
// Personal Journey (/community/my-journey)
// ==========================================
class PersonalJourney extends Equatable {
  final int userId;
  final int currentLevel;
  final int currentExp;
  final int expToNextLevel;
  final double progressPercent;
  final String tierName;
  final String tierColor;
  final String badgeName;
  final String badgeIcon;
  final int monthlyXp;
  final int monthlyActivities;
  final int newBadgesCount;
  final int rankInLevel;
  final int totalInLevel;
  final double percentile;
  final int currentStreak;
  final int longestStreak;
  final int totalActivities;

  const PersonalJourney({
    required this.userId,
    required this.currentLevel,
    required this.currentExp,
    required this.expToNextLevel,
    required this.progressPercent,
    required this.tierName,
    required this.tierColor,
    required this.badgeName,
    required this.badgeIcon,
    required this.monthlyXp,
    required this.monthlyActivities,
    required this.newBadgesCount,
    required this.rankInLevel,
    required this.totalInLevel,
    required this.percentile,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalActivities,
  });

  @override
  List<Object?> get props => [
        userId, currentLevel, currentExp, expToNextLevel, progressPercent,
        tierName, tierColor, badgeName, badgeIcon, monthlyXp, monthlyActivities,
        newBadgesCount, rankInLevel, totalInLevel, percentile, currentStreak,
        longestStreak, totalActivities,
      ];
}

// ==========================================
// Daily Tasks (/daily-tasks)
// ==========================================
class DailyTask extends Equatable {
  final int id;
  final String taskType;
  final String taskName;
  final String taskDescription;
  final String taskIcon;
  final bool premiumOnly;
  final int xpReward;
  final int coinReward;
  final int targetCount;
  final int currentCount;
  final bool isCompleted;
  final bool isClaimed;

  const DailyTask({
    required this.id,
    required this.taskType,
    required this.taskName,
    required this.taskDescription,
    required this.taskIcon,
    required this.premiumOnly,
    required this.xpReward,
    required this.coinReward,
    required this.targetCount,
    required this.currentCount,
    required this.isCompleted,
    required this.isClaimed,
  });

  double get progress => targetCount == 0 ? 0 : (currentCount / targetCount).clamp(0.0, 1.0);
  bool get isClaimable => isCompleted && !isClaimed;

  @override
  List<Object?> get props => [
        id, taskType, taskName, taskDescription, taskIcon, premiumOnly,
        xpReward, coinReward, targetCount, currentCount, isCompleted, isClaimed,
      ];
}

class DailyTaskSummary extends Equatable {
  final int totalTasks;
  final int completedTasks;
  final int claimedTasks;
  final int totalXpEarned;
  final int totalXpPossible;
  final int totalCoinsEarned;
  final int totalCoinsPossible;
  final int loginStreak;
  final List<DailyTask> tasks;

  const DailyTaskSummary({
    required this.totalTasks,
    required this.completedTasks,
    required this.claimedTasks,
    required this.totalXpEarned,
    required this.totalXpPossible,
    required this.totalCoinsEarned,
    required this.totalCoinsPossible,
    required this.loginStreak,
    required this.tasks,
  });

  int get claimableCount => tasks.where((t) => t.isClaimable).length;

  @override
  List<Object?> get props => [
        totalTasks, completedTasks, claimedTasks, totalXpEarned, totalXpPossible,
        totalCoinsEarned, totalCoinsPossible, loginStreak, tasks,
      ];
}

// ==========================================
// Progress Map (/map)
// ==========================================
class MapLandmark extends Equatable {
  final String id;
  final String landmarkKey;
  final String name;
  final String description;
  final String icon;
  final int xpReward;
  final int coinReward;
  final bool isUnlocked;
  final int currentValue;
  final int unlockValue;
  final double progressPercent;
  final bool rewardClaimed;

  const MapLandmark({
    required this.id,
    required this.landmarkKey,
    required this.name,
    required this.description,
    required this.icon,
    required this.xpReward,
    required this.coinReward,
    required this.isUnlocked,
    required this.currentValue,
    required this.unlockValue,
    required this.progressPercent,
    required this.rewardClaimed,
  });

  bool get canClaim => isUnlocked && !rewardClaimed;

  @override
  List<Object?> get props => [
        id, landmarkKey, name, description, icon, xpReward, coinReward,
        isUnlocked, currentValue, unlockValue, progressPercent, rewardClaimed,
      ];
}

class MapRegion extends Equatable {
  final String id;
  final String regionKey;
  final String name;
  final String description;
  final String icon;
  final bool isUnlocked;
  final int totalLandmarks;
  final int unlockedLandmarks;
  final List<MapLandmark> landmarks;

  const MapRegion({
    required this.id,
    required this.regionKey,
    required this.name,
    required this.description,
    required this.icon,
    required this.isUnlocked,
    required this.totalLandmarks,
    required this.unlockedLandmarks,
    required this.landmarks,
  });

  @override
  List<Object?> get props => [
        id, regionKey, name, description, icon, isUnlocked,
        totalLandmarks, unlockedLandmarks, landmarks,
      ];
}

class ProgressMap extends Equatable {
  final List<MapRegion> regions;
  final int totalRegions;
  final int unlockedRegions;
  final int totalLandmarks;
  final int unlockedLandmarks;
  final double overallProgress;

  const ProgressMap({
    required this.regions,
    required this.totalRegions,
    required this.unlockedRegions,
    required this.totalLandmarks,
    required this.unlockedLandmarks,
    required this.overallProgress,
  });

  @override
  List<Object?> get props => [
        regions, totalRegions, unlockedRegions, totalLandmarks,
        unlockedLandmarks, overallProgress,
      ];
}

// ==========================================
// Hall of Fame / Leaderboard (/community/hall-of-fame)
// ==========================================
class HallOfFameEntry extends Equatable {
  final int rank;
  final int userId;
  final String userName;
  final String avatar;
  final int monthlyXp;
  final String message;
  final String tierName;
  final String tierColor;

  const HallOfFameEntry({
    required this.rank,
    required this.userId,
    required this.userName,
    required this.avatar,
    required this.monthlyXp,
    required this.message,
    required this.tierName,
    required this.tierColor,
  });

  @override
  List<Object?> get props => [rank, userId, userName, avatar, monthlyXp, message, tierName, tierColor];
}

// ==========================================
// Rewards Shop (/rewards)
// ==========================================
class Reward extends Equatable {
  final int id;
  final String name;
  final String description;
  final String image;
  final int coinCost;
  final int stock;
  final bool isActive;
  final String rewardType;
  final String rewardValue;

  const Reward({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.coinCost,
    required this.stock,
    required this.isActive,
    required this.rewardType,
    required this.rewardValue,
  });

  bool get isAvailable => isActive && (stock == -1 || stock > 0);

  @override
  List<Object?> get props => [id, name, description, image, coinCost, stock, isActive, rewardType, rewardValue];
}
