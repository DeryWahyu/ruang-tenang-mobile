import 'package:equatable/equatable.dart';
import '../../../domain/entities/billing.dart';

enum BillingStatusEnum { initial, loading, success, failure, submitting, checkoutSuccess }

/// Status pemuatan khusus daftar transaksi (terpisah dari alur katalog/checkout).
enum TransactionsStatus { initial, loading, loadingMore, success, failure }

class BillingState extends Equatable {
  final BillingStatusEnum status;
  final BillingCatalog? catalog;
  final Map<String, dynamic>? checkoutResult;
  final String errorMessage;

  // Status billing pengguna (premium/koin/kuota).
  final BillingStatus? billingStatus;

  // Riwayat transaksi + pagination.
  final TransactionsStatus transactionsStatus;
  final List<BillingTransaction> transactions;
  final int transactionsPage;
  final int transactionsTotalPages;
  final String transactionsError;
  final String? filterStatus;
  final String? filterItemType;

  const BillingState({
    this.status = BillingStatusEnum.initial,
    this.catalog,
    this.checkoutResult,
    this.errorMessage = '',
    this.billingStatus,
    this.transactionsStatus = TransactionsStatus.initial,
    this.transactions = const [],
    this.transactionsPage = 1,
    this.transactionsTotalPages = 1,
    this.transactionsError = '',
    this.filterStatus,
    this.filterItemType,
  });

  const BillingState.initial() : this();

  bool get transactionsHasMore => transactionsPage < transactionsTotalPages;
  bool get isLoadingMore => transactionsStatus == TransactionsStatus.loadingMore;

  BillingState copyWith({
    BillingStatusEnum? status,
    BillingCatalog? catalog,
    Map<String, dynamic>? checkoutResult,
    String? errorMessage,
    BillingStatus? billingStatus,
    TransactionsStatus? transactionsStatus,
    List<BillingTransaction>? transactions,
    int? transactionsPage,
    int? transactionsTotalPages,
    String? transactionsError,
    String? filterStatus,
    String? filterItemType,
    bool clearFilters = false,
  }) {
    return BillingState(
      status: status ?? this.status,
      catalog: catalog ?? this.catalog,
      checkoutResult: checkoutResult ?? this.checkoutResult,
      errorMessage: errorMessage ?? this.errorMessage,
      billingStatus: billingStatus ?? this.billingStatus,
      transactionsStatus: transactionsStatus ?? this.transactionsStatus,
      transactions: transactions ?? this.transactions,
      transactionsPage: transactionsPage ?? this.transactionsPage,
      transactionsTotalPages: transactionsTotalPages ?? this.transactionsTotalPages,
      transactionsError: transactionsError ?? this.transactionsError,
      filterStatus: clearFilters ? null : (filterStatus ?? this.filterStatus),
      filterItemType: clearFilters ? null : (filterItemType ?? this.filterItemType),
    );
  }

  @override
  List<Object?> get props => [
        status,
        catalog,
        checkoutResult,
        errorMessage,
        billingStatus,
        transactionsStatus,
        transactions,
        transactionsPage,
        transactionsTotalPages,
        transactionsError,
        filterStatus,
        filterItemType,
      ];
}