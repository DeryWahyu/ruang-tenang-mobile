import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../models/user_model.dart';

class AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSource(this._apiClient);

  /// POST /auth/login
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.login,
      data: {
        'email': email,
        'password': password,
      },
      fromJson: (json) => Map<String, dynamic>.from(json as Map),
    );

    if (!response.success || response.data == null) {
      throw Exception(response.error ?? 'Login gagal');
    }

    return response.data!;
  }

  /// POST /auth/register
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.register,
      data: {
        'name': name,
        'email': email,
        'password': password,
        'role': 'user',
      },
      fromJson: (json) => Map<String, dynamic>.from(json as Map),
    );

    if (!response.success || response.data == null) {
      throw Exception(response.error ?? 'Registrasi gagal');
    }

    return UserModel.fromJson(response.data!);
  }

  /// POST /auth/forgot-password
  Future<String> forgotPassword({required String email}) async {
    final response = await _apiClient.post<dynamic>(
      ApiConstants.forgotPassword,
      data: {'email': email},
    );

    return response.message ?? 'Link reset password telah dikirim ke email Anda';
  }

  /// POST /auth/reset-password
  Future<String> resetPassword({
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await _apiClient.post<dynamic>(
      ApiConstants.resetPassword,
      data: {
        'token': token,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );

    return response.message ?? 'Password berhasil direset';
  }

  /// GET /auth/me
  Future<UserModel> getProfile() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.me,
      fromJson: (json) => Map<String, dynamic>.from(json as Map),
    );

    if (!response.success || response.data == null) {
      throw Exception(response.error ?? 'Gagal memuat profil');
    }

    return UserModel.fromJson(response.data!);
  }

  /// PUT /auth/profile
  Future<UserModel> updateProfile({
    String? name,
    String? avatar,
    String? bio,
    String? tagline,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (avatar != null) data['avatar'] = avatar;
    if (bio != null) data['bio'] = bio;
    if (tagline != null) data['tagline'] = tagline;

    final response = await _apiClient.put<Map<String, dynamic>>(
      ApiConstants.updateProfile,
      data: data,
      fromJson: (json) => Map<String, dynamic>.from(json as Map),
    );

    if (!response.success || response.data == null) {
      throw Exception(response.error ?? 'Gagal update profil');
    }

    return UserModel.fromJson(response.data!);
  }

  /// PUT /auth/password
  Future<String> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    final response = await _apiClient.put<dynamic>(
      ApiConstants.updatePassword,
      data: {
        'current_password': currentPassword,
        'new_password': newPassword,
        'new_password_confirmation': newPasswordConfirmation,
      },
    );

    return response.message ?? 'Password berhasil diubah';
  }
}
