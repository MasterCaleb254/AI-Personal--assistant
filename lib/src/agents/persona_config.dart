// persona_config.dart
import 'package:ai_personal_assistant/src/features/prompts/prompt_manager.dart';

/// Configuration for agent personas
/// 
/// Combines prompt templates with behavioral parameters
class PersonaConfig {
  final PromptManager promptManager;
  final Map<String, dynamic> _config;

  PersonaConfig({
    required this.promptManager,
    required Map<String, dynamic> config,
  }) : _config = config;

  /// Get behavior parameter with type safety
  T getBehaviorParam<T>(String key, T defaultValue) {
    final value = _config[key];
    if (value is T) return value;
    return defaultValue;
  }

  /// Apply persona configuration to agent
  void configureAgent(BaseAgent agent) {
    if (agent is GptAgent) {
      final temperature = getBehaviorParam<double>('temperature', 0.7);
      agent.setTemperature(temperature);
    }
  }
}