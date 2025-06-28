import 'package:ai_personal_assistant/src/services/analytics_service.dart';
import 'package:ai_personal_assistant/src/utils/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Centralized error handling with:
/// - Error classification
/// - Context enrichment
/// - Analytics integration
/// - User-friendly reporting
class ErrorHandler {
  final AnalyticsService _analytics;
  final Logger _logger;

  ErrorHandler(this._analytics, this._logger);

  /// Handle and process errors
  Failure handleError(
    dynamic error, {
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
    bool report = true,
  }) {
    final failure = _classifyError(error, stackTrace, context);

    if (report) {
      _logError(failure);
      _reportToAnalytics(failure);
    }

    return failure;
  }

  /// Classify error into specific failure type
  Failure _classifyError(
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  ) {
    // Handle custom failure types
    if (error is Failure) {
      return error;
    }

    // Classify platform errors
    switch (error.runtimeType) {
      case FirebaseAuthException:
        return AuthFailure.fromFirebase(error);
      case DriftDatabaseException:
        return DbFailure(
          'Database error: ${error.toString()}',
          operation: 'Database operation',
          stackTrace: stackTrace,
        );
      case SocketException:
        return NetworkFailure(
          'Network unavailable: ${error.toString()}',
          stackTrace: stackTrace,
        );
      case HttpException:
        return ApiFailure(
          'HTTP error: ${error.toString()}',
          endpoint: 'Unknown',
          method: 'Unknown',
          stackTrace: stackTrace,
        );
      case FileSystemException:
        return FileFailure(
          'File system error: ${error.toString()}',
          path: error.path,
          operation: 'File operation',
          stackTrace: stackTrace,
        );
      default:
        return Failure(
          'Unhandled error: ${error.toString()}',
          stackTrace: stackTrace,
          context: context ?? {},
        );
    }
  }

  void _logError(Failure failure) {
    _logger.error(
      failure.message,
      error: failure,
      stackTrace: failure.stackTrace,
    );
  }

  void _reportToAnalytics(Failure failure) {
    _analytics.trackEvent('app_error', properties: failure.toJson());
  }
}

/// Riverpod provider for error handler
final errorHandlerProvider = Provider<ErrorHandler>((ref) {
  return ErrorHandler(
    ref.watch(analyticsServiceProvider),
    ref.watch(loggerProvider),
  );
});