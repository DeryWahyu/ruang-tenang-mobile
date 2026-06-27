import 'package:equatable/equatable.dart';
import '../../../domain/entities/billing.dart';

enum BillingStatus { initial, loading, success, failure, submitting, checkoutSuccess }

class BillingState extends Equatable {
  final BillingStatus status;
  final BillingCatalog? catalog;
  final Map<String, dynamic>? checkoutResult;
  final String errorMessage;

  const BillingState({
    this.status = BillingStatus.initial,
    this.catalog,
    this.checkoutResult,
    this.errorMessage = '',
  });

  const BillingState.initial() : this();

  BillingState copyWith({
    BillingStatus? status,
    BillingCatalog? catalog,
    Map<String, dynamic>? checkoutResult,
    String? errorMessage,
  }) {
    return BillingState(
      status: status ?? this.status,
      catalog: catalog ?? this.catalog,
      checkoutResult: checkoutResult ?? this.checkoutResult,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, catalog, checkoutResult, errorMessage];
}