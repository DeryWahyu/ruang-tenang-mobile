import 'package:equatable/equatable.dart';

abstract class ArticleEvent extends Equatable {
  const ArticleEvent();
  @override
  List<Object?> get props => [];
}

class ArticleListRequested extends ArticleEvent {
  final bool refresh;
  final int? categoryId;
  const ArticleListRequested({this.refresh = false, this.categoryId});
  @override
  List<Object?> get props => [refresh, categoryId];
}

class ArticleLoadMoreRequested extends ArticleEvent {
  const ArticleLoadMoreRequested();
}

class ArticleDetailRequested extends ArticleEvent {
  final String slug;
  const ArticleDetailRequested(this.slug);
  @override
  List<Object?> get props => [slug];
}

class ArticleCategoriesRequested extends ArticleEvent {
  const ArticleCategoriesRequested();
}

class ArticleCategorySelected extends ArticleEvent {
  final int? categoryId;
  const ArticleCategorySelected(this.categoryId);
  @override
  List<Object?> get props => [categoryId];
}

class ArticleSearchRequested extends ArticleEvent {
  final String query;
  const ArticleSearchRequested(this.query);
  @override
  List<Object?> get props => [query];
}