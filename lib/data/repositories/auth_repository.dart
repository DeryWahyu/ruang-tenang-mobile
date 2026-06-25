import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/constants/storage_keys.dart';
import '../models/user_model.dart';
import '../datasources/remote/auth_remote_datasource.dart';

class AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final FlutterSecureStorage _secureStorage;

  AuthRepository({
    required AuthRemoteDataSource remoteDataSource,
    required FlutterSecureStorage secureStorage,
  })  : _remoteDataSource = remoteDataSource,
        _secureStorage = secureStorage;

  /// Login and save token
  Future<User> login({
    required String email,
    required String password,
  }) async {
    final data = await _remoteDataSource.login(
      email: email,
      password: password,
    );

    final token = data['token'] as String?;
    final userData = data['user'] as Map<String, dynamic>?;

    if (token == null || userData == null) {
      throw Exception('Response login tidak valid');
    }

    // Save token
    await _secureStorage.write(key: StorageKeys.authToken, value: token);

    // Save user data
    final user = User.fromJson(userData);
    await _secureStorage.write(
      key: StorageKeys.userData,
      value: jsonEncode(user.toJson()),
    );

    return user;
  }

  /// Register new account
  Future<User> register({
    required String name,
    required String email,
    required String password,
  }) async {
    return await _remoteDataSource.register(
      name: name,
      email: email,
      password: password,
    );
  }

  /// Forgot password
  Future<String> forgotPassword({required String email}) async {
    return await _remoteDataSource.forgotPassword(email: email);
  }

  /// Reset password
  Future<String> resetPassword({
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    return await _remoteDataSource.resetPassword(
      token: token,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
  }

  /// Get current user profile
  Future<User> getProfile() async {
    final user = await _remoteDataSource.getProfile();

    // Update cached user data
    await _secureStorage.write(
      key: StorageKeys.userData,
      value: jsonEncode(user.toJson()),
    );

    return user;
  }

  /// Update profile
  Future<User> updateProfile({
    String? name,
    String? avatar,
    String? bio,
    String? tagline,
  }) async {
    final user = await _remoteDataSource.updateProfile(
      name: name,
      avatar: avatar,
      bio: bio,
      tagline: tagline,
    );

    // Update cached user data
    await _secureStorage.write(
      key: StorageKeys.userData,
      value: jsonEncode(user.toJson()),
    );

    return user;
  }

  /// Update password
  Future<String> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    return await _remoteDataSource.updatePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      newPasswordConfirmation: newPasswordConfirmation,
    );
  }

  /// Logout
  Future<void> logout() async {
    await _secureStorage.delete(key: StorageKeys.authToken);
    await _secureStorage.delete(key: StorageKeys.userData);
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await _secureStorage.read(key: StorageKeys.authToken);
    return token != null && token.isNotEmpty;
  }

  /// Get cached user data (without network call)
  Future<User?> getCachedUser() async {
    final userData = await _secureStorage.read(key: StorageKeys.userData);
    if (userData == null) return null;

    try {
      final json = jsonDecode(userData) as Map<String, dynamic>;
      return User.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  /// Get stored token
  Future<String?> getToken() async {
    return await _secureStorage.read(key: StorageKeys.authToken);
  }
}
