import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/secondary_gamification.dart';
import '../../../domain/repositories/secondary_gamification_repository.dart';
import 'view_state.dart';

String _err(Object e, String fallback) {
  final s = e.toString().replaceFirst('Exception: ', '');
  return s.isEmpty ? fallback : s;
}

// ==========================================
// Guild
// ==========================================
class GuildCubit extends Cubit<ViewState<GuildHubData>> {
  final SecondaryGamificationRepository _repo;
  GuildCubit(this._repo) : super(const ViewState.initial());

  Future<void> load() async {
    emit(state.copyWith(status: ViewStatus.loading, clearMessages: true));
    try {
      final myGuild = await _repo.getMyGuild();
      GuildDetail? detail;
      if (myGuild.isMember && myGuild.guild != null) {
        try {
          detail = await _repo.getGuildDetail(myGuild.guild!.id);
        } catch (_) {}
      }
      List<GuildLeaderboardEntry> leaderboard = [];
      try {
        leaderboard = await _repo.getGuildLeaderboard(limit: 20);
      } catch (_) {}
      List<Guild> publicGuilds = [];
      if (!myGuild.isMember) {
        try {
          publicGuilds = await _repo.getPublicGuilds(limit: 20);
        } catch (_) {}
      }
      emit(state.copyWith(
        status: ViewStatus.success,
        data: GuildHubData(
          myGuild: myGuild,
          detail: detail,
          leaderboard: leaderboard,
          publicGuilds: publicGuilds,
        ),
      ));
    } catch (e) {
      emit(state.copyWith(status: ViewStatus.failure, error: _err(e, 'Gagal memuat guild')));
    }
  }

  Future<void> createGuild({required String name, required String description, required String icon, required bool isPublic}) async {
    emit(state.copyWith(submitting: true, clearMessages: true));
    try {
      await _repo.createGuild(name: name, description: description, icon: icon, isPublic: isPublic);
      emit(state.copyWith(submitting: false, actionMessage: 'Guild berhasil dibuat!'));
      await load();
    } catch (e) {
      emit(state.copyWith(submitting: false, status: ViewStatus.failure, error: _err(e, 'Gagal membuat guild')));
    }
  }

  Future<void> joinGuild(String guildId) async {
    emit(state.copyWith(submitting: true, clearMessages: true));
    try {
      await _repo.joinGuild(guildId);
      emit(state.copyWith(submitting: false, actionMessage: 'Berhasil bergabung ke guild!'));
      await load();
    } catch (e) {
      emit(state.copyWith(submitting: false, status: ViewStatus.failure, error: _err(e, 'Gagal bergabung')));
    }
  }

  Future<void> joinByCode(String code) async {
    emit(state.copyWith(submitting: true, clearMessages: true));
    try {
      await _repo.joinGuildByCode(code);
      emit(state.copyWith(submitting: false, actionMessage: 'Berhasil bergabung ke guild!'));
      await load();
    } catch (e) {
      emit(state.copyWith(submitting: false, status: ViewStatus.failure, error: _err(e, 'Kode tidak valid')));
    }
  }

  Future<void> leaveGuild(String guildId) async {
    emit(state.copyWith(submitting: true, clearMessages: true));
    try {
      await _repo.leaveGuild(guildId);
      emit(state.copyWith(submitting: false, actionMessage: 'Kamu telah meninggalkan guild'));
      await load();
    } catch (e) {
      emit(state.copyWith(submitting: false, status: ViewStatus.failure, error: _err(e, 'Gagal meninggalkan guild')));
    }
  }
}

// ==========================================
// Streak Society
// ==========================================
class StreakSocietyCubit extends Cubit<ViewState<StreakSocietyOverview>> {
  final SecondaryGamificationRepository _repo;
  StreakSocietyCubit(this._repo) : super(const ViewState.initial());

  Future<void> load() async {
    emit(state.copyWith(status: ViewStatus.loading, clearMessages: true));
    try {
      final overview = await _repo.getStreakSocietyOverview();
      emit(state.copyWith(status: ViewStatus.success, data: overview));
    } catch (e) {
      emit(state.copyWith(status: ViewStatus.failure, error: _err(e, 'Gagal memuat streak society')));
    }
  }

  Future<void> join() async {
    emit(state.copyWith(submitting: true, clearMessages: true));
    try {
      final msg = await _repo.joinStreakSociety();
      emit(state.copyWith(submitting: false, actionMessage: msg));
      await load();
    } catch (e) {
      emit(state.copyWith(submitting: false, status: ViewStatus.failure, error: _err(e, 'Gagal bergabung')));
    }
  }
}

