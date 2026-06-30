import '../../domain/entities/billing.dart';
import '../../domain/repositories/billing_repository.dart';
import '../datasources/remote/billing_remote_datasource.dart';

class BillingRepositoryImpl implements BillingRepository {
  final BillingRemoteDataSource _remote;

  BillingRepositoryImpl({required BillingRemoteDataSource remote}) : _remote = remote;

  @override
  Future<BillingCatalog> getCatalog() async {
    final model = await _remote.getCatalog();
    return model.toEntity();
  }

  @override
  Future<Map<String, dynamic>> createCheckout(String itemType, int itemId) async {
    return _remote.createCheckout(itemType, itemId);
  }

  @override
  Future<BillingStatus> getStatus() => _remote.getStatus();

  @override
  Future<BillingTransactionPage> getTransactions({
    int page = 1,
    int limit = 20,
    String? status,
    String? itemType,
  }) =>
      _remote.getTransactions(page: page, limit: limit, status: status, itemType: itemType);

  @override
  Future<String> exportTransactionsCsv({String? status, String? itemType}) =>
      _remote.exportTransactionsCsv(status: status, itemType: itemType);

  @override
  Future<String> getInvoiceCsv(String orderId) => _remote.getInvoiceCsv(orderId);
}