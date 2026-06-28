import '../../domain/entities/secondary_gamification.dart';

DateTime? _date(dynamic v) {
  if (v == null || v is! String || v.isEmpty) return null;
  try {
    return DateTime.parse(v).toLocal();
  } catch (_) {
    return null;
  }
}

int _int(dynamic v) => (v as num?)?.toInt() ?? 0;
double _double(dynamic v) => (v as num?)?.toDouble() ?? 0.0;
String _str(dynamic v) => v?.toString() ?? '';
bool _bool(dynamic v) => v as bool? ?? false;

// ==========================================
// Guild
// ==========================================
class GuildModel {
  static Guild fromJson(Map<String, dynamic> j) => Guild(
        id: _str(j['id']),
        name: _str(j['name']),
        description: _str(j['description']),
        icon: j['icon'] as String? ?? '🛡️',
        banner: _str(j['banner']),
        leaderId: _int(j['leader_id']),
        leaderName: _str(j['leader_name']),
        maxMembers: _int(j['max_members']),
        memberCount: _int(j['member_count']),
        totalXp: _int(j['total_xp']),
        level: _int(j['level']),
        isPublic: _bool(j['is_public']),
        inviteCode: _str(j['invite_code']),
      );
}

class GuildMemberModel {
  static GuildMember fromJson(Map<String, dynamic> j) => GuildMember(
        userId: _int(j['user_id']),
        username: _str(j['username']),
        name: _str(j['name']),
        avatar: _str(j['avatar']),
        role: _str(j['role']),
        xpContributed: _int(j['xp_contributed']),
        userLevel: _int(j['user_level']),
      );
}

class GuildChallengeModel {
  static GuildChallenge fromJson(Map<String, dynamic> j) => GuildChallenge(
        id: _str(j['id']),
        title: _str(j['title']),
        description: _str(j['description']),
        challengeType: _str(j['challenge_type']),
        targetValue: _int(j['target_value']),
        currentValue: _int(j['current_value']),
        progressPercent: _double(j['progress_percent']),
        xpReward: _int(j['xp_reward']),
        coinReward: _int(j['coin_reward']),
        endsAt: _date(j['ends_at']),
        isCompleted: _bool(j['is_completed']),
        isActive: _bool(j['is_active']),
      );
}

class GuildDetailModel {
  static GuildDetail fromJson(Map<String, dynamic> j) => GuildDetail(
        guild: GuildModel.fromJson(j),
        members: (j['members'] as List<dynamic>?)
                ?.map((e) => GuildMemberModel.fromJson(Map<String, dynamic>.from(e as Map)))
                .toList() ??
            [],
        activeChallenges: (j['active_challenges'] as List<dynamic>?)
                ?.map((e) => GuildChallengeModel.fromJson(Map<String, dynamic>.from(e as Map)))
                .toList() ??
            [],
        isCurrentUserGuild: _bool(j['is_current_user_guild']),
        currentUserRole: _str(j['current_user_role']),
      );
}

class MyGuildModel {
  static MyGuild fromJson(Map<String, dynamic> j) => MyGuild(
        guild: j['guild'] != null ? GuildModel.fromJson(Map<String, dynamic>.from(j['guild'] as Map)) : null,
        memberRole: _str(j['member_role']),
        xpContributed: _int(j['xp_contributed']),
        isMember: _bool(j['is_member']),
      );
}

class GuildLeaderboardEntryModel {
  static GuildLeaderboardEntry fromJson(Map<String, dynamic> j) => GuildLeaderboardEntry(
        id: _str(j['id']),
        name: _str(j['name']),
        icon: j['icon'] as String? ?? '🛡️',
        totalXp: _int(j['total_xp']),
        level: _int(j['level']),
        memberCount: _int(j['member_count']),
        rank: _int(j['rank']),
      );
}

// ==========================================
// Streak Society
// ==========================================
class StreakSocietyModel {
  static StreakSociety fromJson(Map<String, dynamic> j) => StreakSociety(
        id: _int(j['id']),
        name: _str(j['name']),
        icon: j['icon'] as String? ?? '🔥',
        minStreak: _int(j['min_streak']),
        borderColor: _str(j['border_color']),
        badgeGlow: _bool(j['badge_glow']),
        exclusiveChat: _bool(j['exclusive_chat']),
        memberCount: _int(j['member_count']),
        isMember: _bool(j['is_member']),
      );
}

class StreakSocietyOverviewModel {
  static StreakSocietyOverview fromJson(Map<String, dynamic> j) => StreakSocietyOverview(
        currentStreak: _int(j['current_streak']),
        currentSociety: j['current_society'] != null
            ? StreakSocietyModel.fromJson(Map<String, dynamic>.from(j['current_society'] as Map))
            : null,
        allSocieties: (j['all_societies'] as List<dynamic>?)
                ?.map((e) => StreakSocietyModel.fromJson(Map<String, dynamic>.from(e as Map)))
                .toList() ??
            [],
      );
}

// ==========================================
// Timed Challenge
// ==========================================
class TimedChallengeTemplateModel {
  static TimedChallengeTemplate fromJson(Map<String, dynamic> j) => TimedChallengeTemplate(
        id: _int(j['id']),
        title: _str(j['title']),
        description: _str(j['description']),
        challengeType: _str(j['challenge_type']),
        targetValue: _int(j['target_value']),
        durationMinutes: _int(j['duration_minutes']),
        xpReward: _int(j['xp_reward']),
        coinReward: _int(j['coin_reward']),
        icon: j['icon'] as String? ?? '⚡',
      );
}

