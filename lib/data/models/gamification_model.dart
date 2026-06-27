import 'package:equatable/equatable.dart';
import '../../domain/entities/gamification.dart';

class UserLevelInfoModel extends Equatable {
  final int level;
  final String badgeName;
  final String badgeIcon;
  final int currentExp;

  const UserLevelInfoModel({
    required this.level,
    required this.badgeName,
    required this.badgeIcon,
    required this.currentExp,
  });

  factory UserLevelInfoModel.fromJson(Map<String, dynamic> json) {
    return UserLevelInfoModel(
      level: (json['level'] as num?)?.toInt() ?? 0,
      badgeName: json['badge_name'] as String? ?? '',
      badgeIcon: json['badge_icon'] as String? ?? '',
      currentExp: (json['current_exp'] as num?)?.toInt() ?? 0,
    );
  }

  UserLevelInfo toEntity() => UserLevelInfo(
        level: level,
        badgeName: badgeName,
        badgeIcon: badgeIcon,
        currentExp: currentExp,
      );

  @override
  List<Object?> get props => [level, badgeName, badgeIcon, currentExp];
}

class ExpHistoryModel extends Equatable {
  final int id;
  final String activityType;
  final int points;
  final String description;
  final DateTime createdAt;

  const ExpHistoryModel({
    required this.id,
    required this.activityType,
    required this.points,
    required this.description,
    required this.createdAt,
  });

  factory ExpHistoryModel.fromJson(Map<String, dynamic> json) {
    return ExpHistoryModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      activityType: json['activity_type'] as String? ?? '',
      points: (json['points'] as num?)?.toInt() ?? 0,
      description: json['description'] as String? ?? '',
      createdAt: _parseDate(json['created_at']) ?? DateTime.now(),
    );
  }

  ExpHistory toEntity() => ExpHistory(
        id: id,
        activityType: activityType,
        points: points,
        description: description,
        createdAt: createdAt,
      );

  @override
  List<Object?> get props => [id, activityType, points, description, createdAt];
}

class BadgeProgressModel extends Equatable {
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

  const BadgeProgressModel({
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

  factory BadgeProgressModel.fromJson(Map<String, dynamic> json) {
    return BadgeProgressModel(
      badgeId: json['badge_id'] as String? ?? '',
      badgeKey: json['badge_key'] as String? ?? '',
      badgeName: json['badge_name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      icon: json['icon'] as String? ?? '',
      category: json['category'] as String? ?? '',
      earned: json['earned'] as bool? ?? false,
      currentValue: (json['current_value'] as num?)?.toInt() ?? 0,
      targetValue: (json['target_value'] as num?)?.toInt() ?? 0,
      progressPercent: (json['progress_percent'] as num?)?.toDouble() ?? 0.0,
    );
  }

  BadgeProgress toEntity() => BadgeProgress(
        badgeId: badgeId,
        badgeKey: badgeKey,
        badgeName: badgeName,
        description: description,
        icon: icon,
        category: category,
        earned: earned,
        currentValue: currentValue,
        targetValue: targetValue,
        progressPercent: progressPercent,
      );

  @override
  List<Object?> get props => [
        badgeId, badgeKey, badgeName, description, icon, category,
        earned, currentValue, targetValue, progressPercent,
      ];
}

class MysteryChestModel extends Equatable {
  final String id;
  final String rarity;
  final String rarityIcon;
  final bool isOpened;
  final String rewardType;
  final int rewardValue;
  final String rewardLabel;
  final DateTime createdAt;

  const MysteryChestModel({
    required this.id,
    required this.rarity,
    required this.rarityIcon,
    required this.isOpened,
    this.rewardType = '',
    this.rewardValue = 0,
    this.rewardLabel = '',
    required this.createdAt,
  });

  factory MysteryChestModel.fromJson(Map<String, dynamic> json) {
    return MysteryChestModel(
      id: json['id'] as String? ?? '',
      rarity: json['rarity'] as String? ?? '',
      rarityIcon: json['rarity_icon'] as String? ?? '',
      isOpened: json['is_opened'] as bool? ?? false,
      rewardType: json['reward_type'] as String? ?? '',
      rewardValue: (json['reward_value'] as num?)?.toInt() ?? 0,
      rewardLabel: json['reward_label'] as String? ?? '',
      createdAt: _parseDate(json['created_at']) ?? DateTime.now(),
    );
  }

  MysteryChest toEntity() => MysteryChest(
        id: id,
        rarity: rarity,
        rarityIcon: rarityIcon,
        isOpened: isOpened,
        rewardType: rewardType,
        rewardValue: rewardValue,
        rewardLabel: rewardLabel,
        createdAt: createdAt,
      );

  @override
  List<Object?> get props => [id, rarity, rarityIcon, isOpened, rewardType, rewardValue, rewardLabel, createdAt];
}

class DailySpinSlotModel extends Equatable {
  final int id;
  final String name;
  final String icon;
  final String rewardType;
  final int rewardValue;
  final String rarity;

  const DailySpinSlotModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.rewardType,
    required this.rewardValue,
    required this.rarity,
  });

  factory DailySpinSlotModel.fromJson(Map<String, dynamic> json) {
    return DailySpinSlotModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      icon: json['icon'] as String? ?? '',
      rewardType: json['reward_type'] as String? ?? '',
      rewardValue: (json['reward_value'] as num?)?.toInt() ?? 0,
      rarity: json['rarity'] as String? ?? '',
    );
  }

  DailySpinSlot toEntity() => DailySpinSlot(
        id: id,
        name: name,
        icon: icon,
        rewardType: rewardType,
        rewardValue: rewardValue,
        rarity: rarity,
      );

  @override
  List<Object?> get props => [id, name, icon, rewardType, rewardValue, rarity];
}

class DailySpinWheelModel extends Equatable {
  final List<DailySpinSlotModel> slots;
  final bool hasSpunToday;

  const DailySpinWheelModel({
    required this.slots,
    required this.hasSpunToday,
  });

  factory DailySpinWheelModel.fromJson(Map<String, dynamic> json) {
    return DailySpinWheelModel(
      slots: (json['slots'] as List<dynamic>?)
              ?.map((e) => DailySpinSlotModel.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
      hasSpunToday: json['has_spun_today'] as bool? ?? false,
    );
  }

  DailySpinWheel toEntity() => DailySpinWheel(
        slots: slots.map((e) => e.toEntity()).toList(),
        hasSpunToday: hasSpunToday,
      );

  @override
  List<Object?> get props => [slots, hasSpunToday];
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