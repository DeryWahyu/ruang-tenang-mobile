import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../models/forum_model.dart';

class ForumRemoteDataSource {
  final ApiClient _apiClient;

  ForumRemoteDataSource(this._apiClient);

  /// GET /forums
  Future<Map<String, dynamic>> getForums({
    int page = 1,
    int limit = 10,
    String? search,
    int? categoryId,
  }) async {
    final response = await _apiClient.getPaginated<ForumThreadModel>(
      ApiConstants.forums,
      queryParameters: {
        'page': page,
        'limit': limit,
        if (search != null && search.isNotEmpty) 'search': search,
        if (categoryId != null) 'category_id': categoryId,
      },
      fromJson: (json) => ForumThreadModel.fromJson(json),
    );

    return {
      'items': response.data,
      'total': response.totalItems,
      'page': response.page,
      'limit': response.limit,
    };
  }

  /// GET /forums/:slug
  Future<ForumThreadModel> getForum(String slug) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '${ApiConstants.forums}/$slug',
      fromJson: (json) => Map<String, dynamic>.from(json as Map),
    );

    if (!response.success || response.data == null) {
      throw Exception(response.error ?? 'Gagal memuat detail forum');
    }

    return ForumThreadModel.fromJson(response.data!);
  }

  /// POST /forums
  Future<ForumThreadModel> createForum({
    required String title,
    required String content,
    int? categoryId,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.forums,
      data: {
        'title': title,
        'content': content,
        if (categoryId != null) 'category_id': categoryId,
      },
      fromJson: (json) => Map<String, dynamic>.from(json as Map),
    );

    if (!response.success || response.data == null) {
      throw Exception(response.error ?? 'Gagal membuat forum');
    }

    return ForumThreadModel.fromJson(response.data!);
  }

  /// PUT /forums/:id/like
  Future<void> toggleLike(int id) async {
    final response = await _apiClient.put<dynamic>(
      '${ApiConstants.forums}/$id/like',
    );

    if (!response.success) {
      throw Exception(response.error ?? 'Gagal memberikan like');
    }
  }

  /// GET /forum-categories
  Future<List<ForumCategoryModel>> getCategories() async {
    final response = await _apiClient.get<List<dynamic>>(
      ApiConstants.forumCategories,
      fromJson: (json) => json as List<dynamic>,
    );

    if (!response.success || response.data == null) {
      throw Exception(response.error ?? 'Gagal memuat kategori forum');
    }

    return response.data!
        .map((e) => ForumCategoryModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// GET /forums/:slug/posts?page=&limit=&sort_by=
  Future<Map<String, dynamic>> getPosts(
    String slug, {
    int page = 1,
    int limit = 10,
    String sortBy = 'newest',
  }) async {
    final response = await _apiClient.getPaginated<ForumPostModel>(
      '${ApiConstants.forums}/$slug/posts',
      queryParameters: {
        'page': page,
        'limit': limit,
        'sort_by': sortBy,
      },
      fromJson: (json) => ForumPostModel.fromJson(json),
    );

    return {
      'items': response.data,
      'total': response.totalItems,
      'page': response.page,
      'limit': response.limit,
    };
  }

  /// POST /forums/:slug/posts
  Future<ForumPostModel> createPost(String slug, String content) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '${ApiConstants.forums}/$slug/posts',
      data: {'content': content},
      fromJson: (json) => Map<String, dynamic>.from(json as Map),
    );

    if (!response.success || response.data == null) {
      throw Exception(response.error ?? 'Gagal membuat balasan forum');
    }

    return ForumPostModel.fromJson(response.data!);
  }

  /// PUT /posts/:id/upvote
  Future<void> upvotePost(int id) async {
    final response = await _apiClient.put<dynamic>(
      '${ApiConstants.posts}/$id/upvote',
    );

    if (!response.success) {
      throw Exception(response.error ?? 'Gagal memberikan upvote');
    }
  }

  /// PUT /posts/:id/downvote
  Future<void> downvotePost(int id) async {
    final response = await _apiClient.put<dynamic>(
      '${ApiConstants.posts}/$id/downvote',
    );

    if (!response.success) {
      throw Exception(response.error ?? 'Gagal memberikan downvote');
    }
  }

  /// DELETE /posts/:id/vote
  Future<void> removeVote(int id) async {
    final response = await _apiClient.delete<dynamic>(
      '${ApiConstants.posts}/$id/vote',
    );

    if (!response.success) {
      throw Exception(response.error ?? 'Gagal menghapus vote');
    }
  }
}