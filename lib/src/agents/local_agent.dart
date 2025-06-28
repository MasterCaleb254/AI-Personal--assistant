import 'dart:async';
import 'package:ai_personal_assistant/src/agents/base_agent.dart';
import 'package:ai_personal_assistant/src/data/models/agent_response.dart';
import 'package:ai_personal_assistant/src/utils/errors/agent_failure.dart';
import 'package:ai_personal_assistant/src/utils/logger.dart';
import 'package:collection/collection.dart';

/// Rule-based agent for handling predefined local commands
/// 
/// Implements deterministic behavior for common tasks without cloud dependencies
class LocalAgent implements BaseAgent {
  static const _agentId = 'local_agent';
  static const _displayName = 'Local Assistant';
  
  final List<LocalCommand> _commands;
  final String _fallbackResponse;

  /// Initialize with command registry and fallback response
  const LocalAgent({
    List<LocalCommand> commands = defaultCommands,
    String fallbackResponse = "I can't handle that request yet. Try asking something else.",
  })  : _commands = commands,
        _fallbackResponse = fallbackResponse;

  @override
  Future<AgentResponse> processInput({
    required String input,
    required List<Message> conversationHistory,
  }) async {
    try {
      final normalizedInput = _normalizeInput(input);
      final command = _findMatchingCommand(normalizedInput);

      if (command != null) {
        return await _executeCommand(command, normalizedInput, conversationHistory);
      }

      return AgentResponse(
        content: _fallbackResponse,
        sources: [],
        isComplete: true,
      );
    } catch (e, stackTrace) {
      throw AgentFailure(
        'Local command processing failed: ${e.toString()}',
        stackTrace: stackTrace,
      );
    }
  }

  String _normalizeInput(String input) {
    return input
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), ''); // Remove punctuation
  }

  LocalCommand? _findMatchingCommand(String input) {
    return _commands.firstWhereOrNull(
      (cmd) => cmd.triggers.any(
        (trigger) => input.contains(trigger),
    );
  }

  Future<AgentResponse> _executeCommand(
    LocalCommand command,
    String input,
    List<Message> history,
  ) async {
    final result = await command.execute(input, history);
    logger.i('Executed local command: ${command.name}');
    
    return AgentResponse(
      content: result,
      sources: [command.name],
      isComplete: true,
    );
  }

  @override
  String get agentId => _agentId;

  @override
  String get displayName => _displayName;

  @override
  bool get requiresInternet => false;

  /// Predefined commands for common local operations
  static const defaultCommands = [
    LocalCommand(
      name: 'Clear Conversation',
      triggers: ['clear chat', 'reset conversation', 'start over'],
      execute: _clearConversation,
    ),
    LocalCommand(
      name: 'Get Help',
      triggers: ['help', 'what can you do', 'capabilities'],
      execute: _showHelp,
    ),
    LocalCommand(
      name: 'System Info',
      triggers: ['system info', 'app version', 'about this app'],
      execute: _showSystemInfo,
    ),
    LocalCommand(
      name: 'Joke',
      triggers: ['tell joke', 'make me laugh', 'funny'],
      execute: _tellJoke,
    ),
  ];

  /// Command execution handlers
  static Future<String> _clearConversation(String input, List<Message> history) async {
    return 'Conversation history has been cleared. What would you like to talk about now?';
  }

  static Future<String> _showHelp(String input, List<Message> history) async {
    return '''
I can help with:
- Answering questions (using AI)
- Telling jokes and fun facts
- Clearing our conversation history
- Showing system information
- Setting reminders (coming soon!)

Try asking me about the weather or current time!
''';
  }

  static Future<String> _showSystemInfo(String input, List<Message> history) async {
    // In real implementation, this would use package_info_plus
    return '''
AI Personal Assistant v1.2.0
Local Agent Mode
Offline capabilities enabled
''';
  }

  static Future<String> _tellJoke(String input, List<Message> history) async {
    const jokes = [
      "Why don't scientists trust atoms? Because they make up everything!",
      "What did one wall say to the other wall? I'll meet you at the corner!",
      "Why did the scarecrow win an award? Because he was outstanding in his field!"
    ];
    return jokes[DateTime.now().millisecond % jokes.length];
  }
}

/// Definition of a local command with execution logic
class LocalCommand {
  final String name;
  final List<String> triggers;
  final Future<String> Function(String input, List<Message> history) execute;

  const LocalCommand({
    required this.name,
    required this.triggers,
    required this.execute,
  });
}