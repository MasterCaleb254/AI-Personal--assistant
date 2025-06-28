/// File system operation failures
class FileFailure extends Failure {
  final String path;
  final String operation;
  final int? fileSize;

  const FileFailure(
    String message, {
    String? code,
    StackTrace? stackTrace,
    required this.path,
    required this.operation,
    this.fileSize,
  }) : super(
          message,
          code: code,
          stackTrace: stackTrace,
          context: {
            'path': path,
            'operation': operation,
            'file_size': fileSize,
          },
        );

  factory FileFailure.fromIoException(dynamic error, StackTrace stackTrace) {
    return FileFailure(
      'File operation failed: ${error.toString()}',
      path: 'Unknown',
      operation: 'Unknown',
      stackTrace: stackTrace,
    );
  }
}