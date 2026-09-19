import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/error_message.dart';
import '../../../domain/entities/secondary_gamification.dart';
import '../../../domain/repositories/secondary_gamification_repository.dart';
import 'view_state.dart';

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
