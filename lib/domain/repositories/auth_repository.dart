import '../entities/user.dart';

class PhoneVerificationRequired implements Exception {
  final String challenge;
  final bool phoneRequired;
  const PhoneVerificationRequired(this.challenge, this.phoneRequired);
}

/// Abstract repository interface for auth (domain layer).
///
/// Implemented by [AuthRepositoryImpl] in the data layer. Returns
/// domain entities — the data layer handles JSON/cache mapping.
abstract class AuthRepository {
  Future<User> login({required String email, required String password});
  Future<void> setVerificationPhone({
    required String challenge,
    required String whatsappNumber,
  });
  Future<User> verifyPhone({required String challenge, required String code});
  Future<User> register({
    required String name,
    required String email,
    required String whatsappNumber,
    required String password,
  });
  Future<String> forgotPassword({required String email});
  Future<String> resetPassword({
    required String token,
    required String password,
    required String passwordConfirmation,
  });
  Future<User> getProfile();
  Future<User> updateProfile({
    String? name,
    String? whatsappNumber,
    String? avatar,
    String? bio,
    String? tagline,
  });
  Future<String> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  });
  Future<void> logout();
  Future<bool> isAuthenticated();
  Future<User?> getCachedUser();
}
