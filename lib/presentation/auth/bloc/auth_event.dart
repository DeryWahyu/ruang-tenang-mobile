import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Check if user is already logged in (on app start)
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Login
class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

/// Register
class AuthRegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;

  const AuthRegisterRequested({
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [name, email, password];
}

/// Forgot password
class AuthForgotPasswordRequested extends AuthEvent {
  final String email;

  const AuthForgotPasswordRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

/// Reset password with token
class AuthResetPasswordRequested extends AuthEvent {
  final String token;
  final String password;
  final String passwordConfirmation;

  const AuthResetPasswordRequested({
    required this.token,
    required this.password,
    required this.passwordConfirmation,
  });

  @override
  List<Object?> get props => [token, password, passwordConfirmation];
}

/// Logout
class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

/// Refresh profile
class AuthProfileRefreshRequested extends AuthEvent {
  const AuthProfileRefreshRequested();
}
