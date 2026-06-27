import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../models/billing_model.dart';

class BillingRemoteDataSource {
  final ApiClient _apiClient;

  BillingRemoteDataSource(this._apiClient);

  Future<BillingCatalogModel> getCatalog() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.billing + '/catalog',
      fromJson: (json) => Map<String, dynamic>.from(json as Map),
    );
    if (!response.success || response.data == null) {
      throw Exception(response.error ?? 'Gagal memuat katalog');
    }
    return BillingCatalogModel.fromJson(response.data!);
  }

  Future<Map<String, dynamic>> createCheckout(String itemType, int itemId) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.billing + '/checkout',
      data: {
        'item_type': itemType,
        'item_id': itemId,
      },
      fromJson: (json) => Map<String, dynamic>.from(json as Map),
    );
    if (!response.success || response.data == null) {
      throw Exception(response.error ?? 'Gagal membuat checkout');
    }
    return response.data!;
  }
}