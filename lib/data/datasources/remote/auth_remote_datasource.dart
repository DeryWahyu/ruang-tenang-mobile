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
      data: {'email': email, 'password': password},
      fromJson: (json) => Map<String, dynamic>.from(json as Map),
    );

    if (!response.success || response.data == null) {
      throw Exception(response.error ?? 'Login gagal');
    }

    return response.data!;
  }

  Future<void> setVerificationPhone({
    required String challenge,
    required String whatsappNumber,
  }) async {
    await _apiClient.post<dynamic>(
      '/auth/verification/phone',
      data: {
        'verification_token': challenge,
        'whatsapp_number': whatsappNumber,
      },
    );
  }

  Future<Map<String, dynamic>> verifyPhone({
    required String challenge,
    required String code,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/auth/verification/verify',
      data: {'verification_token': challenge, 'code': code},
      fromJson: (json) => Map<String, dynamic>.from(json as Map),
    );
    if (!response.success || response.data == null) {
      throw Exception(response.error ?? 'Kode OTP tidak valid');
    }
    return response.data!;
  }

  /// POST /auth/register
  Future<UserModel> register({
    required String name,
    required String email,
    required String whatsappNumber,
    required String password,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.register,
      data: {
        'name': name,
        'email': email,
        'whatsapp_number': whatsappNumber,
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

    return response.message ?? 'Kode reset dikirim ke WhatsApp yang terdaftar';
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
        'new_password': password,
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
    String? whatsappNumber,
    String? avatar,
    String? bio,
    String? tagline,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (whatsappNumber != null) data['whatsapp_number'] = whatsappNumber;
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
