import 'package:equatable/equatable.dart';

// ==========================================
// Guild
// ==========================================
class Guild extends Equatable {
  final String id;
  final String name;
  final String description;
  final String icon;
  final String banner;
  final int leaderId;
  final String leaderName;
  final int maxMembers;
  final int memberCount;
  final int totalXp;
  final int level;
  final bool isPublic;
  final String inviteCode;

  const Guild({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.banner,
    required this.leaderId,
    required this.leaderName,
    required this.maxMembers,
    required this.memberCount,
    required this.totalXp,
    required this.level,
    required this.isPublic,
    required this.inviteCode,
  });

  @override
  List<Object?> get props =>
      [id, name, description, icon, banner, leaderId, leaderName, maxMembers, memberCount, totalXp, level, isPublic, inviteCode];
}

class GuildMember extends Equatable {
  final int userId;
  final String username;
  final String name;
  final String avatar;
  final String role;
  final int xpContributed;
  final int userLevel;

  const GuildMember({
    required this.userId,
    required this.username,
    required this.name,
    required this.avatar,
    required this.role,
    required this.xpContributed,
    required this.userLevel,
  });

  @override
  List<Object?> get props => [userId, username, name, avatar, role, xpContributed, userLevel];
}

class GuildChallenge extends Equatable {
  final String id;
  final String title;
  final String description;
  final String challengeType;
  final int targetValue;
  final int currentValue;
  final double progressPercent;
  final int xpReward;
  final int coinReward;
  final DateTime? endsAt;
  final bool isCompleted;
  final bool isActive;

  const GuildChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.challengeType,
    required this.targetValue,
    required this.currentValue,
    required this.progressPercent,
    required this.xpReward,
    required this.coinReward,
    required this.endsAt,
    required this.isCompleted,
    required this.isActive,
  });

  @override
  List<Object?> get props =>
      [id, title, description, challengeType, targetValue, currentValue, progressPercent, xpReward, coinReward, endsAt, isCompleted, isActive];
}

class GuildDetail extends Equatable {
  final Guild guild;
  final List<GuildMember> members;
  final List<GuildChallenge> activeChallenges;
  final bool isCurrentUserGuild;
  final String currentUserRole;

  const GuildDetail({
    required this.guild,
    required this.members,
    required this.activeChallenges,
    required this.isCurrentUserGuild,
    required this.currentUserRole,
  });

  @override
  List<Object?> get props => [guild, members, activeChallenges, isCurrentUserGuild, currentUserRole];
}

class MyGuild extends Equatable {
  final Guild? guild;
  final String memberRole;
  final int xpContributed;
  final bool isMember;

  const MyGuild({
    required this.guild,
    required this.memberRole,
    required this.xpContributed,
    required this.isMember,
  });

  @override
  List<Object?> get props => [guild, memberRole, xpContributed, isMember];
}

class GuildLeaderboardEntry extends Equatable {
  final String id;
  final String name;
  final String icon;
  final int totalXp;
  final int level;
  final int memberCount;
  final int rank;

  const GuildLeaderboardEntry({
    required this.id,
    required this.name,
    required this.icon,
    required this.totalXp,
    required this.level,
    required this.memberCount,
    required this.rank,
  });

  @override
  List<Object?> get props => [id, name, icon, totalXp, level, memberCount, rank];
}

/// Aggregate data for the Guild hub screen.
class GuildHubData extends Equatable {
  final MyGuild myGuild;
  final GuildDetail? detail;
  final List<GuildLeaderboardEntry> leaderboard;
  final List<Guild> publicGuilds;

  const GuildHubData({
    required this.myGuild,
    required this.detail,
    required this.leaderboard,
    required this.publicGuilds,
  });

  @override
  List<Object?> get props => [myGuild, detail, leaderboard, publicGuilds];
}

// ==========================================
// XP Boost / Combo
// ==========================================
class XPBoost extends Equatable {
  final String id;
  final double multiplier;
  final String triggerType;
  final DateTime? expiresAt;
  final int remainingSeconds;

  const XPBoost({
    required this.id,
    required this.multiplier,
    required this.triggerType,
    required this.expiresAt,
    required this.remainingSeconds,
  });

  @override
  List<Object?> get props => [id, multiplier, triggerType, expiresAt, remainingSeconds];
}

class ComboStatus extends Equatable {
  final int comboCount;
  final double multiplier;
  final double nextMultiplier;
  final String lastActivity;
  final int expiresInSeconds;

  const ComboStatus({
    required this.comboCount,
    required this.multiplier,
    required this.nextMultiplier,
    required this.lastActivity,
    required this.expiresInSeconds,
  });

  @override
  List<Object?> get props => [comboCount, multiplier, nextMultiplier, lastActivity, expiresInSeconds];
}

/// Aggregate for the XP Boost & Combo screen.
class XpBoostData extends Equatable {
  final XPBoost? boost;
  final ComboStatus combo;
  final double effectiveMultiplier;

  const XpBoostData({required this.boost, required this.combo, required this.effectiveMultiplier});

  @override
  List<Object?> get props => [boost, combo, effectiveMultiplier];
}
