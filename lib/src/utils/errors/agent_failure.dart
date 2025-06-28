/// AI agent processing failures
class AgentFailure extends Failure {
  final String agentId;
  final String input;
  final String? model;

  const AgentFailure(
    String message, {
    String? code,
    StackTrace? stackTrace,
    required this.agentId,
    required this.input,
    this.model,
  }) : super(
          message,
          code: code,
          stackTrace: stackTrace,
          context: {
            'agent_id': agentId,
            'input': input,
            'model': model,
          },
        );

  factory AgentFailure.fromProcessingError(
    String agentId,
    String input,
    dynamic error,
    StackTrace stackTrace,
  ) {
    return AgentFailure(
      'Processing failed: ${error.toString()}',
      agentId: agentId,
      input: input,
      stackTrace: stackTrace,
    );
  }
}