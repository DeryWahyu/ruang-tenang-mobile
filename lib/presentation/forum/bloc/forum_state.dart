import 'package:equatable/equatable.dart';
import '../../../domain/entities/forum.dart';

enum ForumStatus {
  initial,
  loading,
  listSuccess,
  detailLoading,
  detailSuccess,
  submitting,
  success,
  failure,
}

class ForumState extends Equatable {
  final ForumStatus status;
  final List<ForumThread> threads;
  final List<ForumCategory> categories;
  final ForumThread? detail;
  final List<ForumPost> posts;
  final String errorMessage;
  final String successMessage;
  final String sortBy;
  final int page;
  final bool hasMore;
  final bool loadingMore;
  final int postsPage;
  final bool postsHasMore;
  final bool postsLoadingMore;

  const ForumState({
    this.status = ForumStatus.initial,
    this.threads = const [],
    this.categories = const [],
    this.detail,
    this.posts = const [],
    this.errorMessage = '',
    this.successMessage = '',
    this.sortBy = 'newest',
    this.page = 1,
    this.hasMore = false,
    this.loadingMore = false,
    this.postsPage = 1,
    this.postsHasMore = false,
    this.postsLoadingMore = false,
  });

  const ForumState.initial() : this();

  ForumState copyWith({
    ForumStatus? status,
    List<ForumThread>? threads,
    List<ForumCategory>? categories,
    ForumThread? detail,
    List<ForumPost>? posts,
    String? errorMessage,
    String? successMessage,
    String? sortBy,
    int? page,
    bool? hasMore,
    bool? loadingMore,
    int? postsPage,
    bool? postsHasMore,
    bool? postsLoadingMore,
  }) {
    return ForumState(
      status: status ?? this.status,
      threads: threads ?? this.threads,
      categories: categories ?? this.categories,
      detail: detail ?? this.detail,
      posts: posts ?? this.posts,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
      sortBy: sortBy ?? this.sortBy,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      loadingMore: loadingMore ?? this.loadingMore,
      postsPage: postsPage ?? this.postsPage,
      postsHasMore: postsHasMore ?? this.postsHasMore,
      postsLoadingMore: postsLoadingMore ?? this.postsLoadingMore,
    );
  }

  @override
  List<Object?> get props => [
    status,
    threads,
    categories,
    detail,
    posts,
    errorMessage,
    successMessage,
    sortBy,
    page,
    hasMore,
    loadingMore,
    postsPage,
    postsHasMore,
    postsLoadingMore,
  ];
}
