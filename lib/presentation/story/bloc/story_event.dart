import 'package:equatable/equatable.dart';

abstract class StoryEvent extends Equatable {
  const StoryEvent();
  @override
  List<Object?> get props => [];
}

class StoryListRequested extends StoryEvent {
  final bool refresh;
  final String sortBy;
  const StoryListRequested({this.refresh = false, this.sortBy = 'recent'});
  @override
  List<Object?> get props => [refresh, sortBy];
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

class StoryCategoriesRequested extends StoryEvent {
  const StoryCategoriesRequested();
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
  const StoryCommentCreateRequested({required this.storyId, required this.content});
  @override
  List<Object?> get props => [storyId, content];
}

class StoryCommentHeartToggled extends StoryEvent {
  final String commentId;
  const StoryCommentHeartToggled(this.commentId);
  @override
  List<Object?> get props => [commentId];
}

class StorySearchRequested extends StoryEvent {
  final String query;
  const StorySearchRequested(this.query);
  @override
  List<Object?> get props => [query];
}