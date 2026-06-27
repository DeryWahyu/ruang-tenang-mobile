import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../domain/repositories/wellness_repository.dart';
import 'wellness_event.dart';
import 'wellness_state.dart';

class WellnessBloc extends Bloc<WellnessEvent, WellnessState> {
  final WellnessRepository _repository;

  WellnessBloc({required WellnessRepository repository})
      : _repository = repository,
        super(const WellnessState.initial()) {
    on<WellnessOnboardingRequested>(_onOnboardingRequested);
    on<WellnessOnboardingSubmitted>(_onOnboardingSubmitted);
    on<WellnessPlanRequested>(_onPlanRequested);
    on<WellnessPlanItemCompleted>(_onPlanItemCompleted);
  }

  Future<void> _onOnboardingRequested(WellnessOnboardingRequested event, Emitter<WellnessState> emit) async {
    emit(state.copyWith(status: WellnessStatus.loading));
    try {
      final result = await _repository.getOnboarding();
      emit(state.copyWith(status: WellnessStatus.success, onboardingResult: result));
    } on ApiException catch (e) {
      emit(state.copyWith(status: WellnessStatus.failure, errorMessage: e.message));
    } catch (_) {
      emit(state.copyWith(status: WellnessStatus.failure, errorMessage: 'Gagal memuat status onboarding'));
    }
  }

  Future<void> _onOnboardingSubmitted(WellnessOnboardingSubmitted event, Emitter<WellnessState> emit) async {
    emit(state.copyWith(status: WellnessStatus.submitting));
    try {
      final result = await _repository.completeOnboarding(event.initialMood, event.goals, event.habits);
      emit(state.copyWith(status: WellnessStatus.success, onboardingResult: result, plan: result.plan));
    } on ApiException catch (e) {
      emit(state.copyWith(status: WellnessStatus.failure, errorMessage: e.message));
    } catch (_) {
      emit(state.copyWith(status: WellnessStatus.failure, errorMessage: 'Gagal menyimpan onboarding'));
    }
  }

  Future<void> _onPlanRequested(WellnessPlanRequested event, Emitter<WellnessState> emit) async {
    emit(state.copyWith(status: WellnessStatus.loading));
    try {
      final plan = await _repository.getCurrentPlan();
      emit(state.copyWith(status: WellnessStatus.success, plan: plan));
    } on ApiException catch (e) {
      emit(state.copyWith(status: WellnessStatus.failure, errorMessage: e.message));
    } catch (_) {
      emit(state.copyWith(status: WellnessStatus.failure, errorMessage: 'Gagal memuat rencana kesehatan'));
    }
  }

  Future<void> _onPlanItemCompleted(WellnessPlanItemCompleted event, Emitter<WellnessState> emit) async {
    try {
      await _repository.completePlanItem(event.itemId);
      add(const WellnessPlanRequested());
    } catch (_) {}
  }
}