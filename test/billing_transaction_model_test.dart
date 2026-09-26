import 'package:flutter_test/flutter_test.dart';
import 'package:ruang_tenang_mobile/data/models/billing_model.dart';

void main() {
  test('parses Duitku payment reference and URL', () {
    final transaction = BillingTransactionModel.fromJson({
      'id': 12,
      'order_id': 'RT-12-12345',
      'item_type': 'subscription',
      'item_name': 'Premium 30 hari',
      'amount': 25000,
      'currency': 'IDR',
      'status': 'pending',
      'payment_provider': 'duitku',
      'provider_reference': 'DUITKU-REF-123',
      'payment_url':
          'https://app-sandbox.duitku.com/redirect_checkout?reference=DUITKU-REF-123',
      'created_at': '2026-09-26T10:00:00Z',
    });

    expect(transaction.paymentProvider, 'duitku');
    expect(transaction.providerReference, 'DUITKU-REF-123');
    expect(
      transaction.paymentUrl,
      'https://app-sandbox.duitku.com/redirect_checkout?reference=DUITKU-REF-123',
    );
  });
}
