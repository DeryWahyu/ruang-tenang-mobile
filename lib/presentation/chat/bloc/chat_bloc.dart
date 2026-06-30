import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/error_message.dart';
import '../../../domain/entities/chat.dart';
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
    on<ChatFirstMessageSent>(_onFirstMessageSent);
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
    } catch (e) {
      emit(state.copyWith(
        status: ChatStatus.failure,
        errorMessage: ErrorMessage.from(e, 'Gagal memuat daftar obrolan.'),
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
    } catch (e) {
      emit(state.copyWith(
        status: ChatStatus.failure,
        errorMessage: ErrorMessage.from(e, 'Gagal memuat obrolan.'),
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
    } catch (e) {
      emit(state.copyWith(
        status: ChatStatus.failure,
        errorMessage: ErrorMessage.from(e, 'Gagal membuat sesi obrolan.'),
      ));
    }
  }

  /// Membuat sesi baru tanpa judul lalu langsung mengirim pesan pertama.
  /// Backend akan menghasilkan judul otomatis dari pesan pertama tersebut.
  Future<void> _onFirstMessageSent(
      ChatFirstMessageSent event, Emitter<ChatState> emit) async {
    final content = event.content.trim();
    if (content.isEmpty) return;

    emit(state.copyWith(status: ChatStatus.loading));

    // 1. Buat sesi tanpa judul (title kosong -> backend auto-generate).
    final ChatSession session;
    try {
      session = await _useCases.createSession('', folderId: event.folderId);
    } catch (e) {
      emit(state.copyWith(
        status: ChatStatus.failure,
        errorMessage: ErrorMessage.from(e, 'Gagal membuat sesi obrolan.'),
      ));
      return;
    }

    // Tampilkan sesi baru supaya UI bisa berpindah ke layar obrolan.
    emit(state.copyWith(
      status: ChatStatus.createSuccess,
      currentSession: session,
    ));

    // 2. Kirim pesan pertama pada sesi yang baru dibuat.
    emit(state.copyWith(status: ChatStatus.sendingMessage));
    try {
      final result = await _useCases.sendMessage(session.uuid, content);

      final updatedMessages = [
        ...session.messages,
        result.userMessage,
        result.aiMessage,
      ];
      var updatedSession = session.copyWith(messages: updatedMessages);

      // Muat ulang sesi agar mendapat judul yang dibuat otomatis oleh backend
      // dari pesan pertama. Jika gagal, tetap pakai gabungan pesan lokal.
      try {
        final refreshed = await _useCases.getSession(session.uuid);
        updatedSession = refreshed;
      } catch (_) {
        // Abaikan; judul akan tersinkron saat berikutnya membuka sesi.
      }

      emit(state.copyWith(
        status: ChatStatus.detailSuccess,
        currentSession: updatedSession,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ChatStatus.detailSuccess,
        errorMessage: ErrorMessage.from(e, 'Gagal mengirim pesan.'),
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
    } catch (e) {
      emit(state.copyWith(
        status: ChatStatus.failure,
        errorMessage: ErrorMessage.from(e, 'Gagal menghapus obrolan.'),
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
    } catch (e) {
      // Tetap di detailSuccess agar percakapan tetap tampil. Jalur ini juga
      // menangani kuota chat habis — pesan error dari API (mis. "kuota habis")
      // diteruskan apa adanya lewat ErrorMessage.from.
      emit(state.copyWith(
        status: ChatStatus.detailSuccess,
        errorMessage: ErrorMessage.from(e, 'Gagal mengirim pesan.'),
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
