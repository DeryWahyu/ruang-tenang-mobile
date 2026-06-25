class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? code;
  final dynamic data;

  const ApiException({
    required this.message,
    this.statusCode,
    this.code,
    this.data,
  });

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException({String message = 'Sesi telah berakhir, silakan login kembali'})
      : super(message: message, statusCode: 401);
}

class ForbiddenException extends ApiException {
  const ForbiddenException({String message = 'Anda tidak memiliki akses'})
      : super(message: message, statusCode: 403);
}

class NotFoundException extends ApiException {
  const NotFoundException({String message = 'Data tidak ditemukan'})
      : super(message: message, statusCode: 404);
}

class ValidationException extends ApiException {
  final List<ValidationError> errors;

  const ValidationException({
    String message = 'Validasi gagal',
    this.errors = const [],
  }) : super(message: message, statusCode: 422, code: 'ERR_VALIDATION');
}

class ValidationError {
  final String field;
  final String message;

  const ValidationError({required this.field, required this.message});

  factory ValidationError.fromJson(Map<String, dynamic> json) {
    return ValidationError(
      field: json['field'] as String? ?? '',
      message: json['message'] as String? ?? '',
    );
  }
}

class RateLimitException extends ApiException {
  const RateLimitException({String message = 'Terlalu banyak permintaan, coba lagi nanti'})
      : super(message: message, statusCode: 429);
}

class ServerException extends ApiException {
  const ServerException({String message = 'Terjadi kesalahan pada server'})
      : super(message: message, statusCode: 500);
}

class NetworkException extends ApiException {
  const NetworkException({String message = 'Tidak ada koneksi internet'})
      : super(message: message, statusCode: null);
}

class TimeoutException extends ApiException {
  const TimeoutException({String message = 'Koneksi timeout, coba lagi'})
      : super(message: message, statusCode: null);
}
