// base_agent.dart
import 'package:ai_personal_assistant/src/data/models/agent_response.dart';
import 'package:ai_personal_assistant/src/utils/errors/agent_failure.dart';

/// Abstract interface for all AI agents
/// 
/// Follows SRP: Handles only conversation processing logic
abstract class BaseAgent {
  /// Processes user input and returns an agent response
  /// 
  /// [input]: Raw user input text
  /// [conversationHistory]: Previous messages in the conversation
  /// 
  /// Throws [AgentFailure] on processing errors
  Future<AgentResponse> processInput({
    required String input,
    required List<Message> conversationHistory,
  });

  /// Agent identifier for UI and analytics
  String get agentId;

  /// Display name shown to users
  String get displayName;

  /// Whether agent requires internet connection
  bool get requiresInternet;
}