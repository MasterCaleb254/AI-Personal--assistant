/// Network connectivity failures
class NetworkFailure extends Failure {
  final String? host;
  final int? port;

  const NetworkFailure(
    String message, {
    String? code,
    StackTrace? stackTrace,
    this.host,
    this.port,
  }) : super(
          message,
          code: code,
          stackTrace: stackTrace,
          context: {
            'host': host,
            'port': port,
          },
        );

  factory NetworkFailure.fromException(dynamic error, StackTrace stackTrace) {
    return NetworkFailure(
      'Network error: ${error.toString()}',
      stackTrace: stackTrace,
    );
  }
}