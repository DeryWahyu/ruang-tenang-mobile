import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/error_message.dart';
import '../../../domain/repositories/forum_repository.dart';
import 'forum_event.dart';
import '../../../domain/entities/forum.dart';
import 'forum_state.dart';

class ForumBloc extends Bloc<ForumEvent, ForumState> {
  final ForumRepository _repository;
  String? _search;
  int? _categoryId;
  String? _circle;

  ForumBloc({required ForumRepository repository})
    : _repository = repository,
      super(const ForumState.initial()) {
    on<ForumListRequested>(_onListRequested);
    on<ForumLoadMoreRequested>(_onLoadMoreRequested);
    on<ForumCategoriesRequested>(_onCategoriesRequested);
    on<ForumDetailRequested>(_onDetailRequested);
    on<ForumPostsRequested>(_onPostsRequested);
    on<ForumPostsLoadMoreRequested>(_onPostsLoadMoreRequested);
    on<ForumCreateRequested>(_onCreateRequested);
    on<ForumPostCreateRequested>(_onPostCreateRequested);
    on<ForumPostVoteRequested>(_onPostVoteRequested);
    on<ForumLikeToggled>(_onLikeToggled);
    on<ForumSearchRequested>(_onSearchRequested);
  }

  Future<void> _onListRequested(
    ForumListRequested event,
    Emitter<ForumState> emit,
  ) async {
    if (event.updateFilters) {
      _search = event.search;
      _categoryId = event.categoryId;
      _circle = event.circle;
    }
    emit(
      state.copyWith(
        status: ForumStatus.loading,
        threads: event.refresh ? const [] : state.threads,
      ),
    );
    try {
      final threads = await _repository.getForums(
        search: _search,
        categoryId: _categoryId,
        circle: _circle,
      );
      emit(
        state.copyWith(
          status: ForumStatus.listSuccess,
          threads: threads,
          page: 1,
          hasMore: threads.length == 10,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ForumStatus.failure,
          errorMessage: ErrorMessage.from(e, 'Gagal memuat forum'),
        ),
      );
    }
  }

  Future<void> _onLoadMoreRequested(
    ForumLoadMoreRequested event,
    Emitter<ForumState> emit,
  ) async {
    if (!state.hasMore || state.loadingMore) return;
    emit(state.copyWith(loadingMore: true));
    try {
      final nextPage = state.page + 1;
      final next = await _repository.getForums(
        page: nextPage,
        search: _search,
        categoryId: _categoryId,
        circle: _circle,
      );
      emit(
        state.copyWith(
          threads: [...state.threads, ...next],
          page: nextPage,
          hasMore: next.length == 10,
          loadingMore: false,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          loadingMore: false,
          errorMessage: ErrorMessage.from(
            error,
            'Gagal memuat forum berikutnya',
          ),
        ),
      );
    }
  }

  Future<void> _onCategoriesRequested(
    ForumCategoriesRequested event,
    Emitter<ForumState> emit,
  ) async {
    try {
      final categories = await _repository.getCategories();
      emit(state.copyWith(categories: categories));
    } catch (_) {}
  }

  Future<void> _onDetailRequested(
    ForumDetailRequested event,
    Emitter<ForumState> emit,
  ) async {
    emit(state.copyWith(status: ForumStatus.detailLoading));
    try {
      final forum = await _repository.getForum(event.slug);
      emit(state.copyWith(status: ForumStatus.detailSuccess, detail: forum));
    } catch (e) {
      emit(
        state.copyWith(
          status: ForumStatus.failure,
          errorMessage: ErrorMessage.from(e, 'Gagal memuat detail forum'),
        ),
      );
    }
  }

  Future<void> _onPostsRequested(
    ForumPostsRequested event,
    Emitter<ForumState> emit,
  ) async {
    try {
      final posts = await _repository.getPosts(
        event.slug,
        sortBy: event.sortBy,
      );
      emit(
        state.copyWith(
          posts: posts,
          sortBy: event.sortBy,
          postsPage: 1,
          postsHasMore: posts.length == 10,
        ),
      );
    } catch (_) {}
  }

  Future<void> _onPostsLoadMoreRequested(
    ForumPostsLoadMoreRequested event,
    Emitter<ForumState> emit,
  ) async {
    if (!state.postsHasMore || state.postsLoadingMore) return;
    emit(state.copyWith(postsLoadingMore: true));
    try {
      final nextPage = state.postsPage + 1;
      final next = await _repository.getPosts(
        event.slug,
        page: nextPage,
        sortBy: state.sortBy,
      );
      emit(
        state.copyWith(
          posts: [...state.posts, ...next],
          postsPage: nextPage,
          postsHasMore: next.length == 10,
          postsLoadingMore: false,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          postsLoadingMore: false,
          errorMessage: ErrorMessage.from(
            error,
            'Gagal memuat balasan berikutnya',
          ),
        ),
      );
    }
  }

