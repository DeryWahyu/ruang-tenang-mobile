import '../../domain/entities/article.dart';
import '../../domain/repositories/article_repository.dart';
import '../datasources/remote/article_remote_datasource.dart';
import '../models/article_model.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  final ArticleRemoteDataSource _remote;

  ArticleRepositoryImpl({required ArticleRemoteDataSource remote})
    : _remote = remote;

  @override
  Future<List<ArticleListItem>> getMyArticles({
    int page = 1,
    String? search,
  }) async => (await _remote.getMyArticles(
    page: page,
    search: search,
  )).map((item) => item.toEntity()).toList();

  @override
  Future<Article> getMyArticle(String id) async =>
      (await _remote.getMyArticle(id)).toEntity();

  @override
  Future<void> saveMyArticle({
    String? id,
    required String title,
    required String content,
    required int categoryId,
    String? thumbnail,
  }) => _remote.saveMyArticle(
    id: id,
    title: title,
    content: content,
    categoryId: categoryId,
    thumbnail: thumbnail,
  );

  @override
  Future<void> deleteMyArticle(String id) => _remote.deleteMyArticle(id);

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
