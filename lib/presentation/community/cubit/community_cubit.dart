import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/error_message.dart';
import '../../../domain/entities/community.dart';
import '../../../domain/repositories/community_repository.dart';
import '../../gamification/cubit/view_state.dart';

/// Cubit untuk layar Statistik Komunitas. Memuat [CommunityStats]
/// dan mengekspos status loading/success/failure via [ViewState].
class CommunityCubit extends Cubit<ViewState<CommunityStats>> {
  final CommunityRepository _repository;

  CommunityCubit(this._repository) : super(const ViewState.initial());

  Future<void> load() async {
    emit(state.copyWith(status: ViewStatus.loading, clearMessages: true));
    try {
      final stats = await _repository.getStats();
      emit(state.copyWith(status: ViewStatus.success, data: stats));
    } catch (e) {
      emit(state.copyWith(
        status: ViewStatus.failure,
        error: ErrorMessage.from(e, 'Gagal memuat statistik komunitas'),
      ));
    }
  }
}
