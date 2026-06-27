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