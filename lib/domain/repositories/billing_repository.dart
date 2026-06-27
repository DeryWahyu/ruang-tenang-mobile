import '../entities/billing.dart';

abstract class BillingRepository {
  Future<BillingCatalog> getCatalog();
  Future<Map<String, dynamic>> createCheckout(String itemType, int itemId);
}