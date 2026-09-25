import 'package:equatable/equatable.dart';

abstract class StoryEvent extends Equatable {
  const StoryEvent();
  @override
  List<Object?> get props => [];
}

class StoryListRequested extends StoryEvent {
  final bool refresh;
  final String sortBy;
  final String? categoryId;
  final String? search;
  const StoryListRequested({
    this.refresh = false,
    this.sortBy = 'recent',
    this.categoryId,
    this.search,
  });
  @override
  List<Object?> get props => [refresh, sortBy, categoryId, search];
}

class StoryLoadMoreRequested extends StoryEvent {
  final String sortBy;
  final String? categoryId;
  final String? search;
  const StoryLoadMoreRequested({
    this.sortBy = 'recent',
    this.categoryId,
    this.search,
  });
  @override
  List<Object?> get props => [sortBy, categoryId, search];
}

class StoryDetailRequested extends StoryEvent {
  final String id;
  const StoryDetailRequested(this.id);
  @override
  List<Object?> get props => [id];
}

class StoryHeartToggled extends StoryEvent {
  final String id;
  const StoryHeartToggled(this.id);
  @override
  List<Object?> get props => [id];
}

class StoryCommentsRequested extends StoryEvent {
  final String storyId;
  const StoryCommentsRequested(this.storyId);
  @override
  List<Object?> get props => [storyId];
}

class StoryCommentCreateRequested extends StoryEvent {
  final String storyId;
  final String content;
  const StoryCommentCreateRequested({
    required this.storyId,
    required this.content,
  });
  @override
  List<Object?> get props => [storyId, content];
}

class StoryCommentHeartToggled extends StoryEvent {
  final String storyId;
  final String commentId;
  const StoryCommentHeartToggled(this.storyId, this.commentId);
  @override
  List<Object?> get props => [storyId, commentId];
}

class StorySearchRequested extends StoryEvent {
  final String query;
  const StorySearchRequested(this.query);
  @override
  List<Object?> get props => [query];
}
