import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/error_message.dart';
import '../../../domain/entities/story.dart';
import '../../../domain/repositories/story_repository.dart';
import 'story_event.dart';
import 'story_state.dart';

class StoryBloc extends Bloc<StoryEvent, StoryState> {
  final StoryRepository _repository;

  StoryBloc({required StoryRepository repository})
      : _repository = repository,
        super(const StoryState.initial()) {
    on<StoryListRequested>(_onListRequested);
    on<StoryDetailRequested>(_onDetailRequested);
    on<StoryHeartToggled>(_onHeartToggled);
    on<StoryCategoriesRequested>(_onCategoriesRequested);
    on<StoryCommentsRequested>(_onCommentsRequested);
    on<StoryCommentCreateRequested>(_onCommentCreate);
    on<StoryCommentHeartToggled>(_onCommentHeartToggled);
    on<StorySearchRequested>(_onSearchRequested);
  }

  Future<void> _onListRequested(StoryListRequested event, Emitter<StoryState> emit) async {
    emit(state.copyWith(status: StoryStatus.loading, stories: event.refresh ? const [] : state.stories));
    try {
      final stories = await _repository.getStories(sortBy: event.sortBy);
      emit(state.copyWith(status: StoryStatus.listSuccess, stories: stories));
    } catch (e) {
      emit(state.copyWith(
        status: StoryStatus.failure,
        errorMessage: ErrorMessage.from(e, 'Gagal memuat cerita'),
      ));
    }
  }

  Future<void> _onDetailRequested(StoryDetailRequested event, Emitter<StoryState> emit) async {
    emit(state.copyWith(status: StoryStatus.detailLoading));
    try {
      final story = await _repository.getStory(event.id);
      emit(state.copyWith(status: StoryStatus.detailSuccess, detail: story));
    } catch (e) {
      emit(state.copyWith(
        status: StoryStatus.failure,
        errorMessage: ErrorMessage.from(e, 'Gagal memuat cerita'),
      ));
    }
  }

  Future<void> _onHeartToggled(StoryHeartToggled event, Emitter<StoryState> emit) async {
    try {
      await _repository.toggleHeart(event.id);
      if (state.detail != null && state.detail!.id == event.id) {
        final updated = Story(
          id: state.detail!.id,
          title: state.detail!.title,
          content: state.detail!.content,
          coverImage: state.detail!.coverImage,
          isAnonymous: state.detail!.isAnonymous,
          hasTriggerWarning: state.detail!.hasTriggerWarning,
          triggerWarningText: state.detail!.triggerWarningText,
          status: state.detail!.status,
          viewCount: state.detail!.viewCount,
          heartCount: state.detail!.hasHearted ? state.detail!.heartCount - 1 : state.detail!.heartCount + 1,
          commentCount: state.detail!.commentCount,
          isFeatured: state.detail!.isFeatured,
          author: state.detail!.author,
          categories: state.detail!.categories,
          tags: state.detail!.tags,
          hasHearted: !state.detail!.hasHearted,
          createdAt: state.detail!.createdAt,
          publishedAt: state.detail!.publishedAt,
        );
        emit(state.copyWith(detail: updated));
      }
    } catch (_) {}
  }

  Future<void> _onCategoriesRequested(StoryCategoriesRequested event, Emitter<StoryState> emit) async {
    try {
      final categories = await _repository.getCategories();
      emit(state.copyWith(categories: categories));
    } catch (_) {}
  }

  Future<void> _onCommentsRequested(StoryCommentsRequested event, Emitter<StoryState> emit) async {
    try {
      final comments = await _repository.getComments(event.storyId);
      emit(state.copyWith(comments: comments));
    } catch (_) {}
  }

  Future<void> _onCommentCreate(StoryCommentCreateRequested event, Emitter<StoryState> emit) async {
    emit(state.copyWith(status: StoryStatus.submitting));
    try {
      final comment = await _repository.createComment(event.storyId, event.content);
      emit(state.copyWith(
        status: StoryStatus.success,
        comments: [...state.comments, comment],
        successMessage: 'Komentar berhasil dikirim',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: StoryStatus.failure,
        errorMessage: ErrorMessage.from(e, 'Gagal mengirim komentar'),
      ));
    }
  }

  Future<void> _onCommentHeartToggled(StoryCommentHeartToggled event, Emitter<StoryState> emit) async {
    final oldComments = state.comments;
    final index = oldComments.indexWhere((c) => c.id == event.commentId);
    if (index == -1) return;

    final comment = oldComments[index];
    final isHearted = !comment.hasHearted;
    final newCount = comment.heartCount + (isHearted ? 1 : -1);

    final newComments = List<StoryComment>.from(oldComments);
    newComments[index] = comment.copyWith(
      hasHearted: isHearted,
      heartCount: newCount,
    );

    emit(state.copyWith(comments: newComments));

    try {
      await _repository.toggleCommentHeart(event.commentId);
    } catch (_) {
      // Revert on failure
      emit(state.copyWith(comments: oldComments));
    }
  }

  Future<void> _onSearchRequested(StorySearchRequested event, Emitter<StoryState> emit) async {
    emit(state.copyWith(status: StoryStatus.loading, stories: const []));
    try {
      final stories = await _repository.getStories(search: event.query);
      emit(state.copyWith(status: StoryStatus.listSuccess, stories: stories));
    } catch (e) {
      emit(state.copyWith(
        status: StoryStatus.failure,
        errorMessage: ErrorMessage.from(e, 'Gagal mencari cerita'),
      ));
    }
  }
}