import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/error_message.dart';
import '../../../domain/entities/secondary_gamification.dart';
import '../../../domain/repositories/secondary_gamification_repository.dart';
import 'view_state.dart';

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
      emit(state.copyWith(status: ViewStatus.failure, error: ErrorMessage.from(e, 'Gagal memuat guild')));
    }
  }

  Future<void> createGuild({required String name, required String description, required String icon, required bool isPublic}) async {
    emit(state.copyWith(submitting: true, clearMessages: true));
    try {
      await _repo.createGuild(name: name, description: description, icon: icon, isPublic: isPublic);
      emit(state.copyWith(submitting: false, actionMessage: 'Guild berhasil dibuat!'));
      await load();
    } catch (e) {
      emit(state.copyWith(submitting: false, status: ViewStatus.failure, error: ErrorMessage.from(e, 'Gagal membuat guild')));
    }
  }

  Future<void> joinGuild(String guildId) async {
    emit(state.copyWith(submitting: true, clearMessages: true));
    try {
      await _repo.joinGuild(guildId);
      emit(state.copyWith(submitting: false, actionMessage: 'Berhasil bergabung ke guild!'));
      await load();
    } catch (e) {
      emit(state.copyWith(submitting: false, status: ViewStatus.failure, error: ErrorMessage.from(e, 'Gagal bergabung')));
    }
  }

  Future<void> joinByCode(String code) async {
    emit(state.copyWith(submitting: true, clearMessages: true));
    try {
      await _repo.joinGuildByCode(code);
      emit(state.copyWith(submitting: false, actionMessage: 'Berhasil bergabung ke guild!'));
      await load();
    } catch (e) {
      emit(state.copyWith(submitting: false, status: ViewStatus.failure, error: ErrorMessage.from(e, 'Kode tidak valid')));
    }
  }

  Future<void> leaveGuild(String guildId) async {
    emit(state.copyWith(submitting: true, clearMessages: true));
    try {
      await _repo.leaveGuild(guildId);
      emit(state.copyWith(submitting: false, actionMessage: 'Kamu telah meninggalkan guild'));
      await load();
    } catch (e) {
      emit(state.copyWith(submitting: false, status: ViewStatus.failure, error: ErrorMessage.from(e, 'Gagal meninggalkan guild')));
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
      emit(state.copyWith(status: ViewStatus.failure, error: ErrorMessage.from(e, 'Gagal memuat XP boost')));
    }
  }
}