class UserTimedChallengeModel {
  static UserTimedChallenge fromJson(Map<String, dynamic> j) => UserTimedChallenge(
        id: _str(j['id']),
        template: j['template'] != null
            ? TimedChallengeTemplateModel.fromJson(Map<String, dynamic>.from(j['template'] as Map))
            : const TimedChallengeTemplate(
                id: 0,
                title: '',
                description: '',
                challengeType: '',
                targetValue: 0,
                durationMinutes: 0,
                xpReward: 0,
                coinReward: 0,
                icon: '⚡',
              ),
        currentValue: _int(j['current_value']),
        targetValue: _int(j['target_value']),
        progressPercent: _double(j['progress_percent']),
        status: _str(j['status']),
        expiresAt: _date(j['expires_at']),
        remainingSeconds: _int(j['remaining_seconds']),
      );
}

// ==========================================
// XP Boost / Combo
// ==========================================
class XPBoostModel {
  static XPBoost fromJson(Map<String, dynamic> j) => XPBoost(
        id: _str(j['id']),
        multiplier: _double(j['multiplier']),
        triggerType: _str(j['trigger_type']),
        expiresAt: _date(j['expires_at']),
        remainingSeconds: _int(j['remaining_seconds']),
      );
}

class ComboStatusModel {
  static ComboStatus fromJson(Map<String, dynamic> j) => ComboStatus(
        comboCount: _int(j['combo_count']),
        multiplier: _double(j['multiplier']),
        nextMultiplier: _double(j['next_multiplier']),
        lastActivity: _str(j['last_activity']),
        expiresInSeconds: _int(j['expires_in_seconds']),
      );
}

// ==========================================
// Friend Quest
// ==========================================
class QuestUserModel {
  static QuestUser fromJson(Map<String, dynamic> j) => QuestUser(
        id: _int(j['id']),
        username: _str(j['username']),
        avatar: _str(j['avatar']),
      );
}

class FriendQuestModel {
  static FriendQuest fromJson(Map<String, dynamic> j) => FriendQuest(
        id: _str(j['id']),
        title: _str(j['title']),
        description: _str(j['description']),
        questType: _str(j['quest_type']),
        targetValue: _int(j['target_value']),
        requesterProgress: _int(j['requester_progress']),
        partnerProgress: _int(j['partner_progress']),
        totalProgress: _int(j['total_progress']),
        progressPercent: _double(j['progress_percent']),
        xpReward: _int(j['xp_reward']),
        coinReward: _int(j['coin_reward']),
        status: _str(j['status']),
        requester: j['requester'] != null
            ? QuestUserModel.fromJson(Map<String, dynamic>.from(j['requester'] as Map))
            : const QuestUser(id: 0, username: '', avatar: ''),
        partner: j['partner'] != null
            ? QuestUserModel.fromJson(Map<String, dynamic>.from(j['partner'] as Map))
            : const QuestUser(id: 0, username: '', avatar: ''),
        endsAt: _date(j['ends_at']),
      );
}

// ==========================================
// Weekly League
// ==========================================
class LeagueDivisionModel {
  static LeagueDivision fromJson(Map<String, dynamic> j) => LeagueDivision(
        id: _int(j['id']),
        name: _str(j['name']),
        icon: j['icon'] as String? ?? '🏆',
        tier: _int(j['tier']),
        color: _str(j['color']),
        promotionSlots: _int(j['promotion_slots']),
        demotionSlots: _int(j['demotion_slots']),
      );
}

class LeagueSeasonModel {
  static LeagueSeason fromJson(Map<String, dynamic> j) => LeagueSeason(
        id: _str(j['id']),
        weekNumber: _int(j['week_number']),
        year: _int(j['year']),
        endsAt: _date(j['ends_at']),
        isActive: _bool(j['is_active']),
      );
}

class LeagueParticipantModel {
  static LeagueParticipant fromJson(Map<String, dynamic> j) => LeagueParticipant(
        rank: _int(j['rank']),
        userId: _int(j['user_id']),
        username: _str(j['username']),
        avatar: _str(j['avatar']),
        weeklyXp: _int(j['weekly_xp']),
        isPromoted: _bool(j['is_promoted']),
        isDemoted: _bool(j['is_demoted']),
        isMe: _bool(j['is_me']),
      );
}

class LeagueOverviewModel {
  static LeagueOverview fromJson(Map<String, dynamic> j) => LeagueOverview(
        season: j['season'] != null
            ? LeagueSeasonModel.fromJson(Map<String, dynamic>.from(j['season'] as Map))
            : const LeagueSeason(id: '', weekNumber: 0, year: 0, endsAt: null, isActive: false),
        division: j['division'] != null
            ? LeagueDivisionModel.fromJson(Map<String, dynamic>.from(j['division'] as Map))
            : const LeagueDivision(
                id: 0, name: '', icon: '🏆', tier: 0, color: '', promotionSlots: 0, demotionSlots: 0),
        myRank: _int(j['my_rank']),
        myWeeklyXp: _int(j['my_weekly_xp']),
        leaderboard: (j['leaderboard'] as List<dynamic>?)
                ?.map((e) => LeagueParticipantModel.fromJson(Map<String, dynamic>.from(e as Map)))
                .toList() ??
            [],
        timeLeftSeconds: _int(j['time_left_seconds']),
      );
}
