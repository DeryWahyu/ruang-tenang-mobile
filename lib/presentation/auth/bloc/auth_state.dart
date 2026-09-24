import 'package:equatable/equatable.dart';
import '../../../domain/entities/user.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  failure,
  verificationRequired,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;
  final String? successMessage;
  final String? verificationToken;
  final bool phoneRequired;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.successMessage,
    this.verificationToken,
    this.phoneRequired = false,
  });

  const AuthState.initial() : this(status: AuthStatus.initial);

  const AuthState.loading() : this(status: AuthStatus.loading);

  const AuthState.authenticated(User user)
    : this(status: AuthStatus.authenticated, user: user);

  const AuthState.unauthenticated() : this(status: AuthStatus.unauthenticated);

  const AuthState.failure(String message)
    : this(status: AuthStatus.failure, errorMessage: message);

  const AuthState.verificationRequired(String challenge, bool phoneRequired)
    : this(
        status: AuthStatus.verificationRequired,
        verificationToken: challenge,
        phoneRequired: phoneRequired,
      );

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
    String? successMessage,
    String? verificationToken,
    bool? phoneRequired,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
      successMessage: successMessage,
      verificationToken: verificationToken ?? this.verificationToken,
      phoneRequired: phoneRequired ?? this.phoneRequired,
    );
  }

  bool get isLoading => status == AuthStatus.loading;
  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isUnauthenticated => status == AuthStatus.unauthenticated;

  @override
  List<Object?> get props => [
    status,
    user,
    errorMessage,
    successMessage,
    verificationToken,
    phoneRequired,
  ];
}
