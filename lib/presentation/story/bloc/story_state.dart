import 'package:equatable/equatable.dart';
import '../../../domain/entities/story.dart';

enum StoryStatus { initial, loading, listSuccess, detailLoading, detailSuccess, submitting, success, failure }

class StoryState extends Equatable {
  final StoryStatus status;
  final List<StoryCard> stories;
  final Story? detail;
  final List<StoryComment> comments;
  final String errorMessage;
  final String successMessage;

  const StoryState({
    this.status = StoryStatus.initial,
    this.stories = const [],
    this.detail,
    this.comments = const [],
    this.errorMessage = '',
    this.successMessage = '',
  });

  const StoryState.initial() : this();

  StoryState copyWith({
    StoryStatus? status,
    List<StoryCard>? stories,
    Story? detail,
    List<StoryComment>? comments,
    String? errorMessage,
    String? successMessage,
  }) {
    return StoryState(
      status: status ?? this.status,
      stories: stories ?? this.stories,
      detail: detail ?? this.detail,
      comments: comments ?? this.comments,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
    );
  }

  @override
  List<Object?> get props => [status, stories, detail, comments, errorMessage, successMessage];
}
