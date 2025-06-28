import 'dart:async';
import 'package:ai_personal_assistant/src/config/api_keys.dart';
import 'package:ai_personal_assistant/src/config/env.dart';
import 'package:ai_personal_assistant/src/services/analytics_service.dart';
import 'package:ai_personal_assistant/src/utils/errors/tts_failure.dart';
import 'package:ai_personal_assistant/src/utils/logger.dart';
import 'package:ai_personal_assistant/src/utils/native/tts_native.dart';

/// Unified TTS client supporting:
/// - Google Cloud TTS
/// - AWS Polly
/// - On-device synthesis
class TtsClient {
  final AppEnvironment _environment;
  final String? _googleApiKey;
  final String? _awsAccessKey;
  final String? _awsSecretKey;
  final TtsNativeHandler _nativeHandler;
  final AnalyticsService _analytics;
  final Logger _logger;

  TtsClient({
    required AppEnvironment environment,
    String? googleApiKey,
    String? awsAccessKey,
    String? awsSecretKey,
    required AnalyticsService analytics,
    TtsNativeHandler? nativeHandler,
    Logger? logger,
  })  : _environment = environment,
        _googleApiKey = googleApiKey,
        _awsAccessKey = awsAccessKey,
        _awsSecretKey = awsSecretKey,
        _nativeHandler = nativeHandler ?? TtsNativeHandler(),
        _analytics = analytics,
        _logger = logger ?? Logger();

  /// Synthesizes speech from text using best available engine
  Future<void> speak(String text) async {
    try {
      if (_shouldUseNativeEngine) {
        await _speakNative(text);
      } else if (_awsAccessKey != null && _awsSecretKey != null) {
        await _speakAws(text);
      } else if (_googleApiKey != null) {
        await _speakGoogle(text);
      } else {
        throw TtsFailure('No valid TTS provider configured');
      }
    } catch (e, stackTrace) {
      _logger.error('TTS synthesis failed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  bool get _shouldUseNativeEngine {
    return _environment.isProduction || _googleApiKey == null;
  }

  Future<void> _speakNative(String text) async {
    _analytics.trackEvent('tts_engine_used', properties: {'engine': 'native'});
    await _nativeHandler.synthesize(text);
  }

  Future<void> _speakGoogle(String text) async {
    _analytics.trackEvent('tts_engine_used', properties: {'engine': 'google'});
    // Implementation would use Google Cloud Text-to-Speech API
    throw UnimplementedError('Google TTS not implemented');
  }

  Future<void> _speakAws(String text) async {
    _analytics.trackEvent('tts_engine_used', properties: {'engine': 'aws'});
    // Implementation would use AWS Polly API
    throw UnimplementedError('AWS Polly not implemented');
  }

  /// Stops current speech synthesis
  Future<void> stop() => _nativeHandler.stop();

  /// Clean up resources
  void dispose() => _nativeHandler.dispose();
}