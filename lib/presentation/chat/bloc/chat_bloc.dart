import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../domain/usecases/chat/chat_usecases.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatUseCases _useCases;

  ChatBloc({required ChatUseCases chatUseCases})
      : _useCases = chatUseCases,
        super(const ChatState.initial()) {
    on<ChatSessionsRequested>(_onSessionsRequested);
    on<ChatSessionsLoadMoreRequested>(_onLoadMoreRequested);
    on<ChatSessionDetailRequested>(_onDetailRequested);
    on<ChatSessionCreateRequested>(_onCreateRequested);
    on<ChatSessionDeleteRequested>(_onDeleteRequested);
    on<ChatMessageSendRequested>(_onMessageSendRequested);
    on<ChatMessageLikeToggled>(_onMessageLikeToggled);
    on<ChatMessageDislikeToggled>(_onMessageDislikeToggled);
  }

  Future<void> _onSessionsRequested(
      ChatSessionsRequested event, Emitter<ChatState> emit) async {
    emit(state.copyWith(
      status: ChatStatus.loading,
      sessions: event.refresh ? const [] : state.sessions,
      total: event.refresh ? 0 : state.total,
      page: 1,
    ));

    try {
      final result =
          await _useCases.getSessions(page: 1, limit: state.limit);
      emit(state.copyWith(
        status: ChatStatus.listSuccess,
        sessions: result.items,
        total: result.total,
        page: result.page,
        limit: result.limit,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(status: ChatStatus.failure, errorMessage: e.message));
    } catch (_) {
      emit(state.copyWith(
        status: ChatStatus.failure,
        errorMessage: 'Gagal memuat daftar obrolan.',
      ));
    }
  }

  Future<void> _onLoadMoreRequested(
      ChatSessionsLoadMoreRequested event, Emitter<ChatState> emit) async {
    if (!state.hasNextPage || state.isLoadMore) return;

    emit(state.copyWith(status: ChatStatus.loadMore));

    try {
      final nextPage = state.page + 1;
      final result =
          await _useCases.getSessions(page: nextPage, limit: state.limit);
      emit(state.copyWith(
        status: ChatStatus.listSuccess,
        sessions: [...state.sessions, ...result.items],
        page: result.page,
        total: result.total,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: ChatStatus.listSuccess,
        errorMessage: 'Gagal memuat obrolan lebih banyak.',
      ));
    }
  }

  Future<void> _onDetailRequested(
      ChatSessionDetailRequested event, Emitter<ChatState> emit) async {
    emit(state.copyWith(
        status: ChatStatus.detailLoading, currentSession: null));

    try {
      final session = await _useCases.getSession(event.uuid);
      emit(state.copyWith(
        status: ChatStatus.detailSuccess,
        currentSession: session,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(status: ChatStatus.failure, errorMessage: e.message));
    } catch (_) {
      emit(state.copyWith(
        status: ChatStatus.failure,
        errorMessage: 'Gagal memuat obrolan.',
      ));
    }
  }

  Future<void> _onCreateRequested(
      ChatSessionCreateRequested event, Emitter<ChatState> emit) async {
    emit(state.copyWith(status: ChatStatus.loading));

    try {
      final session = await _useCases.createSession(
        event.title.trim(),
        folderId: event.folderId,
      );
      // Expose the freshly created session so the UI can navigate straight
      // into the new conversation.
      emit(state.copyWith(
        status: ChatStatus.createSuccess,
        currentSession: session,
        successMessage: 'Sesi obrolan dibuat.',
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(status: ChatStatus.failure, errorMessage: e.message));
    } catch (_) {
      emit(state.copyWith(
        status: ChatStatus.failure,
        errorMessage: 'Gagal membuat sesi obrolan.',
      ));
    }
  }

  Future<void> _onDeleteRequested(
      ChatSessionDeleteRequested event, Emitter<ChatState> emit) async {
    emit(state.copyWith(status: ChatStatus.loading));

    try {
      await _useCases.deleteSession(event.uuid);
      final remaining =
          state.sessions.where((e) => e.uuid != event.uuid).toList();
      emit(state.copyWith(
        status: ChatStatus.success,
        sessions: remaining,
        total: state.total > 0 ? state.total - 1 : 0,
        successMessage: 'Obrolan dihapus.',
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(status: ChatStatus.failure, errorMessage: e.message));
    } catch (_) {
      emit(state.copyWith(
        status: ChatStatus.failure,
        errorMessage: 'Gagal menghapus obrolan.',
      ));
    }
  }

  Future<void> _onMessageSendRequested(
      ChatMessageSendRequested event, Emitter<ChatState> emit) async {
    if (state.currentSession == null) return;

    emit(state.copyWith(status: ChatStatus.sendingMessage));

    try {
      final result =
          await _useCases.sendMessage(event.uuid, event.content.trim());

      final updatedMessages = [
        ...state.currentSession!.messages,
        result.userMessage,
        result.aiMessage,
      ];

      final updatedSession =
          state.currentSession!.copyWith(messages: updatedMessages);

      emit(state.copyWith(
        status: ChatStatus.detailSuccess,
        currentSession: updatedSession,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: ChatStatus.detailSuccess,
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: ChatStatus.detailSuccess,
        errorMessage: 'Gagal mengirim pesan.',
      ));
    }
  }

  Future<void> _onMessageLikeToggled(
      ChatMessageLikeToggled event, Emitter<ChatState> emit) async {
    try {
      await _useCases.toggleLikeMessage(event.messageId);
    } catch (_) {
      // Ignored for optimisic UI if implemented
    }
  }

  Future<void> _onMessageDislikeToggled(
      ChatMessageDislikeToggled event, Emitter<ChatState> emit) async {
    try {
      await _useCases.toggleDislikeMessage(event.messageId);
    } catch (_) {
      // Ignored
    }
  }
}
