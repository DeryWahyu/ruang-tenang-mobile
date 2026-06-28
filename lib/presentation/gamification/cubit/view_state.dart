import 'package:equatable/equatable.dart';

enum ViewStatus { initial, loading, success, failure }

/// Generic view state used by the secondary gamification cubits.
class ViewState<T> extends Equatable {
  final ViewStatus status;
  final T? data;
  final String error;
  final bool submitting;
  final String actionMessage;

  const ViewState({
    this.status = ViewStatus.initial,
    this.data,
    this.error = '',
    this.submitting = false,
    this.actionMessage = '',
  });

  const ViewState.initial() : this();

  ViewState<T> copyWith({
    ViewStatus? status,
    T? data,
    String? error,
    bool? submitting,
    String? actionMessage,
    bool clearMessages = false,
  }) {
    return ViewState<T>(
      status: status ?? this.status,
      data: data ?? this.data,
      error: clearMessages ? '' : (error ?? this.error),
      submitting: submitting ?? this.submitting,
      actionMessage: clearMessages ? '' : (actionMessage ?? this.actionMessage),
    );
  }

  @override
  List<Object?> get props => [status, data, error, submitting, actionMessage];
}
