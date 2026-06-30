import '../../domain/entities/secondary_gamification.dart';
import '../../core/utils/json_parser.dart';


// ==========================================
// Guild
// ==========================================
class GuildModel {
  static Guild fromJson(Map<String, dynamic> j) => Guild(
        id: Json.string(j['id']),
        name: Json.string(j['name']),
        description: Json.string(j['description']),
        icon: j['icon'] as String? ?? 'shield',
        banner: Json.string(j['banner']),
        leaderId: Json.intValue(j['leader_id']),
        leaderName: Json.string(j['leader_name']),
        maxMembers: Json.intValue(j['max_members']),
        memberCount: Json.intValue(j['member_count']),
        totalXp: Json.intValue(j['total_xp']),
        level: Json.intValue(j['level']),
        isPublic: Json.boolValue(j['is_public']),
        inviteCode: Json.string(j['invite_code']),
      );
}

class GuildMemberModel {
  static GuildMember fromJson(Map<String, dynamic> j) => GuildMember(
        userId: Json.intValue(j['user_id']),
        username: Json.string(j['username']),
        name: Json.string(j['name']),
        avatar: Json.string(j['avatar']),
        role: Json.string(j['role']),
        xpContributed: Json.intValue(j['xp_contributed']),
        userLevel: Json.intValue(j['user_level']),
      );
}

class GuildChallengeModel {
  static GuildChallenge fromJson(Map<String, dynamic> j) => GuildChallenge(
        id: Json.string(j['id']),
        title: Json.string(j['title']),
        description: Json.string(j['description']),
        challengeType: Json.string(j['challenge_type']),
        targetValue: Json.intValue(j['target_value']),
        currentValue: Json.intValue(j['current_value']),
        progressPercent: Json.doubleValue(j['progress_percent']),
        xpReward: Json.intValue(j['xp_reward']),
        coinReward: Json.intValue(j['coin_reward']),
        endsAt: Json.date(j['ends_at']),
        isCompleted: Json.boolValue(j['is_completed']),
        isActive: Json.boolValue(j['is_active']),
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
        isCurrentUserGuild: Json.boolValue(j['is_current_user_guild']),
        currentUserRole: Json.string(j['current_user_role']),
      );
}

class MyGuildModel {
  static MyGuild fromJson(Map<String, dynamic> j) => MyGuild(
        guild: j['guild'] != null ? GuildModel.fromJson(Map<String, dynamic>.from(j['guild'] as Map)) : null,
        memberRole: Json.string(j['member_role']),
        xpContributed: Json.intValue(j['xp_contributed']),
        isMember: Json.boolValue(j['is_member']),
      );
}

class GuildLeaderboardEntryModel {
  static GuildLeaderboardEntry fromJson(Map<String, dynamic> j) => GuildLeaderboardEntry(
        id: Json.string(j['id']),
        name: Json.string(j['name']),
        icon: j['icon'] as String? ?? 'shield',
        totalXp: Json.intValue(j['total_xp']),
        level: Json.intValue(j['level']),
        memberCount: Json.intValue(j['member_count']),
        rank: Json.intValue(j['rank']),
      );
}

// ==========================================
// XP Boost / Combo
// ==========================================
class XPBoostModel {
  static XPBoost fromJson(Map<String, dynamic> j) => XPBoost(
        id: Json.string(j['id']),
        multiplier: Json.doubleValue(j['multiplier']),
        triggerType: Json.string(j['trigger_type']),
        expiresAt: Json.date(j['expires_at']),
        remainingSeconds: Json.intValue(j['remaining_seconds']),
      );
}

class ComboStatusModel {
  static ComboStatus fromJson(Map<String, dynamic> j) => ComboStatus(
        comboCount: Json.intValue(j['combo_count']),
        multiplier: Json.doubleValue(j['multiplier']),
        nextMultiplier: Json.doubleValue(j['next_multiplier']),
        lastActivity: Json.string(j['last_activity']),
        expiresInSeconds: Json.intValue(j['expires_in_seconds']),
      );
}
