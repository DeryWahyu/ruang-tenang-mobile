import 'package:equatable/equatable.dart';
import '../../../domain/entities/chat.dart';

enum ChatStatus {
  initial,
  loading,
  loadMore,
  listSuccess,
  detailLoading,
  detailSuccess,
  sendingMessage,
  success,
  failure,
}

class ChatState extends Equatable {
  final ChatStatus status;
  final List<ChatSessionListItem> sessions;
  final int total;
  final int page;
  final int limit;
  final ChatSession? currentSession;
  final String? errorMessage;
  final String? successMessage;

  const ChatState({
    this.status = ChatStatus.initial,
    this.sessions = const [],
    this.total = 0,
    this.page = 1,
    this.limit = 20,
    this.currentSession,
    this.errorMessage,
    this.successMessage,
  });

  const ChatState.initial() : this(status: ChatStatus.initial);

  bool get isLoading => status == ChatStatus.loading;
  bool get isLoadMore => status == ChatStatus.loadMore;
  bool get isDetailLoading => status == ChatStatus.detailLoading;
  bool get isSendingMessage => status == ChatStatus.sendingMessage;

  int get totalPages => limit > 0 ? (total / limit).ceil() : 0;
  bool get hasNextPage => page < totalPages;

  ChatState copyWith({
    ChatStatus? status,
    List<ChatSessionListItem>? sessions,
    int? total,
    int? page,
    int? limit,
    ChatSession? currentSession,
    String? errorMessage,
    String? successMessage,
  }) {
    return ChatState(
      status: status ?? this.status,
      sessions: sessions ?? this.sessions,
      total: total ?? this.total,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      currentSession: currentSession ?? this.currentSession,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        sessions,
        total,
        page,
        limit,
        currentSession,
        errorMessage,
        successMessage,
      ];
}
