import '../entities/article.dart';

abstract class ArticleRepository {
  Future<List<ArticleListItem>> getArticles({
    int page = 1,
    int limit = 10,
    int? categoryId,
    String? search,
  });
  Future<Article> getArticle(String slug);
  Future<List<ArticleCategory>> getCategories();
}