import '../../domain/entities/article.dart';
import '../../domain/repositories/article_repository.dart';
import '../datasources/remote/article_remote_datasource.dart';
import '../models/article_model.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  final ArticleRemoteDataSource _remote;

  ArticleRepositoryImpl({required ArticleRemoteDataSource remote}) : _remote = remote;

  @override
  Future<List<ArticleListItem>> getArticles({
    int page = 1,
    int limit = 10,
    int? categoryId,
    String? search,
  }) async {
    final result = await _remote.getArticles(
      page: page,
      limit: limit,
      categoryId: categoryId,
      search: search,
    );
    final items = result['items'] as List<ArticleListItemModel>;
    return items.map((e) => e.toEntity()).toList();
  }

  @override
  Future<Article> getArticle(String slug) async {
    final model = await _remote.getArticle(slug);
    return model.toEntity();
  }

  @override
  Future<List<ArticleCategory>> getCategories() async {
    final models = await _remote.getCategories();
    return models.map((e) => e.toEntity()).toList();
  }
}