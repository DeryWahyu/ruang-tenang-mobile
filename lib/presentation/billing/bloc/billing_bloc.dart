import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/error_message.dart';
import '../../../domain/repositories/billing_repository.dart';
import 'billing_event.dart';
import 'billing_state.dart';

class BillingBloc extends Bloc<BillingEvent, BillingState> {
  final BillingRepository _repository;
  static const _pageLimit = 20;

  BillingBloc({required BillingRepository repository})
      : _repository = repository,
        super(const BillingState.initial()) {
    on<BillingCatalogRequested>(_onCatalogRequested);
    on<BillingCheckoutRequested>(_onCheckoutRequested);
    on<BillingStatusRequested>(_onStatusRequested);
    on<BillingTransactionsRequested>(_onTransactionsRequested);
    on<BillingTransactionsLoadMore>(_onTransactionsLoadMore);
    on<BillingTransactionsFilterChanged>(_onFilterChanged);
  }

  Future<void> _onCatalogRequested(BillingCatalogRequested event, Emitter<BillingState> emit) async {
    emit(state.copyWith(status: BillingStatusEnum.loading));
    try {
      final catalog = await _repository.getCatalog();
      emit(state.copyWith(status: BillingStatusEnum.success, catalog: catalog));
    } catch (e) {
      emit(state.copyWith(
        status: BillingStatusEnum.failure,
        errorMessage: ErrorMessage.from(e, 'Gagal memuat katalog'),
      ));
    }
  }

  Future<void> _onCheckoutRequested(BillingCheckoutRequested event, Emitter<BillingState> emit) async {
    emit(state.copyWith(status: BillingStatusEnum.submitting));
    try {
      final result = await _repository.createCheckout(event.itemType, event.itemId);
      emit(state.copyWith(status: BillingStatusEnum.checkoutSuccess, checkoutResult: result));
    } catch (e) {
      emit(state.copyWith(
        status: BillingStatusEnum.failure,
        errorMessage: ErrorMessage.from(e, 'Gagal memproses pembayaran'),
      ));
    }
  }

  /// Muat status billing (premium/koin/kuota) — non-fatal untuk alur katalog.
  Future<void> _onStatusRequested(BillingStatusRequested event, Emitter<BillingState> emit) async {
    try {
      final billingStatus = await _repository.getStatus();
      emit(state.copyWith(billingStatus: billingStatus));
    } catch (_) {
      // Status bersifat pelengkap; abaikan kegagalan agar katalog tetap tampil.
    }
  }

  Future<void> _onTransactionsRequested(
      BillingTransactionsRequested event, Emitter<BillingState> emit) async {
    final status = event.status ?? state.filterStatus;
    final itemType = event.itemType ?? state.filterItemType;
    emit(state.copyWith(
      transactionsStatus: TransactionsStatus.loading,
      transactions: event.refresh ? const [] : state.transactions,
      transactionsPage: 1,
      filterStatus: status,
      filterItemType: itemType,
    ));
    try {
      final result = await _repository.getTransactions(
        page: 1,
        limit: _pageLimit,
        status: status,
        itemType: itemType,
      );
      emit(state.copyWith(
        transactionsStatus: TransactionsStatus.success,
        transactions: result.transactions,
        transactionsPage: result.page,
        transactionsTotalPages: result.totalPages,
      ));
    } catch (e) {
      emit(state.copyWith(
        transactionsStatus: TransactionsStatus.failure,
        transactionsError: ErrorMessage.from(e, 'Gagal memuat riwayat transaksi'),
      ));
    }
  }

  /// Ganti filter: set filter di state kosong dulu lalu muat ulang.
  Future<void> _onFilterChanged(
      BillingTransactionsFilterChanged event, Emitter<BillingState> emit) async {
    emit(state.copyWith(
      clearFilters: true,
      filterStatus: event.status,
      filterItemType: event.itemType,
    ));
    add(BillingTransactionsRequested(
      refresh: true,
      status: event.status,
      itemType: event.itemType,
    ));
  }

  Future<void> _onTransactionsLoadMore(
      BillingTransactionsLoadMore event, Emitter<BillingState> emit) async {
    if (!state.transactionsHasMore || state.isLoadingMore) return;
    emit(state.copyWith(transactionsStatus: TransactionsStatus.loadingMore));
    try {
      final nextPage = state.transactionsPage + 1;
      final result = await _repository.getTransactions(
        page: nextPage,
        limit: _pageLimit,
        status: state.filterStatus,
        itemType: state.filterItemType,
      );
      emit(state.copyWith(
        transactionsStatus: TransactionsStatus.success,
        transactions: [...state.transactions, ...result.transactions],
        transactionsPage: result.page,
        transactionsTotalPages: result.totalPages,
      ));
    } catch (_) {
      emit(state.copyWith(transactionsStatus: TransactionsStatus.success));
    }
  }
}