import 'package:equatable/equatable.dart';

abstract class BillingEvent extends Equatable {
  const BillingEvent();
  @override
  List<Object?> get props => [];
}

class BillingCatalogRequested extends BillingEvent {
  const BillingCatalogRequested();
}

class BillingCheckoutRequested extends BillingEvent {
  final String itemType;
  final int itemId;
  const BillingCheckoutRequested({required this.itemType, required this.itemId});
  @override
  List<Object?> get props => [itemType, itemId];
}

/// Muat status billing (premium, koin, kuota chat).
class BillingStatusRequested extends BillingEvent {
  const BillingStatusRequested();
}

/// Muat halaman pertama riwayat transaksi.
class BillingTransactionsRequested extends BillingEvent {
  final bool refresh;
  final String? status;
  final String? itemType;
  const BillingTransactionsRequested({this.refresh = false, this.status, this.itemType});
  @override
  List<Object?> get props => [refresh, status, itemType];
}

/// Muat halaman berikutnya riwayat transaksi (pagination).
class BillingTransactionsLoadMore extends BillingEvent {
  const BillingTransactionsLoadMore();
}

/// Ubah filter (status/tipe) lalu muat ulang dari halaman pertama.
class BillingTransactionsFilterChanged extends BillingEvent {
  final String? status;
  final String? itemType;
  const BillingTransactionsFilterChanged({this.status, this.itemType});
  @override
  List<Object?> get props => [status, itemType];
}