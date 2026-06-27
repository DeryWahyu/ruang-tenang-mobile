import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class ChatSessionsRequested extends ChatEvent {
  final bool refresh;
  const ChatSessionsRequested({this.refresh = false});

  @override
  List<Object?> get props => [refresh];
}

class ChatSessionsLoadMoreRequested extends ChatEvent {
  const ChatSessionsLoadMoreRequested();
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

  const ChatMessageSendRequested({required this.uuid, required this.content});

  @override
  List<Object?> get props => [uuid, content];
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