  Future<void> _onCreateRequested(
    ForumCreateRequested event,
    Emitter<ForumState> emit,
  ) async {
    emit(state.copyWith(status: ForumStatus.submitting));
    try {
      await _repository.createForum(
        title: event.title,
        content: event.content,
        categoryId: event.categoryId,
      );
      emit(
        state.copyWith(
          status: ForumStatus.success,
          successMessage: 'Diskusi berhasil dibuat',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ForumStatus.failure,
          errorMessage: ErrorMessage.from(e, 'Gagal membuat diskusi'),
        ),
      );
    }
  }

  Future<void> _onPostCreateRequested(
    ForumPostCreateRequested event,
    Emitter<ForumState> emit,
  ) async {
    emit(state.copyWith(status: ForumStatus.submitting));
    try {
      final post = await _repository.createPost(event.slug, event.content);
      emit(
        state.copyWith(
          status: ForumStatus.success,
          posts: [...state.posts, post],
          successMessage: 'Balasan berhasil dikirim',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ForumStatus.failure,
          errorMessage: ErrorMessage.from(e, 'Gagal mengirim balasan'),
        ),
      );
    }
  }

  Future<void> _onPostVoteRequested(
    ForumPostVoteRequested event,
    Emitter<ForumState> emit,
  ) async {
    try {
      if (event.voteType == 'upvote') {
        await _repository.upvotePost(event.postId);
      } else if (event.voteType == 'downvote') {
        await _repository.downvotePost(event.postId);
      } else {
        await _repository.removeVote(event.postId);
      }
      final updatedPosts = state.posts.map((post) {
        if (post.id != event.postId) return post;
        if (event.voteType == 'upvote') {
          return ForumPost(
            id: post.id,
            forumId: post.forumId,
            userId: post.userId,
            content: post.content,
            isAcceptedAnswer: post.isAcceptedAnswer,
            isCommunityFavorite: post.isCommunityFavorite,
            upvotesCount: post.hasUserVoted && post.userVoteType == 'upvote'
                ? post.upvotesCount - 1
                : post.upvotesCount + 1,
            downvotesCount: post.hasUserVoted && post.userVoteType == 'downvote'
                ? post.downvotesCount - 1
                : post.downvotesCount,
            netVotes:
                post.netVotes +
                (post.hasUserVoted && post.userVoteType == 'upvote'
                    ? -1
                    : post.hasUserVoted && post.userVoteType == 'downvote'
                    ? 2
                    : 1),
            hasUserVoted: !(post.hasUserVoted && post.userVoteType == 'upvote'),
            userVoteType: post.hasUserVoted && post.userVoteType == 'upvote'
                ? null
                : 'upvote',
            isAutoHidden: post.isAutoHidden,
            isFlagged: post.isFlagged,
            createdAt: post.createdAt,
            updatedAt: post.updatedAt,
            user: post.user,
          );
        } else {
          return ForumPost(
            id: post.id,
            forumId: post.forumId,
            userId: post.userId,
            content: post.content,
            isAcceptedAnswer: post.isAcceptedAnswer,
            isCommunityFavorite: post.isCommunityFavorite,
            upvotesCount: post.hasUserVoted && post.userVoteType == 'upvote'
                ? post.upvotesCount - 1
                : post.upvotesCount,
            downvotesCount: post.hasUserVoted && post.userVoteType == 'downvote'
                ? post.downvotesCount - 1
                : post.downvotesCount + 1,
            netVotes:
                post.netVotes +
                (post.hasUserVoted && post.userVoteType == 'downvote'
                    ? 1
                    : post.hasUserVoted && post.userVoteType == 'upvote'
                    ? -2
                    : -1),
            hasUserVoted:
                !(post.hasUserVoted && post.userVoteType == 'downvote'),
            userVoteType: post.hasUserVoted && post.userVoteType == 'downvote'
                ? null
                : 'downvote',
            isAutoHidden: post.isAutoHidden,
            isFlagged: post.isFlagged,
            createdAt: post.createdAt,
            updatedAt: post.updatedAt,
            user: post.user,
          );
        }
      }).toList();
      emit(state.copyWith(posts: updatedPosts));
    } catch (_) {}
  }

  Future<void> _onLikeToggled(
    ForumLikeToggled event,
    Emitter<ForumState> emit,
  ) async {
    final currentDetail = state.detail;
    if (currentDetail != null && currentDetail.slug == event.slug) {
      final isLiked = !currentDetail.isLiked;
      final likesCount = currentDetail.likesCount + (isLiked ? 1 : -1);
      final updatedDetail = currentDetail.copyWith(
        isLiked: isLiked,
        likesCount: likesCount,
      );
      emit(state.copyWith(detail: updatedDetail));

      try {
        await _repository.toggleLike(event.slug);
      } catch (_) {
        // Revert on failure
        emit(state.copyWith(detail: currentDetail));
      }
    } else {
      try {
        await _repository.toggleLike(event.slug);
      } catch (_) {}
    }
  }

  Future<void> _onSearchRequested(
    ForumSearchRequested event,
    Emitter<ForumState> emit,
  ) async {
    add(
      ForumListRequested(
        refresh: true,
        updateFilters: true,
        search: event.query,
        categoryId: _categoryId,
        circle: _circle,
      ),
    );
  }
}