// ==========================================
// Timed Challenge
// ==========================================
class TimedChallengeCubit extends Cubit<ViewState<TimedChallengeData>> {
  final SecondaryGamificationRepository _repo;
  TimedChallengeCubit(this._repo) : super(const ViewState.initial());

  Future<void> load() async {
    emit(state.copyWith(status: ViewStatus.loading, clearMessages: true));
    try {
      final templates = await _repo.getTimedChallengeTemplates();
      final active = await _repo.getActiveTimedChallenge();
      emit(state.copyWith(
        status: ViewStatus.success,
        data: TimedChallengeData(active: active, templates: templates),
      ));
    } catch (e) {
      emit(state.copyWith(status: ViewStatus.failure, error: _err(e, 'Gagal memuat challenge')));
    }
  }

  Future<void> start(int templateId) async {
    emit(state.copyWith(submitting: true, clearMessages: true));
    try {
      await _repo.startTimedChallenge(templateId);
      emit(state.copyWith(submitting: false, actionMessage: 'Challenge dimulai! ⚡'));
      await load();
    } catch (e) {
      emit(state.copyWith(submitting: false, status: ViewStatus.failure, error: _err(e, 'Gagal memulai challenge')));
    }
  }

  Future<void> complete(String challengeId) async {
    emit(state.copyWith(submitting: true, clearMessages: true));
    try {
      await _repo.completeTimedChallenge(challengeId);
      emit(state.copyWith(submitting: false, actionMessage: 'Challenge selesai! 🎉'));
      await load();
    } catch (e) {
      emit(state.copyWith(submitting: false, status: ViewStatus.failure, error: _err(e, 'Gagal menyelesaikan challenge')));
    }
  }
}

// ==========================================
// XP Boost / Combo
// ==========================================
class XpBoostCubit extends Cubit<ViewState<XpBoostData>> {
  final SecondaryGamificationRepository _repo;
  XpBoostCubit(this._repo) : super(const ViewState.initial());

  Future<void> load() async {
    emit(state.copyWith(status: ViewStatus.loading, clearMessages: true));
    try {
      final boost = await _repo.getActiveBoost();
      final combo = await _repo.getComboStatus();
      final multiplier = await _repo.getEffectiveMultiplier();
      emit(state.copyWith(
        status: ViewStatus.success,
        data: XpBoostData(boost: boost, combo: combo, effectiveMultiplier: multiplier),
      ));
    } catch (e) {
      emit(state.copyWith(status: ViewStatus.failure, error: _err(e, 'Gagal memuat XP boost')));
    }
  }
}

// ==========================================
// Friend Quest
// ==========================================
class FriendQuestCubit extends Cubit<ViewState<List<FriendQuest>>> {
  final SecondaryGamificationRepository _repo;
  FriendQuestCubit(this._repo) : super(const ViewState.initial());

  Future<void> load() async {
    emit(state.copyWith(status: ViewStatus.loading, clearMessages: true));
    try {
      final quests = await _repo.getMyFriendQuests(limit: 50);
      emit(state.copyWith(status: ViewStatus.success, data: quests));
    } catch (e) {
      emit(state.copyWith(status: ViewStatus.failure, error: _err(e, 'Gagal memuat friend quest')));
    }
  }

  Future<void> accept(String questId) async {
    emit(state.copyWith(submitting: true, clearMessages: true));
    try {
      await _repo.acceptFriendQuest(questId);
      emit(state.copyWith(submitting: false, actionMessage: 'Quest diterima!'));
      await load();
    } catch (e) {
      emit(state.copyWith(submitting: false, status: ViewStatus.failure, error: _err(e, 'Gagal menerima quest')));
    }
  }

  Future<void> decline(String questId) async {
    emit(state.copyWith(submitting: true, clearMessages: true));
    try {
      await _repo.declineFriendQuest(questId);
      emit(state.copyWith(submitting: false, actionMessage: 'Quest ditolak'));
      await load();
    } catch (e) {
      emit(state.copyWith(submitting: false, status: ViewStatus.failure, error: _err(e, 'Gagal menolak quest')));
    }
  }
}

// ==========================================
// Weekly League
// ==========================================
class WeeklyLeagueCubit extends Cubit<ViewState<LeagueOverview>> {
  final SecondaryGamificationRepository _repo;
  WeeklyLeagueCubit(this._repo) : super(const ViewState.initial());

  Future<void> load() async {
    emit(state.copyWith(status: ViewStatus.loading, clearMessages: true));
    try {
      final overview = await _repo.getLeagueOverview();
      // overview may be null when there is no active season — that is a valid success state.
      emit(ViewState<LeagueOverview>(status: ViewStatus.success, data: overview));
    } catch (e) {
      emit(state.copyWith(status: ViewStatus.failure, error: _err(e, 'Gagal memuat liga')));
    }
  }
}
