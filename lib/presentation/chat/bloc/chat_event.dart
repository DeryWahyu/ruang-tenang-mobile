import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class ChatSessionsRequested extends ChatEvent {
  final bool refresh;
  final String filter;
  final String? search;
  const ChatSessionsRequested({
    this.refresh = false,
    this.filter = 'all',
    this.search,
  });

  @override
  List<Object?> get props => [refresh, filter, search];
}

class ChatSessionsLoadMoreRequested extends ChatEvent {
  final String filter;
  final String? search;
  const ChatSessionsLoadMoreRequested({this.filter = 'all', this.search});

  @override
  List<Object?> get props => [filter, search];
}

class ChatSessionDetailRequested extends ChatEvent {
  final String uuid;
  const ChatSessionDetailRequested(this.uuid);

  @override
  List<Object?> get props => [uuid];
}

class ChatSessionCreateRequested extends ChatEvent {
  final String title;
  final int? folderId;

  const ChatSessionCreateRequested({required this.title, this.folderId});

  @override
  List<Object?> get props => [title, folderId];
}

class ChatSessionDeleteRequested extends ChatEvent {
  final String uuid;
  const ChatSessionDeleteRequested(this.uuid);

  @override
  List<Object?> get props => [uuid];
}

class ChatMessageSendRequested extends ChatEvent {
  final String uuid;
  final String content;
  final String type;

  const ChatMessageSendRequested({
    required this.uuid,
    required this.content,
    this.type = 'text',
  });

  @override
  List<Object?> get props => [uuid, content, type];
}

/// Dikirim saat pengguna mengirim pesan pertama pada obrolan baru (belum ada
/// sesi). Bloc akan membuat sesi tanpa judul lalu langsung mengirim pesan
/// pertama. Judul dibuat otomatis oleh backend dari pesan pertama tersebut
/// (mirip GPT/Gemini/Claude).
class ChatFirstMessageSent extends ChatEvent {
  final String content;
  final String type;
  final int? folderId;

  const ChatFirstMessageSent({
    required this.content,
    this.folderId,
    this.type = 'text',
  });

  @override
  List<Object?> get props => [content, folderId, type];
}

class ChatMessageLikeToggled extends ChatEvent {
  final int messageId;
  const ChatMessageLikeToggled(this.messageId);

  @override
  List<Object?> get props => [messageId];
}

class ChatMessageDislikeToggled extends ChatEvent {
  final int messageId;
  const ChatMessageDislikeToggled(this.messageId);

  @override
  List<Object?> get props => [messageId];
}
