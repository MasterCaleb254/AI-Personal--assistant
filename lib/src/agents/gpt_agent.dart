// gpt_agent.dart
import 'package:ai_personal_assistant/src/api/openai_client.dart';
import 'package:ai_personal_assistant/src/config/di.dart';
import 'package:ai_personal_assistant/src/features/prompts/prompt_manager.dart';
import 'package:riverpod/riverpod.dart';

/// OpenAI GPT-powered agent implementation
class GptAgent implements BaseAgent {
  final OpenAIClient _client;
  final PromptManager _promptManager;
  final String _personaId;

  /// Initialize with required dependencies
  GptAgent({
    required OpenAIClient openAiClient,
    required PromptManager promptManager,
    required String personaId,
  })  : _client = openAiClient,
        _promptManager = promptManager,
        _personaId = personaId;

  /// Create instance using Riverpod providers
  factory GptAgent.fromProviders(Ref ref, String personaId) {
    return GptAgent(
      openAiClient: ref.read(openAiClientProvider),
      promptManager: ref.read(promptManagerProvider),
      personaId: personaId,
    );
  }

  @override
  Future<AgentResponse> processInput({
    required String input,
    required List<Message> conversationHistory,
  }) async {
    try {
      final systemPrompt = await _promptManager.loadPersonaPrompt(_personaId);
      final messages = _buildMessageChain(systemPrompt, conversationHistory, input);
      
      final response = await _client.chatCompletion(
        messages: messages,
        maxTokens: 500,
      );

      return AgentResponse(
        content: response.content,
        sources: response.sources,
        isComplete: response.isComplete,
      );
    } catch (e, stackTrace) {
      throw AgentFailure(
        'GPT processing failed: ${e.toString()}',
        stackTrace: stackTrace,
      );
    }
  }

  List<ChatMessage> _buildMessageChain(
    String systemPrompt,
    List<Message> history,
    String currentInput,
  ) {
    final messages = [
      ChatMessage.system(systemPrompt),
      ...history.map((msg) => msg.isUser
          ? ChatMessage.user(msg.content)
          : ChatMessage.assistant(msg.content)),
      ChatMessage.user(currentInput),
    ];

    return messages;
  }

  @override
  String get agentId => 'gpt_agent_${_personaId}';

  @override
  String get displayName => _promptManager.getPersonaDisplayName(_personaId);

  @override
  bool get requiresInternet => true;
}