/// Text-to-Speech specific failures
class TtsFailure extends Failure {
  final String? engine;
  final String? language;
  final String? voiceId;

  const TtsFailure(
    String message, {
    String? code,
    StackTrace? stackTrace,
    this.engine,
    this.language,
    this.voiceId,
  }) : super(
          message,
          code: code,
          stackTrace: stackTrace,
          context: {
            'engine': engine,
            'language': language,
            'voice_id': voiceId,
          },
        );

  factory TtsFailure.fromPlatformError(dynamic error) {
    if (error is String) {
      return TtsFailure('Platform error: $error');
    }
    return TtsFailure('Unknown platform error');
  }
}