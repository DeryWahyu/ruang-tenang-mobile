import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../domain/repositories/billing_repository.dart';
import 'billing_event.dart';
import 'billing_state.dart';

class BillingBloc extends Bloc<BillingEvent, BillingState> {
  final BillingRepository _repository;

  BillingBloc({required BillingRepository repository})
      : _repository = repository,
        super(const BillingState.initial()) {
    on<BillingCatalogRequested>(_onCatalogRequested);
    on<BillingCheckoutRequested>(_onCheckoutRequested);
  }

  Future<void> _onCatalogRequested(BillingCatalogRequested event, Emitter<BillingState> emit) async {
    emit(state.copyWith(status: BillingStatus.loading));
    try {
      final catalog = await _repository.getCatalog();
      emit(state.copyWith(status: BillingStatus.success, catalog: catalog));
    } on ApiException catch (e) {
      emit(state.copyWith(status: BillingStatus.failure, errorMessage: e.message));
    } catch (_) {
      emit(state.copyWith(status: BillingStatus.failure, errorMessage: 'Gagal memuat katalog'));
    }
  }

  Future<void> _onCheckoutRequested(BillingCheckoutRequested event, Emitter<BillingState> emit) async {
    emit(state.copyWith(status: BillingStatus.submitting));
    try {
      final result = await _repository.createCheckout(event.itemType, event.itemId);
      emit(state.copyWith(status: BillingStatus.checkoutSuccess, checkoutResult: result));
    } on ApiException catch (e) {
      emit(state.copyWith(status: BillingStatus.failure, errorMessage: e.message));
    } catch (_) {
      emit(state.copyWith(status: BillingStatus.failure, errorMessage: 'Gagal memproses pembayaran'));
    }
  }
}