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
  const UnauthorizedException({super.message = 'Sesi telah berakhir, silakan login kembali'})
      : super(statusCode: 401);
}

class ForbiddenException extends ApiException {
  const ForbiddenException({super.message = 'Anda tidak memiliki akses'})
      : super(statusCode: 403);
}

class NotFoundException extends ApiException {
  const NotFoundException({super.message = 'Data tidak ditemukan'})
      : super(statusCode: 404);
}

class ValidationException extends ApiException {
  final List<ValidationError> errors;

  const ValidationException({
    super.message = 'Validasi gagal',
    this.errors = const [],
  }) : super(statusCode: 422, code: 'ERR_VALIDATION');
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
  const RateLimitException({super.message = 'Terlalu banyak permintaan, coba lagi nanti'})
      : super(statusCode: 429);
}

class ServerException extends ApiException {
  const ServerException({super.message = 'Terjadi kesalahan pada server'})
      : super(statusCode: 500);
}

class NetworkException extends ApiException {
  const NetworkException({super.message = 'Tidak ada koneksi internet'})
      : super(statusCode: null);
}

class TimeoutException extends ApiException {
  const TimeoutException({super.message = 'Koneksi timeout, coba lagi'})
      : super(statusCode: null);
}
