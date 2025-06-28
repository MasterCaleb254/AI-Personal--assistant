import 'package:riverpod/riverpod.dart';
import 'env.dart';
import 'api_keys.dart';
import 'package:ai_personal_assistant/src/api/openai_client.dart';
import 'package:ai_personal_assistant/src/api/tts_client.dart';
import 'package:ai_personal_assistant/src/services/analytics_service.dart';

/// Global provider container instance
/// 
/// Initialize once at application startup in `main.dart`
final ProviderContainer providerContainer = ProviderContainer();

/// Environment provider
final environmentProvider = Provider<AppEnvironment>((ref) {
  throw UnimplementedError('Environment provider must be overridden');
});

/// API keys provider with environment-aware configuration
final apiKeysProvider = Provider<ApiKeys>((ref) {
  final env = ref.watch(environmentProvider);
  
  // In production, keys must come from secure storage
  if (env.isProduction) {
    return ApiKeys.create(
      openAiApiKey: _fetchFromSecureStorage('OPENAI_KEY'),
      googleCloudApiKey: _fetchFromSecureStorage('GOOGLE_KEY'),
      awsAccessKeyId: _fetchFromSecureStorage('AWS_ACCESS_KEY'),
      awsSecretAccessKey: _fetchFromSecureStorage('AWS_SECRET'),
    );
  } 
  // For development, allow local configuration
  else {
    return ApiKeys.create(
      openAiApiKey: const String.fromEnvironment('OPENAI_KEY'),
      googleCloudApiKey: const String.fromEnvironment('GOOGLE_KEY'),
      awsAccessKeyId: const String.fromEnvironment('AWS_ACCESS_KEY'),
      awsSecretAccessKey: const String.fromEnvironment('AWS_SECRET'),
    );
  }
});

/// OpenAI client provider with automatic cleanup
final openAiClientProvider = Provider.autoDispose<OpenAIClient>((ref) {
  final keys = ref.watch(apiKeysProvider);
  final analytics = ref.watch(analyticsServiceProvider);
  
  return OpenAIClient(
    apiKey: keys.openAiApiKey,
    analyticsService: analytics,
  );
});

/// Text-to-Speech client provider with environment-specific configuration
final ttsClientProvider = Provider.autoDispose<TtsClient>((ref) {
  final env = ref.watch(environmentProvider);
  final keys = ref.watch(apiKeysProvider);
  final analytics = ref.watch(analyticsServiceProvider);
  
  return TtsClient(
    environment: env,
    googleApiKey: keys.googleCloudApiKey,
    awsAccessKey: keys.awsAccessKeyId,
    awsSecretKey: keys.awsSecretAccessKey,
    analyticsService: analytics,
  );
});

/// Implementation placeholder for secure storage retrieval
String _fetchFromSecureStorage(String key) {
  // Implementation details would integrate with Flutter Secure Storage
  // or platform-specific secure storage mechanisms
  throw UnimplementedError('Secure storage access not implemented');
}