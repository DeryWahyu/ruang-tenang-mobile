import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../models/search_model.dart';

class SearchRemoteDataSource {
  final ApiClient _apiClient;

  SearchRemoteDataSource(this._apiClient);

  Future<SearchResultModel> searchGlobal(String query) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.search,
      queryParameters: {'q': query},
      fromJson: (json) => Map<String, dynamic>.from(json as Map),
    );
    if (!response.success || response.data == null) {
      throw Exception(response.error ?? 'Pencarian gagal');
    }
    return SearchResultModel.fromJson(response.data!);
  }
}