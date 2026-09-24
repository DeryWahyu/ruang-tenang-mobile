import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/constants/storage_keys.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/remote/auth_remote_datasource.dart';
import '../models/user_model.dart';

/// Data-layer implementation of [AuthRepository].
///
/// Handles secure token/user storage and caches the latest user. Maps
/// [UserModel] (JSON-coupled) to the pure-Dart [User] entity at the
/// boundary via [UserModel.toEntity].
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final FlutterSecureStorage _secureStorage;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required FlutterSecureStorage secureStorage,
  }) : _remoteDataSource = remoteDataSource,
       _secureStorage = secureStorage;

  @override
  Future<User> login({required String email, required String password}) async {
    final data = await _remoteDataSource.login(
      email: email,
      password: password,
    );

    if (data['verification_required'] == true) {
      throw PhoneVerificationRequired(
        data['verification_token'] as String? ?? '',
        data['phone_required'] as bool? ?? false,
      );
    }

    return _storeLogin(data);
  }

  Future<User> _storeLogin(Map<String, dynamic> data) async {
    final token = data['token'] as String?;
    final userData = data['user'] as Map<String, dynamic>?;

    if (token == null || userData == null) {
      throw Exception('Response login tidak valid');
    }

    await _secureStorage.write(key: StorageKeys.authToken, value: token);

    final user = UserModel.fromJson(userData);
    await _secureStorage.write(
      key: StorageKeys.userData,
      value: jsonEncode(user.toJson()),
    );

    return user.toEntity();
  }

  @override
  Future<void> setVerificationPhone({
    required String challenge,
    required String whatsappNumber,
  }) => _remoteDataSource.setVerificationPhone(
    challenge: challenge,
    whatsappNumber: whatsappNumber,
  );

  @override
  Future<User> verifyPhone({
    required String challenge,
    required String code,
  }) async {
    final data = await _remoteDataSource.verifyPhone(
      challenge: challenge,
      code: code,
    );
    return _storeLogin(data);
  }

  @override
  Future<User> register({
    required String name,
    required String email,
    required String whatsappNumber,
    required String password,
  }) async {
    final user = await _remoteDataSource.register(
      name: name,
      email: email,
      whatsappNumber: whatsappNumber,
      password: password,
    );
    return user.toEntity();
  }

  @override
  Future<String> forgotPassword({required String email}) async {
    return await _remoteDataSource.forgotPassword(email: email);
  }

  @override
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

  @override
  Future<User> getProfile() async {
    final user = await _remoteDataSource.getProfile();
    await _secureStorage.write(
      key: StorageKeys.userData,
      value: jsonEncode(user.toJson()),
    );
    return user.toEntity();
  }

  @override
  Future<User> updateProfile({
    String? name,
    String? whatsappNumber,
    String? avatar,
    String? bio,
    String? tagline,
  }) async {
    final user = await _remoteDataSource.updateProfile(
      name: name,
      whatsappNumber: whatsappNumber,
      avatar: avatar,
      bio: bio,
      tagline: tagline,
    );
    await _secureStorage.write(
      key: StorageKeys.userData,
      value: jsonEncode(user.toJson()),
    );
    return user.toEntity();
  }

  @override
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

  @override
  Future<void> logout() async {
    await _secureStorage.delete(key: StorageKeys.authToken);
    await _secureStorage.delete(key: StorageKeys.userData);
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await _secureStorage.read(key: StorageKeys.authToken);
    return token != null && token.isNotEmpty;
  }

  @override
  Future<User?> getCachedUser() async {
    final userData = await _secureStorage.read(key: StorageKeys.userData);
    if (userData == null) return null;

    try {
      final json = jsonDecode(userData) as Map<String, dynamic>;
      return UserModel.fromJson(json).toEntity();
    } catch (_) {
      return null;
    }
  }
}
