import 'package:equatable/equatable.dart';
import '../../../domain/entities/article.dart';

enum ArticleStatus { initial, loading, loadMore, listSuccess, detailLoading, detailSuccess, failure }

class ArticleState extends Equatable {
  final ArticleStatus status;
  final List<ArticleListItem> items;
  final List<ArticleCategory> categories;
  final Article? detail;
  final int? selectedCategoryId;
  final int page;
  final int limit;
  final int total;
  final String errorMessage;

  const ArticleState({
    this.status = ArticleStatus.initial,
    this.items = const [],
    this.categories = const [],
    this.detail,
    this.selectedCategoryId,
    this.page = 1,
    this.limit = 10,
    this.total = 0,
    this.errorMessage = '',
  });

  const ArticleState.initial() : this();

  bool get hasNextPage => page * limit < total;
  bool get isLoadMore => status == ArticleStatus.loadMore;

  ArticleState copyWith({
    ArticleStatus? status,
    List<ArticleListItem>? items,
    List<ArticleCategory>? categories,
    Article? detail,
    int? selectedCategoryId,
    bool clearCategory = false,
    int? page,
    int? limit,
    int? total,
    String? errorMessage,
  }) {
    return ArticleState(
      status: status ?? this.status,
      items: items ?? this.items,
      categories: categories ?? this.categories,
      detail: detail ?? this.detail,
      selectedCategoryId: clearCategory ? null : (selectedCategoryId ?? this.selectedCategoryId),
      page: page ?? this.page,
      limit: limit ?? this.limit,
      total: total ?? this.total,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, items, categories, detail, selectedCategoryId, page, limit, total, errorMessage];
}