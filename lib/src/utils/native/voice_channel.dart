import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:ai_personal_assistant/src/utils/errors/native_failure.dart';
import 'package:ai_personal_assistant/src/utils/logger.dart';

/// Unified interface for native voice operations
abstract class VoiceChannel {
  Future<String> startRecording();
  Future<void> stopRecording();
  Future<void> playAudio(String filePath);
  Future<void> stopPlayback();
  Future<void> setVolume(double volume);
  Future<bool> hasRecordingPermission();
  Future<void> requestRecordingPermission();
}

/// Platform-specific implementation using method channels
class MethodChannelVoice extends VoiceChannel {
  static const _channel = MethodChannel('ai.assistant/voice');
  static const _permissionChannel = MethodChannel('ai.assistant/permissions');
  final Logger _logger;

  MethodChannelVoice({Logger? logger}) : _logger = logger ?? Logger();

  @override
  Future<String> startRecording() async {
    try {
      final filePath = await _channel.invokeMethod<String>('startRecording');
      return filePath ?? '';
    } on PlatformException catch (e, stackTrace) {
      _logger.error('Recording start failed', error: e, stackTrace: stackTrace);
      throw NativeFailure.fromPlatformException(e);
    }
  }

  @override
  Future<void> stopRecording() async {
    try {
      await _channel.invokeMethod('stopRecording');
    } on PlatformException catch (e, stackTrace) {
      _logger.error('Recording stop failed', error: e, stackTrace: stackTrace);
      throw NativeFailure.fromPlatformException(e);
    }
  }

  @override
  Future<void> playAudio(String filePath) async {
    try {
      await _channel.invokeMethod('playAudio', {'filePath': filePath});
    } on PlatformException catch (e, stackTrace) {
      _logger.error('Audio playback failed', error: e, stackTrace: stackTrace);
      throw NativeFailure.fromPlatformException(e);
    }
  }

  @override
  Future<void> stopPlayback() async {
    try {
      await _channel.invokeMethod('stopPlayback');
    } on PlatformException catch (e, stackTrace) {
      _logger.error('Playback stop failed', error: e, stackTrace: stackTrace);
      throw NativeFailure.fromPlatformException(e);
    }
  }

  @override
  Future<void> setVolume(double volume) async {
    try {
      await _channel.invokeMethod('setVolume', {'volume': volume.clamp(0.0, 1.0)});
    } on PlatformException catch (e, stackTrace) {
      _logger.error('Volume set failed', error: e, stackTrace: stackTrace);
      throw NativeFailure.fromPlatformException(e);
    }
  }

  @override
  Future<bool> hasRecordingPermission() async {
    if (Platform.isWeb) return false;
    
    try {
      return await _permissionChannel.invokeMethod<bool>('hasRecordingPermission') ?? false;
    } on PlatformException catch (e, stackTrace) {
      _logger.error('Permission check failed', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  @override
  Future<void> requestRecordingPermission() async {
    if (Platform.isWeb) return;
    
    try {
      await _permissionChannel.invokeMethod('requestRecordingPermission');
    } on PlatformException catch (e, stackTrace) {
      _logger.error('Permission request failed', error: e, stackTrace: stackTrace);
      throw NativeFailure.fromPlatformException(e);
    }
  }
}