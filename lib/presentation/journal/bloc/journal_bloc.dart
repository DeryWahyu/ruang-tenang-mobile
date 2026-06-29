import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../domain/usecases/journal/journal_usecases.dart';
import 'journal_event.dart';
import 'journal_state.dart';

class JournalBloc extends Bloc<JournalEvent, JournalState> {
  final JournalUseCases _useCases;

  JournalBloc({required JournalUseCases journalUseCases})
      : _useCases = journalUseCases,
        super(const JournalState.initial()) {
    on<JournalListRequested>(_onListRequested);
    on<JournalLoadMoreRequested>(_onLoadMore);
    on<JournalSearchRequested>(_onSearch);
    on<JournalSearchCleared>(_onSearchCleared);
    on<JournalDetailRequested>(_onDetailRequested);
    on<JournalCreateRequested>(_onCreate);
    on<JournalUpdateRequested>(_onUpdate);
    on<JournalDeleteRequested>(_onDelete);
  }

  Future<void> _onListRequested(
    JournalListRequested event,
    Emitter<JournalState> emit,
  ) async {
    emit(state.copyWith(
      status: JournalStatus.loading,
      items: event.refresh ? const [] : state.items,
      total: event.refresh ? 0 : state.total,
      page: 1,
      clearSearch: true,
    ));

    try {
      final result = await _useCases.getList(page: 1, limit: state.limit, tags: event.tags);
      emit(state.copyWith(
        status: JournalStatus.listSuccess,
        items: result.items,
        total: result.total,
        page: result.page,
        limit: result.limit,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: JournalStatus.failure,
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: JournalStatus.failure,
        errorMessage: 'Gagal memuat jurnal. Periksa koneksi internet Anda.',
      ));
    }
  }

  Future<void> _onLoadMore(
    JournalLoadMoreRequested event,
    Emitter<JournalState> emit,
  ) async {
    if (!state.hasNextPage || state.isLoadMore) return;

    emit(state.copyWith(status: JournalStatus.loadMore));

    try {
      final nextPage = state.page + 1;
      final result = await _useCases.getList(page: nextPage, limit: state.limit);
      emit(state.copyWith(
        status: JournalStatus.listSuccess,
        items: [...state.items, ...result.items],
        page: result.page,
        total: result.total,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: JournalStatus.listSuccess,
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: JournalStatus.listSuccess,
        errorMessage: 'Gagal memuat lebih banyak jurnal.',
      ));
    }
  }

  Future<void> _onSearch(
    JournalSearchRequested event,
    Emitter<JournalState> emit,
  ) async {
    final query = event.query.trim();
    if (query.isEmpty) return;

    emit(state.copyWith(
      status: JournalStatus.loading,
      searchQuery: query,
      items: const [],
    ));

    try {
      final results = await _useCases.search(query);
      emit(state.copyWith(
        status: JournalStatus.listSuccess,
        items: results,
        total: results.length,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: JournalStatus.failure,
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: JournalStatus.failure,
        errorMessage: 'Gagal mencari jurnal.',
      ));
    }
  }

  Future<void> _onSearchCleared(
    JournalSearchCleared event,
    Emitter<JournalState> emit,
  ) async {
    emit(state.copyWith(clearSearch: true));
    add(const JournalListRequested(refresh: true));
  }

  Future<void> _onDetailRequested(
    JournalDetailRequested event,
    Emitter<JournalState> emit,
  ) async {
    emit(state.copyWith(
      status: JournalStatus.detailLoading,
      detail: null,
    ));

    try {
      final journal = await _useCases.getJournal(event.uuid);
      emit(state.copyWith(
        status: JournalStatus.detailSuccess,
        detail: journal,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: JournalStatus.failure,
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: JournalStatus.failure,
        errorMessage: 'Gagal memuat detail jurnal.',
      ));
    }
  }

  Future<void> _onCreate(
    JournalCreateRequested event,
    Emitter<JournalState> emit,
  ) async {
    emit(state.copyWith(status: JournalStatus.submitting));

    try {
      final journal = await _useCases.create(
        title: event.title.trim(),
        content: event.content,
        moodId: event.moodId,
        tags: event.tags,
        isPrivate: event.isPrivate,
      );
      // If the user asked to publish but moderation kept it private, inform them.
      final downgraded = !event.isPrivate && journal.isPrivate;
      emit(state.copyWith(
        status: JournalStatus.success,
        successMessage: downgraded
            ? 'Jurnal disimpan sebagai privat. Moderasi otomatis belum menyetujuinya untuk dibagikan ke komunitas.'
            : 'Jurnal berhasil disimpan.',
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: JournalStatus.failure,
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: JournalStatus.failure,
        errorMessage: 'Gagal menyimpan jurnal. Silakan coba lagi.',
      ));
    }
  }

  Future<void> _onUpdate(
    JournalUpdateRequested event,
    Emitter<JournalState> emit,
  ) async {
    emit(state.copyWith(status: JournalStatus.submitting));

    try {
      final journal = await _useCases.update(
        uuid: event.uuid,
        title: event.title?.trim(),
        content: event.content,
        moodId: event.moodId,
        tags: event.tags,
        isPrivate: event.isPrivate,
      );
      final downgraded = event.isPrivate == false && journal.isPrivate;
      emit(state.copyWith(
        status: JournalStatus.detailSuccess,
        detail: journal,
        successMessage: downgraded
            ? 'Perubahan disimpan sebagai privat. Moderasi otomatis belum menyetujuinya untuk dibagikan ke komunitas.'
            : 'Jurnal berhasil diperbarui.',
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: JournalStatus.failure,
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: JournalStatus.failure,
        errorMessage: 'Gagal memperbarui jurnal.',
      ));
    }
  }

  Future<void> _onDelete(
    JournalDeleteRequested event,
    Emitter<JournalState> emit,
  ) async {
    emit(state.copyWith(status: JournalStatus.submitting));

    try {
      await _useCases.delete(event.uuid);
      // Remove the deleted item from the local list so the UI updates.
      final remaining = state.items.where((e) => e.uuid != event.uuid).toList();
      emit(state.copyWith(
        status: JournalStatus.success,
        items: remaining,
        total: state.total > 0 ? state.total - 1 : 0,
        successMessage: 'Jurnal berhasil dihapus.',
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: JournalStatus.failure,
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: JournalStatus.failure,
        errorMessage: 'Gagal menghapus jurnal.',
      ));
    }
  }
}
