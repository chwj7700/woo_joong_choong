/// API 예외 클래스
class ApiException implements Exception {
  final int statusCode;
  final String message;
  
  ApiException({
    required this.statusCode,
    required this.message,
  });
  
  @override
  String toString() => 'ApiException: $statusCode - $message';
}

/// 시간 초과 예외 클래스
class TimeoutException implements Exception {
  @override
  String toString() => 'TimeoutException: 요청이 시간 초과되었습니다';
}

/// 위치 서비스 예외 클래스
class LocationException implements Exception {
  final String message;
  
  LocationException(this.message);
  
  @override
  String toString() => 'LocationException: $message';
} 