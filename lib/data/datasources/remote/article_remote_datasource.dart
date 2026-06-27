import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../models/article_model.dart';

class ArticleRemoteDataSource {
  final ApiClient _apiClient;

  ArticleRemoteDataSource(this._apiClient);

  /// GET /articles
  Future<Map<String, dynamic>> getArticles({
    int page = 1,
    int limit = 10,
    int? categoryId,
    String? search,
  }) async {
    final response = await _apiClient.getPaginated<ArticleListItemModel>(
      ApiConstants.articles,
      queryParameters: {
        'page': page,
        'limit': limit,
        if (categoryId != null) 'category_id': categoryId,
        if (search != null && search.isNotEmpty) 'search': search,
      },
      fromJson: (json) => ArticleListItemModel.fromJson(json),
    );

    return {
      'items': response.data,
      'total': response.totalItems,
      'page': response.page,
      'limit': response.limit,
    };
  }

  /// GET /articles/:slug
  Future<ArticleModel> getArticle(String slug) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '${ApiConstants.articles}/$slug',
      fromJson: (json) => Map<String, dynamic>.from(json as Map),
    );

    if (!response.success || response.data == null) {
      throw Exception(response.error ?? 'Gagal memuat detail artikel');
    }

    return ArticleModel.fromJson(response.data!);
  }

  /// GET /article-categories
  Future<List<ArticleCategoryModel>> getCategories() async {
    final response = await _apiClient.get<List<dynamic>>(
      ApiConstants.articleCategories,
      fromJson: (json) => json as List<dynamic>,
    );

    if (!response.success || response.data == null) {
      throw Exception(response.error ?? 'Gagal memuat kategori artikel');
    }

    return response.data!
        .map((e) => ArticleCategoryModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}
