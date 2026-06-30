import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/error_message.dart';
import '../../../domain/repositories/article_repository.dart';
import 'article_event.dart';
import 'article_state.dart';

class ArticleBloc extends Bloc<ArticleEvent, ArticleState> {
  final ArticleRepository _repository;

  ArticleBloc({required ArticleRepository repository})
      : _repository = repository,
        super(const ArticleState.initial()) {
    on<ArticleListRequested>(_onListRequested);
    on<ArticleLoadMoreRequested>(_onLoadMore);
    on<ArticleDetailRequested>(_onDetailRequested);
    on<ArticleCategoriesRequested>(_onCategoriesRequested);
    on<ArticleCategorySelected>(_onCategorySelected);
    on<ArticleSearchRequested>(_onSearchRequested);
  }

  Future<void> _onListRequested(
    ArticleListRequested event,
    Emitter<ArticleState> emit,
  ) async {
    emit(state.copyWith(
      status: ArticleStatus.loading,
      items: event.refresh ? const [] : state.items,
      page: 1,
    ));

    try {
      final items = await _repository.getArticles(
        page: 1,
        limit: state.limit,
        categoryId: event.categoryId ?? state.selectedCategoryId,
      );
      emit(state.copyWith(
        status: ArticleStatus.listSuccess,
        items: items,
        total: items.length,
        page: 1,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ArticleStatus.failure,
        errorMessage: ErrorMessage.from(e, 'Gagal memuat artikel'),
      ));
    }
  }

  Future<void> _onLoadMore(
    ArticleLoadMoreRequested event,
    Emitter<ArticleState> emit,
  ) async {
    if (!state.hasNextPage || state.isLoadMore) return;
    emit(state.copyWith(status: ArticleStatus.loadMore));

    try {
      final nextPage = state.page + 1;
      final items = await _repository.getArticles(
        page: nextPage,
        limit: state.limit,
        categoryId: state.selectedCategoryId,
      );
      emit(state.copyWith(
        status: ArticleStatus.listSuccess,
        items: [...state.items, ...items],
        page: nextPage,
      ));
    } catch (_) {
      emit(state.copyWith(status: ArticleStatus.listSuccess));
    }
  }

  Future<void> _onDetailRequested(
    ArticleDetailRequested event,
    Emitter<ArticleState> emit,
  ) async {
    emit(state.copyWith(status: ArticleStatus.detailLoading));
    try {
      final article = await _repository.getArticle(event.slug);
      emit(state.copyWith(status: ArticleStatus.detailSuccess, detail: article));
    } catch (e) {
      emit(state.copyWith(
        status: ArticleStatus.failure,
        errorMessage: ErrorMessage.from(e, 'Gagal memuat artikel'),
      ));
    }
  }

  Future<void> _onCategoriesRequested(
    ArticleCategoriesRequested event,
    Emitter<ArticleState> emit,
  ) async {
    try {
      final categories = await _repository.getCategories();
      emit(state.copyWith(categories: categories));
    } catch (_) {}
  }

  Future<void> _onCategorySelected(
    ArticleCategorySelected event,
    Emitter<ArticleState> emit,
  ) async {
    if (event.categoryId == state.selectedCategoryId) {
      emit(state.copyWith(clearCategory: true));
    } else {
      emit(state.copyWith(selectedCategoryId: event.categoryId));
    }
    add(ArticleListRequested(refresh: true, categoryId: event.categoryId));
  }

  Future<void> _onSearchRequested(
    ArticleSearchRequested event,
    Emitter<ArticleState> emit,
  ) async {
    emit(state.copyWith(status: ArticleStatus.loading, items: const []));
    try {
      final items = await _repository.getArticles(search: event.query);
      emit(state.copyWith(status: ArticleStatus.listSuccess, items: items, total: items.length));
    } catch (e) {
      emit(state.copyWith(
        status: ArticleStatus.failure,
        errorMessage: ErrorMessage.from(e, 'Gagal mencari artikel'),
      ));
    }
  }
}