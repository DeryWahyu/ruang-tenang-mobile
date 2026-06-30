import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../models/journal_model.dart';

/// Remote data source for Journal endpoints.
///
/// Note: Journal endpoints do NOT use the standard `{success, data}`
/// envelope. They return `{data: T}` for single items and
/// `{data: [...], total, page, limit}` for the list, with DELETE
/// returning just `{message}`. We therefore use [ApiClient.fetchBody]
/// which returns the raw JSON body.
class JournalRemoteDataSource {
  final ApiClient _apiClient;

  JournalRemoteDataSource(this._apiClient);

  /// GET /journals?page=&limit=&tags=&start_date=&end_date=&mood=
  Future<JournalListResultModel> list({
    int page = 1,
    int limit = 10,
    List<String>? tags,
    DateTime? startDate,
    DateTime? endDate,
    int? moodId,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (tags != null && tags.isNotEmpty) 'tags': tags.join(','),
      if (startDate != null) 'start_date': _formatDate(startDate),
      if (endDate != null) 'end_date': _formatDate(endDate),
      'mood': ?moodId,
    };

    final body = await _apiClient.fetchBody(
      'GET',
      ApiConstants.journals,
      queryParameters: query,
    );

    return JournalListResultModel.fromJson(body);
  }

  /// GET /journals/search?q=&limit=
  Future<List<JournalListItemModel>> search({
    required String query,
    int limit = 10,
  }) async {
    final body = await _apiClient.fetchBody(
      'GET',
      ApiConstants.journalSearch,
      queryParameters: {'q': query, 'limit': limit},
    );

    final data = body['data'];
    if (data is! List) return const [];
    return data
        .map((e) => JournalListItemModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// GET /journals/:uuid
  Future<JournalModel> getByUuid(String uuid) async {
    final body = await _apiClient.fetchBody(
      'GET',
      '${ApiConstants.journals}/$uuid',
    );
    return JournalModel.fromJson(Map<String, dynamic>.from(body['data'] as Map));
  }

  /// POST /journals
  Future<JournalModel> create({
    required String title,
    required String content,
    int? moodId,
    List<String>? tags,
    bool? isPrivate,
    bool? shareWithAI,
  }) async {
    final body = await _apiClient.fetchBody(
      'POST',
      ApiConstants.journals,
      data: {
        'title': title,
        'content': content,
        'mood_id': ?moodId,
        if (tags != null && tags.isNotEmpty) 'tags': tags,
        'is_private': ?isPrivate,
        'share_with_ai': ?shareWithAI,
      },
    );
    return JournalModel.fromJson(Map<String, dynamic>.from(body['data'] as Map));
  }

  /// PUT /journals/:uuid (partial update — only non-null fields sent)
  Future<JournalModel> update({
    required String uuid,
    String? title,
    String? content,
    int? moodId,
    List<String>? tags,
    bool? isPrivate,
    bool? shareWithAI,
  }) async {
    final body = await _apiClient.fetchBody(
      'PUT',
      '${ApiConstants.journals}/$uuid',
      data: {
        'title': ?title,
        'content': ?content,
        'mood_id': ?moodId,
        'tags': ?tags,
        'is_private': ?isPrivate,
        'share_with_ai': ?shareWithAI,
      },
    );
    return JournalModel.fromJson(Map<String, dynamic>.from(body['data'] as Map));
  }

  /// DELETE /journals/:uuid (returns `{message}`)
  Future<void> delete(String uuid) async {
    await _apiClient.fetchBody('DELETE', '${ApiConstants.journals}/$uuid');
  }

  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
