import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_constants.dart';
import '../constants/app_constants.dart';
import 'api_interceptors.dart';
import 'api_response.dart';
import 'api_exceptions.dart';

class ApiClient {
  late final Dio _dio;
  final FlutterSecureStorage _secureStorage;
  final void Function()? onUnauthorized;

  ApiClient({
    required FlutterSecureStorage secureStorage,
    this.onUnauthorized,
  }) : _secureStorage = secureStorage {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.apiBaseUrl,
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        sendTimeout: AppConstants.sendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      AuthInterceptor(_secureStorage),
      ErrorInterceptor(onUnauthorized: onUnauthorized),
      LoggingInterceptor(),
    ]);
  }

  Dio get dio => _dio;

  /// Fetch raw JSON body (for endpoints that don't follow the
  /// standard `{success, data}` envelope, e.g. Journal which returns
  /// `{data: [...], total, page, limit}` directly). Throws the same
  /// [ApiException]s as the wrapped methods on HTTP/network errors.
  Future<Map<String, dynamic>> fetchBody(
    String method,
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final Response<dynamic> response;
      switch (method.toUpperCase()) {
        case 'POST':
          response = await _dio.post(path,
              data: data, queryParameters: queryParameters);
          break;
        case 'PUT':
          response = await _dio.put(path,
              data: data, queryParameters: queryParameters);
          break;
        case 'PATCH':
          response = await _dio.patch(path,
              data: data, queryParameters: queryParameters);
          break;
        case 'DELETE':
          response = await _dio.delete(path,
              data: data, queryParameters: queryParameters);
          break;
        default:
          response = await _dio.get(path, queryParameters: queryParameters);
      }
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (e) {
      throw e.error is ApiException ? e.error as ApiException : const NetworkException();
    }
  }

  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
      );
      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        fromJson,
      );
    } on DioException catch (e) {
      throw e.error is ApiException ? e.error as ApiException : const NetworkException();
    }
  }

  Future<PaginatedResponse<T>> getPaginated<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(Map<String, dynamic> json) fromJson,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
      );
      return PaginatedResponse.fromJson(
        response.data as Map<String, dynamic>,
        fromJson,
      );
    } on DioException catch (e) {
      throw e.error is ApiException ? e.error as ApiException : const NetworkException();
    }
  }

  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        fromJson,
      );
    } on DioException catch (e) {
      throw e.error is ApiException ? e.error as ApiException : const NetworkException();
    }
  }

  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        fromJson,
      );
    } on DioException catch (e) {
      throw e.error is ApiException ? e.error as ApiException : const NetworkException();
    }
  }

  Future<ApiResponse<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        fromJson,
      );
    } on DioException catch (e) {
      throw e.error is ApiException ? e.error as ApiException : const NetworkException();
    }
  }

  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        fromJson,
      );
    } on DioException catch (e) {
      throw e.error is ApiException ? e.error as ApiException : const NetworkException();
    }
  }

  Future<ApiResponse<T>> uploadFile<T>(
    String path, {
    required FormData formData,
    T Function(dynamic json)? fromJson,
    void Function(int, int)? onSendProgress,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: formData,
        onSendProgress: onSendProgress,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );
      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        fromJson,
      );
    } on DioException catch (e) {
      throw e.error is ApiException ? e.error as ApiException : const NetworkException();
    }
  }
}
