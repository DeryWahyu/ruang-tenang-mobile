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
// Streak Society
// ==========================================
class StreakSociety extends Equatable {
  final int id;
  final String name;
  final String icon;
  final int minStreak;
  final String borderColor;
  final bool badgeGlow;
  final bool exclusiveChat;
  final int memberCount;
  final bool isMember;

  const StreakSociety({
    required this.id,
    required this.name,
    required this.icon,
    required this.minStreak,
    required this.borderColor,
    required this.badgeGlow,
    required this.exclusiveChat,
    required this.memberCount,
    required this.isMember,
  });

  @override
  List<Object?> get props => [id, name, icon, minStreak, borderColor, badgeGlow, exclusiveChat, memberCount, isMember];
}

class StreakSocietyOverview extends Equatable {
  final int currentStreak;
  final StreakSociety? currentSociety;
  final List<StreakSociety> allSocieties;

  const StreakSocietyOverview({
    required this.currentStreak,
    required this.currentSociety,
    required this.allSocieties,
  });

  @override
  List<Object?> get props => [currentStreak, currentSociety, allSocieties];
}

// ==========================================
// Timed Challenge (Quest Kilat)
// ==========================================
class TimedChallengeTemplate extends Equatable {
  final int id;
  final String title;
  final String description;
  final String challengeType;
  final int targetValue;
  final int durationMinutes;
  final int xpReward;
  final int coinReward;
  final String icon;

  const TimedChallengeTemplate({
    required this.id,
    required this.title,
    required this.description,
    required this.challengeType,
    required this.targetValue,
    required this.durationMinutes,
    required this.xpReward,
    required this.coinReward,
    required this.icon,
  });

  @override
  List<Object?> get props =>
      [id, title, description, challengeType, targetValue, durationMinutes, xpReward, coinReward, icon];
}

class UserTimedChallenge extends Equatable {
  final String id;
  final TimedChallengeTemplate template;
  final int currentValue;
  final int targetValue;
  final double progressPercent;
  final String status;
  final DateTime? expiresAt;
  final int remainingSeconds;

  const UserTimedChallenge({
    required this.id,
    required this.template,
    required this.currentValue,
    required this.targetValue,
    required this.progressPercent,
    required this.status,
    required this.expiresAt,
    required this.remainingSeconds,
  });

  @override
  List<Object?> get props =>
      [id, template, currentValue, targetValue, progressPercent, status, expiresAt, remainingSeconds];
}

/// Aggregate for the Timed Challenge screen.
class TimedChallengeData extends Equatable {
  final UserTimedChallenge? active;
  final List<TimedChallengeTemplate> templates;

  const TimedChallengeData({required this.active, required this.templates});

  @override
  List<Object?> get props => [active, templates];
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

// ==========================================
// Friend Quest
// ==========================================
class QuestUser extends Equatable {
  final int id;
  final String username;
  final String avatar;

  const QuestUser({required this.id, required this.username, required this.avatar});

  @override
  List<Object?> get props => [id, username, avatar];
}

class FriendQuest extends Equatable {
  final String id;
  final String title;
  final String description;
  final String questType;
  final int targetValue;
  final int requesterProgress;
  final int partnerProgress;
  final int totalProgress;
  final double progressPercent;
  final int xpReward;
  final int coinReward;
  final String status;
  final QuestUser requester;
  final QuestUser partner;
  final DateTime? endsAt;

  const FriendQuest({
    required this.id,
    required this.title,
    required this.description,
    required this.questType,
    required this.targetValue,
    required this.requesterProgress,
    required this.partnerProgress,
    required this.totalProgress,
    required this.progressPercent,
    required this.xpReward,
    required this.coinReward,
    required this.status,
    required this.requester,
    required this.partner,
    required this.endsAt,
  });

  @override
  List<Object?> get props => [
        id, title, description, questType, targetValue, requesterProgress, partnerProgress,
        totalProgress, progressPercent, xpReward, coinReward, status, requester, partner, endsAt,
      ];
}

// ==========================================
// Weekly League
// ==========================================
class LeagueDivision extends Equatable {
  final int id;
  final String name;
  final String icon;
  final int tier;
  final String color;
  final int promotionSlots;
  final int demotionSlots;

  const LeagueDivision({
    required this.id,
    required this.name,
    required this.icon,
    required this.tier,
    required this.color,
    required this.promotionSlots,
    required this.demotionSlots,
  });

  @override
  List<Object?> get props => [id, name, icon, tier, color, promotionSlots, demotionSlots];
}

class LeagueSeason extends Equatable {
  final String id;
  final int weekNumber;
  final int year;
  final DateTime? endsAt;
  final bool isActive;

  const LeagueSeason({
    required this.id,
    required this.weekNumber,
    required this.year,
    required this.endsAt,
    required this.isActive,
  });

  @override
  List<Object?> get props => [id, weekNumber, year, endsAt, isActive];
}

class LeagueParticipant extends Equatable {
  final int rank;
  final int userId;
  final String username;
  final String avatar;
  final int weeklyXp;
  final bool isPromoted;
  final bool isDemoted;
  final bool isMe;

  const LeagueParticipant({
    required this.rank,
    required this.userId,
    required this.username,
    required this.avatar,
    required this.weeklyXp,
    required this.isPromoted,
    required this.isDemoted,
    required this.isMe,
  });

  @override
  List<Object?> get props => [rank, userId, username, avatar, weeklyXp, isPromoted, isDemoted, isMe];
}

class LeagueOverview extends Equatable {
  final LeagueSeason season;
  final LeagueDivision division;
  final int myRank;
  final int myWeeklyXp;
  final List<LeagueParticipant> leaderboard;
  final int timeLeftSeconds;

  const LeagueOverview({
    required this.season,
    required this.division,
    required this.myRank,
    required this.myWeeklyXp,
    required this.leaderboard,
    required this.timeLeftSeconds,
  });

  @override
  List<Object?> get props => [season, division, myRank, myWeeklyXp, leaderboard, timeLeftSeconds];
}
