import '../entities/billing.dart';

abstract class BillingRepository {
  Future<BillingCatalog> getCatalog();
  Future<Map<String, dynamic>> createCheckout(String itemType, int itemId);
  Future<BillingStatus> getStatus();
  Future<BillingTransactionPage> getTransactions({
    int page,
    int limit,
    String? status,
    String? itemType,
  });
  Future<String> exportTransactionsCsv({String? status, String? itemType});
  Future<String> getInvoiceCsv(String orderId);
}