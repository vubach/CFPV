/// Generic API response wrapper matching backend convention.
class ApiResponse<T> {
  final T? data;
  final String? message;
  final int? statusCode;
  final String? error;

  const ApiResponse({
    this.data,
    this.message,
    this.statusCode,
    this.error,
  });

  bool get isSuccess => statusCode != null && statusCode! >= 200 && statusCode! < 300;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse(
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
      message: json['message'] as String?,
      statusCode: json['statusCode'] as int?,
      error: json['error'] as String?,
    );
  }
}

/// Paginated list response.
class PaginatedResponse<T> {
  final List<T> data;
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  const PaginatedResponse({
    required this.data,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  bool get hasMore => page < totalPages;

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    final meta = json['meta'] as Map<String, dynamic>? ?? {};
    return PaginatedResponse(
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => fromJsonT(e))
              .toList() ??
          [],
      page: meta['page'] as int? ?? 1,
      limit: meta['limit'] as int? ?? 20,
      total: meta['total'] as int? ?? 0,
      totalPages: meta['totalPages'] as int? ?? 0,
    );
  }
}
