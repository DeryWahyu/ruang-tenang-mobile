import 'package:equatable/equatable.dart';

abstract class ForumEvent extends Equatable {
  const ForumEvent();
  @override
  List<Object?> get props => [];
}

class ForumListRequested extends ForumEvent {
  final bool refresh;
  final String? search;
  final int? categoryId;
  final String? circle;
  final bool updateFilters;
  const ForumListRequested({
    this.refresh = false,
    this.search,
    this.categoryId,
    this.circle,
    this.updateFilters = false,
  });
  @override
  List<Object?> get props => [
    refresh,
    search,
    categoryId,
    circle,
    updateFilters,
  ];
}

class ForumLoadMoreRequested extends ForumEvent {
  const ForumLoadMoreRequested();
}

class ForumCategoriesRequested extends ForumEvent {
  const ForumCategoriesRequested();
}

class ForumDetailRequested extends ForumEvent {
  final String slug;
  const ForumDetailRequested(this.slug);
  @override
  List<Object?> get props => [slug];
}

class ForumPostsRequested extends ForumEvent {
  final String slug;
  final String sortBy;
  const ForumPostsRequested(this.slug, {this.sortBy = 'newest'});
  @override
  List<Object?> get props => [slug, sortBy];
}

class ForumPostsLoadMoreRequested extends ForumEvent {
  final String slug;
  const ForumPostsLoadMoreRequested(this.slug);
  @override
  List<Object?> get props => [slug];
}

class ForumCreateRequested extends ForumEvent {
  final String title;
  final String content;
  final int? categoryId;
  const ForumCreateRequested({
    required this.title,
    required this.content,
    this.categoryId,
  });
  @override
  List<Object?> get props => [title, content, categoryId];
}

class ForumPostCreateRequested extends ForumEvent {
  final String slug;
  final String content;
  const ForumPostCreateRequested({required this.slug, required this.content});
  @override
  List<Object?> get props => [slug, content];
}

class ForumPostVoteRequested extends ForumEvent {
  final int postId;
  final String voteType;
  const ForumPostVoteRequested({required this.postId, required this.voteType});
  @override
  List<Object?> get props => [postId, voteType];
}

class ForumLikeToggled extends ForumEvent {
  final String slug;
  const ForumLikeToggled(this.slug);
  @override
  List<Object?> get props => [slug];
}

class ForumSearchRequested extends ForumEvent {
  final String query;
  const ForumSearchRequested(this.query);
  @override
  List<Object?> get props => [query];
}
