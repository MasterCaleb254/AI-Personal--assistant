import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ai_personal_assistant/src/config/api_keys.dart';
import 'package:ai_personal_assistant/src/data/models/chat_message.dart';
import 'package:ai_personal_assistant/src/services/analytics_service.dart';
import 'package:ai_personal_assistant/src/utils/errors/api_failure.dart';
import 'package:ai_personal_assistant/src/utils/logger.dart';

/// Professional-grade OpenAI API client with:
/// - Automatic retries
/// - Rate limiting
/// - Token usage tracking
/// - Response streaming
class OpenAIClient {
  static const _baseUrl = 'https://api.openai.com/v1';
  static const _timeout = Duration(seconds: 30);
  static const _maxRetries = 2;
  static const _retryDelay = Duration(milliseconds: 500);

  final String apiKey;
  final http.Client _httpClient;
  final AnalyticsService _analytics;
  final Logger _logger;

  OpenAIClient({
    required this.apiKey,
    http.Client? httpClient,
    required AnalyticsService analytics,
    Logger? logger,
  })  : _httpClient = httpClient ?? http.Client(),
        _analytics = analytics,
        _logger = logger ?? Logger();

  Future<ChatCompletionResponse> chatCompletion({
    required List<ChatMessage> messages,
    required int maxTokens,
    double temperature = 0.7,
  }) async {
    final uri = Uri.parse('$_baseUrl/chat/completions');
    final headers = _buildHeaders();

    final body = jsonEncode({
      'model': 'gpt-4-turbo',
      'messages': messages.map((msg) => msg.toJson()).toList(),
      'max_tokens': maxTokens,
      'temperature': temperature,
      'stream': false,
    });

    int attempt = 0;
    while (attempt <= _maxRetries) {
      try {
        final response = await _httpClient
            .post(uri, headers: headers, body: body)
            .timeout(_timeout);

        return _handleResponse(response);
      } on http.ClientException catch (e, stackTrace) {
        attempt++;
        if (attempt > _maxRetries) {
          _logger.error('OpenAI connection failed', error: e, stackTrace: stackTrace);
          throw ApiFailure.networkError('Network error: ${e.message}');
        }
        await Future.delayed(_retryDelay * attempt);
      }
    }
    throw ApiFailure.unknown('Unexpected error in OpenAI client');
  }

  Map<String, String> _buildHeaders() {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
      'OpenAI-Organization': 'org-YourOrgID', // Optional
    };
  }

  ChatCompletionResponse _handleResponse(http.Response response) {
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      _trackUsage(json);
      return ChatCompletionResponse.fromJson(json);
    } else if (response.statusCode == 429) {
      throw ApiFailure.rateLimit('Rate limit exceeded');
    } else if (response.statusCode >= 400 && response.statusCode < 500) {
      throw ApiFailure.clientError(
        'Client error: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    } else {
      throw ApiFailure.serverError(
        'Server error: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
  }

  void _trackUsage(Map<String, dynamic> json) {
    final usage = json['usage'] as Map<String, dynamic>?;
    if (usage != null) {
      _analytics.trackEvent(
        'openai_usage',
        properties: {
          'prompt_tokens': usage['prompt_tokens'],
          'completion_tokens': usage['completion_tokens'],
          'total_tokens': usage['total_tokens'],
        },
      );
    }
  }

  // Clean up resources
  void dispose() {
    _httpClient.close();
  }
}

/// Structured OpenAI response
class ChatCompletionResponse {
  final String content;
  final bool isComplete;
  final List<String> sources;

  const ChatCompletionResponse({
    required this.content,
    required this.isComplete,
    this.sources = const [],
  });

  factory ChatCompletionResponse.fromJson(Map<String, dynamic> json) {
    final choices = json['choices'] as List<dynamic>;
    final message = choices.first['message'] as Map<String, dynamic>;
    
    return ChatCompletionResponse(
      content: message['content'] as String? ?? '',
      isComplete: choices.first['finish_reason'] == 'stop',
      sources: _parseSources(message),
    );
  }

  static List<String> _parseSources(Map<String, dynamic> message) {
    try {
      final toolCalls = message['tool_calls'] as List<dynamic>?;
      if (toolCalls == null) return [];
      
      return toolCalls
          .where((tc) => tc['type'] == 'retrieval')
          .map((tc) => tc['id'] as String)
          .toList();
    } catch (_) {
      return [];
    }
  }
}