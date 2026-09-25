import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../models/story_model.dart';

class StoryRemoteDataSource {
  final ApiClient _apiClient;

  StoryRemoteDataSource(this._apiClient);

  Future<List<StoryCategoryModel>> getCategories() async {
    final response = await _apiClient.get<List<StoryCategoryModel>>(
      '${ApiConstants.stories}/categories',
      fromJson: (json) => (json as List)
          .map(
            (item) => StoryCategoryModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
    );
    return response.data ?? [];
  }

  Future<List<StoryCardModel>> getMyStories({
    int page = 1,
    String? status,
  }) async {
    final response = await _apiClient.getPaginated<StoryCardModel>(
      '${ApiConstants.stories}/my-stories',
      queryParameters: {
        'page': page,
        'limit': 10,
        if (status != null && status.isNotEmpty) 'status': status,
      },
      fromJson: StoryCardModel.fromJson,
    );
    return response.data;
  }

  Future<StoryModel> saveStory({
    String? id,
    required Map<String, dynamic> data,
  }) async {
    final response = id == null
        ? await _apiClient.post<Map<String, dynamic>>(
            ApiConstants.stories,
            data: data,
            fromJson: (json) => Map<String, dynamic>.from(json as Map),
          )
        : await _apiClient.put<Map<String, dynamic>>(
            '${ApiConstants.stories}/$id',
            data: data,
            fromJson: (json) => Map<String, dynamic>.from(json as Map),
          );
    if (!response.success || response.data == null) {
      throw Exception(response.error ?? 'Kisah belum berhasil disimpan');
    }
    return StoryModel.fromJson(response.data!);
  }

  Future<void> deleteStory(String id) async {
    final response = await _apiClient.delete<dynamic>(
      '${ApiConstants.stories}/$id',
    );
    if (!response.success) {
      throw Exception(response.error ?? 'Kisah belum berhasil dihapus');
    }
  }

  /// GET /stories
  Future<Map<String, dynamic>> getStories({
    int page = 1,
    int limit = 10,
    String sortBy = 'recent',
    String? categoryId,
    String? search,
  }) async {
    final response = await _apiClient.getPaginated<StoryCardModel>(
      ApiConstants.stories,
      queryParameters: {
        'page': page,
        'limit': limit,
        'sort_by': sortBy,
        if (categoryId != null && categoryId.isNotEmpty)
          'category_id': categoryId,
        if (search != null && search.isNotEmpty) 'search': search,
      },
      fromJson: (json) => StoryCardModel.fromJson(json),
    );

    return {
      'items': response.data,
      'total': response.totalItems,
      'page': response.page,
      'limit': response.limit,
    };
  }

  /// GET /stories/:id
  Future<StoryModel> getStory(String id) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '${ApiConstants.stories}/$id',
      fromJson: (json) => Map<String, dynamic>.from(json as Map),
    );

    if (!response.success || response.data == null) {
      throw Exception(response.error ?? 'Gagal memuat detail cerita');
    }

    return StoryModel.fromJson(response.data!);
  }

  /// POST /stories/:id/heart
  Future<void> toggleHeart(String id) async {
    final response = await _apiClient.post<dynamic>(
      '${ApiConstants.stories}/$id/heart',
    );

    if (!response.success) {
      throw Exception(response.error ?? 'Gagal memberikan apresiasi');
    }
  }

  /// GET /stories/:id/comments
  Future<Map<String, dynamic>> getComments(
    String storyId, {
    int page = 1,
    int limit = 10,
  }) async {
    final body = await _apiClient.fetchBody(
      'GET',
      '${ApiConstants.stories}/$storyId/comments',
      queryParameters: {'page': page, 'limit': limit},
    );

    final data = body['data'] as Map<String, dynamic>? ?? body;
    final commentsList = (data['comments'] as List<dynamic>? ?? [])
        .map(
          (e) =>
              StoryCommentModel.fromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList();

    return {
      'items': commentsList,
      'total': (data['total'] as num?)?.toInt() ?? 0,
      'page': (data['page'] as num?)?.toInt() ?? page,
      'limit': (data['limit'] as num?)?.toInt() ?? limit,
    };
  }

  /// POST /stories/:id/comments
  Future<StoryCommentModel> createComment(
    String storyId,
    String content,
  ) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '${ApiConstants.stories}/$storyId/comments',
      data: {'content': content},
      fromJson: (json) => Map<String, dynamic>.from(json as Map),
    );

    if (!response.success || response.data == null) {
      throw Exception(response.error ?? 'Gagal mengirim komentar');
    }

    return StoryCommentModel.fromJson(response.data!);
  }

  /// POST /stories/comments/:id/heart
  Future<void> toggleCommentHeart(String storyId, String commentId) async {
    final response = await _apiClient.post<dynamic>(
      '${ApiConstants.stories}/$storyId/comments/$commentId/heart',
      data: {},
      fromJson: (json) => json,
    );

    if (!response.success) {
      throw Exception(response.error ?? 'Gagal memproses permintaan');
    }
  }
}
