import 'package:equatable/equatable.dart';
import '../../../domain/entities/forum.dart';

enum ForumStatus { initial, loading, listSuccess, detailLoading, detailSuccess, submitting, success, failure }

class ForumState extends Equatable {
  final ForumStatus status;
  final List<ForumThread> threads;
  final List<ForumCategory> categories;
  final ForumThread? detail;
  final List<ForumPost> posts;
  final String errorMessage;
  final String successMessage;
  final String sortBy;

  const ForumState({
    this.status = ForumStatus.initial,
    this.threads = const [],
    this.categories = const [],
    this.detail,
    this.posts = const [],
    this.errorMessage = '',
    this.successMessage = '',
    this.sortBy = 'newest',
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
    );
  }

  @override
  List<Object?> get props => [status, threads, categories, detail, posts, errorMessage, successMessage, sortBy];
}