import 'package:equatable/equatable.dart';
import '../../../domain/entities/wellness.dart';

enum WellnessStatus { initial, loading, success, failure, submitting }

class WellnessState extends Equatable {
  final WellnessStatus status;
  final WellnessOnboardingResult? onboardingResult;
  final WellnessPlan? plan;
  final String errorMessage;

  const WellnessState({
    this.status = WellnessStatus.initial,
    this.onboardingResult,
    this.plan,
    this.errorMessage = '',
  });

  const WellnessState.initial() : this();

  WellnessState copyWith({
    WellnessStatus? status,
    WellnessOnboardingResult? onboardingResult,
    WellnessPlan? plan,
    String? errorMessage,
  }) {
    return WellnessState(
      status: status ?? this.status,
      onboardingResult: onboardingResult ?? this.onboardingResult,
      plan: plan ?? this.plan,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, onboardingResult, plan, errorMessage];
}