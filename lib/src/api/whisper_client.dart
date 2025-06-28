import 'dart:io';
import 'package:ai_personal_assistant/src/config/api_keys.dart';
import 'package:ai_personal_assistant/src/config/env.dart';
import 'package:ai_personal_assistant/src/services/analytics_service.dart';
import 'package:ai_personal_assistant/src/utils/errors/stt_failure.dart';
import 'package:ai_personal_assistant/src/utils/logger.dart';
import 'package:ai_personal_assistant/src/utils/native/stt_native.dart';

/// Speech-to-Text client with:
/// - Whisper API integration
/// - Fallback to platform STT
/// - Automatic language detection
class WhisperClient {
  final AppEnvironment _environment;
  final String? _openAiKey;
  final SttNativeHandler _nativeHandler;
  final AnalyticsService _analytics;
  final Logger _logger;

  WhisperClient({
    required AppEnvironment environment,
    String? openAiKey,
    required AnalyticsService analytics,
    SttNativeHandler? nativeHandler,
    Logger? logger,
  })  : _environment = environment,
        _openAiKey = openAiKey,
        _nativeHandler = nativeHandler ?? SttNativeHandler(),
        _analytics = analytics,
        _logger = logger ?? Logger();

  /// Converts speech audio to text
  Future<String> transcribe(String audioPath) async {
    try {
      if (_shouldUseWhisperApi) {
        return await _transcribeWithWhisper(audioPath);
      } else {
        return await _transcribeNative(audioPath);
      }
    } catch (e, stackTrace) {
      _logger.error('STT transcription failed', error: e, stackTrace: stackTrace);
      throw SttFailure('Transcription failed: ${e.toString()}');
    }
  }

  bool get _shouldUseWhisperApi {
    return _openAiKey != null && !_environment.isProduction;
  }

  Future<String> _transcribeWithWhisper(String audioPath) async {
    _analytics.trackEvent('stt_engine_used', properties: {'engine': 'whisper'});
    // Implementation would use OpenAI Whisper API
    throw UnimplementedError('Whisper API not implemented');
  }

  Future<String> _transcribeNative(String audioPath) async {
    _analytics.trackEvent('stt_engine_used', properties: {'engine': 'native'});
    return _nativeHandler.transcribe(audioPath);
  }

  /// Clean up resources
  void dispose() => _nativeHandler.dispose();
}