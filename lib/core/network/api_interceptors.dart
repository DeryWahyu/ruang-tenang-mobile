import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/storage_keys.dart';
import 'api_exceptions.dart';

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _secureStorage;

  AuthInterceptor(this._secureStorage);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _secureStorage.read(key: StorageKeys.authToken);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

class ErrorInterceptor extends Interceptor {
  final void Function()? onUnauthorized;

  ErrorInterceptor({this.onUnauthorized});

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final statusCode = err.response?.statusCode;
    final responseData = err.response?.data;

    ApiException exception;

    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      exception = const TimeoutException();
    } else if (err.type == DioExceptionType.connectionError) {
      exception = const NetworkException();
    } else if (statusCode != null) {
      final message = responseData is Map<String, dynamic>
          ? (responseData['error'] as String? ?? 'Terjadi kesalahan')
          : 'Terjadi kesalahan';

      switch (statusCode) {
        case 401:
          onUnauthorized?.call();
          exception = UnauthorizedException(message: message);
          break;
        case 403:
          exception = ForbiddenException(message: message);
          break;
        case 404:
          exception = NotFoundException(message: message);
          break;
        case 422:
          final details = responseData is Map<String, dynamic>
              ? (responseData['details'] as List<dynamic>?)
                  ?.map((e) => ValidationError.fromJson(Map<String, dynamic>.from(e as Map)))
                  .toList()
              : <ValidationError>[];
          exception = ValidationException(message: message, errors: details ?? []);
          break;
        case 429:
          exception = RateLimitException(message: message);
          break;
        default:
          if (statusCode >= 500) {
            exception = ServerException(message: message);
          } else {
            exception = ApiException(message: message, statusCode: statusCode);
          }
      }
    } else {
      exception = const NetworkException();
    }

    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: exception,
      ),
    );
  }
}

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('┌──────────────────────────────────────────');
      debugPrint('│ [REQUEST] ${options.method} ${options.uri}');
      if (options.data != null) {
        debugPrint('│ [BODY] ${options.data}');
      }
      debugPrint('└──────────────────────────────────────────');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('┌──────────────────────────────────────────');
      debugPrint('│ [RESPONSE] ${response.statusCode} ${response.requestOptions.uri}');
      debugPrint('└──────────────────────────────────────────');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('┌──────────────────────────────────────────');
      debugPrint('│ [ERROR] ${err.response?.statusCode} ${err.requestOptions.uri}');
      debugPrint('│ [MESSAGE] ${err.message}');
      debugPrint('└──────────────────────────────────────────');
    }
    handler.next(err);
  }
}
