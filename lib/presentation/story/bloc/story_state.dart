import 'package:equatable/equatable.dart';
import '../../../domain/entities/story.dart';

enum StoryStatus { initial, loading, listSuccess, detailLoading, detailSuccess, submitting, success, failure }

class StoryState extends Equatable {
  final StoryStatus status;
  final List<StoryCard> stories;
  final List<StoryCategory> categories;
  final Story? detail;
  final List<StoryComment> comments;
  final String errorMessage;
  final String successMessage;

  const StoryState({
    this.status = StoryStatus.initial,
    this.stories = const [],
    this.categories = const [],
    this.detail,
    this.comments = const [],
    this.errorMessage = '',
    this.successMessage = '',
  });

  const StoryState.initial() : this();

  StoryState copyWith({
    StoryStatus? status,
    List<StoryCard>? stories,
    List<StoryCategory>? categories,
    Story? detail,
    List<StoryComment>? comments,
    String? errorMessage,
    String? successMessage,
  }) {
    return StoryState(
      status: status ?? this.status,
      stories: stories ?? this.stories,
      categories: categories ?? this.categories,
      detail: detail ?? this.detail,
      comments: comments ?? this.comments,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
    );
  }

  @override
  List<Object?> get props => [status, stories, categories, detail, comments, errorMessage, successMessage];
}