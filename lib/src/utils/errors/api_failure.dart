import 'package:http/http.dart';

/// API-related failures
class ApiFailure extends Failure {
  final String endpoint;
  final String method;
  final int? statusCode;
  final dynamic responseBody;

  const ApiFailure(
    String message, {
    String? code,
    StackTrace? stackTrace,
    required this.endpoint,
    required this.method,
    this.statusCode,
    this.responseBody,
  }) : super(
          message,
          code: code,
          stackTrace: stackTrace,
          context: {
            'endpoint': endpoint,
            'method': method,
            'status_code': statusCode,
            'response_body': responseBody?.toString(),
          },
        );

  factory ApiFailure.fromResponse(Response response) {
    final statusCode = response.statusCode;
    String message;
    
    switch (statusCode) {
      case 400:
        message = 'Bad request';
        break;
      case 401:
        message = 'Unauthorized';
        break;
      case 403:
        message = 'Forbidden';
        break;
      case 404:
        message = 'Resource not found';
        break;
      case 429:
        message = 'Rate limit exceeded';
        break;
      case 500:
        message = 'Server error';
        break;
      default:
        message = 'HTTP error $statusCode';
    }
    
    return ApiFailure(
      message,
      endpoint: response.request?.url.toString() ?? 'Unknown',
      method: response.request?.method ?? 'Unknown',
      statusCode: statusCode,
      responseBody: response.body,
    );
  }

  factory ApiFailure.fromException(dynamic error, StackTrace stackTrace) {
    return ApiFailure(
      error.toString(),
      stackTrace: stackTrace,
      endpoint: 'Unknown',
      method: 'Unknown',
    );
  }
}