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

class MysteryChest extends Equatable {
  final String id;
  final String rarity;
  final String rarityIcon;
  final bool isOpened;
  final String rewardType;
  final int rewardValue;
  final String rewardLabel;
  final DateTime createdAt;

  const MysteryChest({
    required this.id,
    required this.rarity,
    required this.rarityIcon,
    required this.isOpened,
    this.rewardType = '',
    this.rewardValue = 0,
    this.rewardLabel = '',
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, rarity, rarityIcon, isOpened, rewardType, rewardValue, rewardLabel, createdAt];
}

class DailySpinSlot extends Equatable {
  final int id;
  final String name;
  final String icon;
  final String rewardType;
  final int rewardValue;
  final String rarity;

  const DailySpinSlot({
    required this.id,
    required this.name,
    required this.icon,
    required this.rewardType,
    required this.rewardValue,
    required this.rarity,
  });

  @override
  List<Object?> get props => [id, name, icon, rewardType, rewardValue, rarity];
}

class DailySpinWheel extends Equatable {
  final List<DailySpinSlot> slots;
  final bool hasSpunToday;

  const DailySpinWheel({
    required this.slots,
    required this.hasSpunToday,
  });

  @override
  List<Object?> get props => [slots, hasSpunToday];
}