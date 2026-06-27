import 'check_auth_status_use_case.dart';
import 'forgot_password_use_case.dart';
import 'get_cached_user_use_case.dart';
import 'get_profile_use_case.dart';
import 'login_use_case.dart';
import 'logout_use_case.dart';
import 'register_use_case.dart';
import 'reset_password_use_case.dart';

/// Aggregate of all auth use cases, injected as a single dependency into
/// [AuthBloc] to keep its constructor signature small.
class AuthUseCases {
  final LoginUseCase login;
  final RegisterUseCase register;
  final ForgotPasswordUseCase forgotPassword;
  final ResetPasswordUseCase resetPassword;
  final GetProfileUseCase getProfile;
  final LogoutUseCase logout;
  final CheckAuthStatusUseCase checkAuthStatus;
  final GetCachedUserUseCase getCachedUser;

  const AuthUseCases({
    required this.login,
    required this.register,
    required this.forgotPassword,
    required this.resetPassword,
    required this.getProfile,
    required this.logout,
    required this.checkAuthStatus,
    required this.getCachedUser,
  });
}
