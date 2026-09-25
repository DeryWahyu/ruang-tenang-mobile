import '../entities/article.dart';

abstract class ArticleRepository {
  Future<List<ArticleListItem>> getMyArticles({int page, String? search});
  Future<Article> getMyArticle(String id);
  Future<void> saveMyArticle({
    String? id,
    required String title,
    required String content,
    required int categoryId,
    String? thumbnail,
  });
  Future<void> deleteMyArticle(String id);
  Future<List<ArticleListItem>> getArticles({
    int page = 1,
    int limit = 10,
    int? categoryId,
    String? search,
  });
  Future<Article> getArticle(String slug);
  Future<List<ArticleCategory>> getCategories();
}
