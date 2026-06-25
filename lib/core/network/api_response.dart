class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final String? error;
  final String? code;
  final List<Map<String, dynamic>>? details;

  const ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.error,
    this.code,
    this.details,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
      error: json['error'] as String?,
      code: json['code'] as String?,
      details: (json['details'] as List<dynamic>?)
          ?.map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
    );
  }
}

class PaginatedResponse<T> {
  final bool success;
  final List<T> data;
  final int page;
  final int limit;
  final int totalItems;
  final int totalPages;

  const PaginatedResponse({
    required this.success,
    required this.data,
    required this.page,
    required this.limit,
    required this.totalItems,
    required this.totalPages,
  });

  bool get hasNextPage => page < totalPages;
  bool get hasPreviousPage => page > 1;

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> json) fromJsonT,
  ) {
    return PaginatedResponse<T>(
      success: json['success'] as bool? ?? false,
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => fromJsonT(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
      page: json['page'] as int? ?? 1,
      limit: json['limit'] as int? ?? 10,
      totalItems: json['total_items'] as int? ?? 0,
      totalPages: json['total_pages'] as int? ?? 0,
    );
  }
}
