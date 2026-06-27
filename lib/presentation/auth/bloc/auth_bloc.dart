import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../domain/usecases/auth/auth_usecases.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthUseCases _useCases;

  AuthBloc({required AuthUseCases authUseCases})
      : _useCases = authUseCases,
        super(const AuthState.initial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthForgotPasswordRequested>(_onForgotPasswordRequested);
    on<AuthResetPasswordRequested>(_onResetPasswordRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthProfileRefreshRequested>(_onProfileRefreshRequested);
  }

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final user = await _useCases.checkAuthStatus();
      if (user != null) {
        emit(AuthState.authenticated(user));
        // Refresh profile in background.
        try {
          final freshUser = await _useCases.getProfile();
          emit(AuthState.authenticated(freshUser));
        } catch (_) {
          // Keep cached user if refresh fails.
        }
        return;
      }
      emit(const AuthState.unauthenticated());
    } catch (_) {
      emit(const AuthState.unauthenticated());
    }
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    try {
      final user = await _useCases.login(
        email: event.email,
        password: event.password,
      );
      emit(AuthState.authenticated(user));
    } on ApiException catch (e) {
      emit(AuthState.failure(e.message));
    } catch (e) {
      emit(AuthState.failure('Login gagal. Periksa email dan password Anda.'));
    }
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    try {
      await _useCases.register(
        name: event.name,
        email: event.email,
        password: event.password,
      );
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        successMessage: 'Registrasi berhasil! Silakan login.',
      ));
    } on ApiException catch (e) {
      emit(AuthState.failure(e.message));
    } catch (e) {
      emit(AuthState.failure('Registrasi gagal. Silakan coba lagi.'));
    }
  }

  Future<void> _onForgotPasswordRequested(
    AuthForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    try {
      final message = await _useCases.forgotPassword(email: event.email);
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        successMessage: message,
      ));
    } on ApiException catch (e) {
      emit(AuthState.failure(e.message));
    } catch (e) {
      emit(AuthState.failure('Gagal mengirim link reset password.'));
    }
  }

  Future<void> _onResetPasswordRequested(
    AuthResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    try {
      final message = await _useCases.resetPassword(
        token: event.token,
        password: event.password,
        passwordConfirmation: event.passwordConfirmation,
      );
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        successMessage: message,
      ));
    } on ApiException catch (e) {
      emit(AuthState.failure(e.message));
    } catch (e) {
      emit(AuthState.failure('Gagal mereset password. Silakan coba lagi.'));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _useCases.logout();
    emit(const AuthState.unauthenticated());
  }

  Future<void> _onProfileRefreshRequested(
    AuthProfileRefreshRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final user = await _useCases.getProfile();
      emit(AuthState.authenticated(user));
    } catch (_) {
      // Keep current state if refresh fails.
    }
  }
}
