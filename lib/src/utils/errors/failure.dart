/// Base class for all application failures
abstract class Failure implements Exception {
  final String message;
  final String? code;
  final StackTrace? stackTrace;
  final DateTime timestamp;
  final Map<String, dynamic> context;

  const Failure(
    this.message, {
    this.code,
    this.stackTrace,
    this.context = const {},
  }) : timestamp = DateTime.now();

  @override
  String toString() {
    return 'Failure: $message${code != null ? ' ($code)' : ''}'
        '\nTimestamp: ${timestamp.toIso8601String()}'
        '\nContext: $context'
        '${stackTrace != null ? '\nStackTrace: $stackTrace' : ''}';
  }

  /// Convert to JSON for logging/analytics
  Map<String, dynamic> toJson() {
    return {
      'type': runtimeType.toString(),
      'message': message,
      'code': code,
      'timestamp': timestamp.toIso8601String(),
      'context': context,
      'stack_trace': stackTrace?.toString(),
    };
  }
}