/// Database operation failures
class DbFailure extends Failure {
  final String operation;
  final String? table;
  final String? query;

  const DbFailure(
    String message, {
    String? code,
    StackTrace? stackTrace,
    required this.operation,
    this.table,
    this.query,
  }) : super(
          message,
          code: code,
          stackTrace: stackTrace,
          context: {
            'operation': operation,
            'table': table,
            'query': query,
          },
        );

  factory DbFailure.fromDrift(dynamic error, StackTrace stackTrace) {
    return DbFailure(
      'Database error: ${error.toString()}',
      operation: 'Unknown',
      stackTrace: stackTrace,
    );
  }
}